library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;
  use work.klm_scint_globals.all;

  use work.tdc_pkg.all;
  use work.xgen_axistream_32.all;
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;
  use ieee.std_logic_misc.all;
library work;
  use work.tdc_pkg.all;
library unisim;
  use unisim.vcomponents.all;
  use work.roling_register_p.all;
  use work.optional_trigger_bits_p.all;

entity TX_TriggerBitSZ is
  port (
    globals : globals_t := globals_t_null;
    TARGET_TB_in        : in tb_vec_type;
    TARGET_TB_out       : out tb_vec_type;
    read_out            :  in std_logic := '0';
    BUSA_CLR_in         : in std_logic := '0';
    BUSA_CLR_out        : out std_logic := '0'
  );
end entity;

architecture rtl of TX_TriggerBitSZ is
    signal   i_reg           :  registerT:= registerT_null;
    signal trigger_mask1         : std_logic_vector(15 downto 0) := x"0008";
    
    signal trigger_switch    : std_logic_vector(15 downto 0) := x"0001";
    
    type optional_trigger_bit_t_a is array (natural range <>) of optional_trigger_bit_t;

  signal edgedetection_tb_out :   optional_trigger_bit_t_a(TARGET_TB_in'range) :=(others =>  optional_trigger_bit_t_null);
  signal RX_m2s : axisStream_32_m2s_a(TARGET_TB_in'range) := (others => axisStream_32_m2s_null);
  signal RX_s2m : axisStream_32_s2m_a(TARGET_TB_in'range) := (others => axisStream_32_s2m_null);


  signal TX_m2s : axisStream_32_m2s_a(TARGET_TB_in'range) := (others => axisStream_32_m2s_null);
  signal TX_s2m : axisStream_32_s2m_a(TARGET_TB_in'range) := (others => axisStream_32_s2m_null);  
  signal egde_detected : std_logic := '0';
  
  SIGNAL TARGET_TB_out_out_buffer   :  tb_vec_type := (others =>(others => '0'));
  
  signal trigger_out_valid    : std_logic_vector(TX_m2s'range) := (others => '0');
begin
    BUSA_CLR_out <= trigger_out_valid(1);

  process(globals.clk) is 
    variable temp : std_logic := '0';
    variable rx : axisStream_32_master_a(RX_s2m'range) := (others => axisStream_32_master_null);
    variable buff: std_logic_vector(31 downto 0);
  begin
    if rising_edge(globals.clk) then 
      pull(rx, RX_s2m);
      temp := '0';
      for j in TARGET_TB_in'range loop 
        temp := temp or edgedetection_tb_out(j).valid;
      end loop;
      if ready_to_send(rx(1)) and temp = '1' then
        for j in TARGET_TB_in'range loop 
          egde_detected <= temp after 5 ns;
          buff := (others =>'0');
          buff(4 downto 0) := edgedetection_tb_out(J).trigger_bit(5 downto 1);
          send_data(rx(j) , buff );

        end loop;
      else  
        egde_detected <= '0' after 5 ns;
      end if;
      
     push(rx, RX_m2s);
    end if;
  end process;
  
  GEN_REG: 
  for I in TARGET_TB_in'range generate
  edgedetection : entity work.KLMTrigBitsEdgeDetection port map(
    clk => globals.clk,
    tb_mask=>  trigger_mask1,
    tb_in  => TARGET_TB_in(I),
    tb_out => edgedetection_tb_out(I)
  );
  

  outfifo : entity work.fifo_cc_axi_32 generic map (
    DATA_WIDTH => 5,
    DEPTH => 10
  ) port map (
    clk      => globals.clk,
    rst      => globals.rst,
    RX_m2s   => RX_m2s(I),
    RX_s2m   =>  RX_s2m(I),

    TX_m2s  => TX_m2s(I),
    TX_s2m  => TX_s2m(I)


  );
    TARGET_TB_out(I)(5 downto 1) <=  TARGET_TB_out_out_buffer(I) when trigger_switch(0) = '1' else TARGET_TB_in(I)(5 downto 1);
    process(globals.clk) is 
      variable tx: axisStream_32_slave :=   axisStream_32_slave_null;
      variable buff : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    begin 
      if rising_edge(globals.clk) then 
        pull(tx, TX_m2s(I));
		    buff := (others => '0');
        trigger_out_valid(I) <= '0';
        if isReceivingData(tx) and read_out = '1' then 
          read_data(tx,buff);
          trigger_out_valid(I) <= '1';
        end if;
		  TARGET_TB_out_out_buffer(I)(5 downto 1) <= buff(4 downto 0);
		  push(tx, TX_s2m(I));
      end if;
    end process;
    
  end generate GEN_REG;
  process(globals.clk) is 

  begin 
    if rising_edge(globals.clk) then


      read_data_s( i_reg,  trigger_mask1    , register_val.trigger_mask     );
      read_data_s( i_reg,  trigger_switch   , register_val.trigger_switch     );

    end if;
  end process;



  reg_buffer : entity work.registerBuffer generic map (
    Depth =>  10
  ) port map (

    clk => globals.clk,
    registersIn   => globals.reg,
    registersOut  => i_reg
  );
  
end architecture;