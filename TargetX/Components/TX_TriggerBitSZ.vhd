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
    globals               : in  globals_t   := globals_t_null;
    reg_out               : out registerT := registerT_null;  
    
    TARGET_TB_in          : in  tb_vec_type;
    TARGET_TB_out         : out tb_vec_type;
    read_out              : in  std_logic_vector(31 downto 0) := (others => '0');
    BUSA_CLR_in           : in  std_logic := '0';
    BUSA_CLR_out          : out std_logic := '0';
    current_timestamp_out : out std_logic_vector(31 downto 0) := (others => '0');

    timestamp_out_reset   : out std_logic_vector(31 downto 0) := (others => '0');
    
    timestamp_out         : out std_logic_vector(31 downto 0) := (others => '0');
    timestamp_out_fine    : out std_logic_vector(31 downto 0) := (others => '0');
    readout_counter       : out std_logic_vector(31 downto 0) := (others => '0')
    
  );
end entity;

architecture rtl of TX_TriggerBitSZ is
  
    signal i_reg_out         : registerT_a(TARGET_TB_in'range)  := (others=>  registerT_null);  
    signal   i_reg           :  registerT:= registerT_null;
    signal trigger_mask1         : std_logic_vector(15 downto 0) := x"0008";
    
    signal trigger_switch    : std_logic_vector(15 downto 0) := x"0001";
    
    signal trigger_ASIC    : std_logic_vector(15 downto 0) := x"0000";
    signal trigger_ASIC_mask    : std_logic_vector(15 downto 0) := x"0000";
    
    signal trigger_time_window    : std_logic_vector(15 downto 0) := x"0000";
    signal No_trigger    : std_logic_vector(15 downto 0) := x"0000";
    constant No_trigger_const    : std_logic_vector(15 downto 0) := x"0001";

  signal edgedetection_tb_out :   optional_trigger_bit_t_a(TARGET_TB_in'range) :=(others =>  optional_trigger_bit_t_null);
  signal RX_m2s : axisStream_32_m2s_a(0 to 3) := (others =>  axisStream_32_m2s_null);
  signal RX_s2m : axisStream_32_s2m_a(0 to 3) := (others =>  axisStream_32_s2m_null);


  signal TX_m2s : axisStream_32_m2s_a(0 to 3) :=(others => axisStream_32_m2s_null);
  signal TX_s2m : axisStream_32_s2m_a(0 to 3) :=(others => axisStream_32_s2m_null);  
  
 
  signal out_RX_m2s : axisStream_32_m2s_a(0 to 3) := (others =>  axisStream_32_m2s_null);
  signal out_RX_s2m : axisStream_32_s2m_a(0 to 3) := (others =>  axisStream_32_s2m_null);


  signal out_TX_m2s : axisStream_32_m2s_a(0 to 3) :=(others => axisStream_32_m2s_null);
  signal out_TX_s2m : axisStream_32_s2m_a(0 to 3) :=(others => axisStream_32_s2m_null);  
  
  SIGNAL TARGET_TB_out_out_buffer   :  tb_vec_type := (others =>(others => '0'));
  
  signal trigger_out_valid    : std_logic := '0';
  
  signal timeStamp : std_logic_vector(63 downto 0)  := (others => '0');
  signal last_trigger_timeStamp : std_logic_vector(63 downto 0)  := (others => '0');
  signal last_trigger_timeStamp_valid : std_logic  := '0';
  

  signal counter_max_slv : std_logic_vector(31 downto 0) := x"00000400";
  signal counter : std_logic_vector(31 downto 0) := (others => '0');
  
  signal reset_slv : std_logic_vector(15 downto 0) := (others => '0');
  signal reset_sl  : std_logic := '0';

  
  
  
  signal disgrard_event :  std_logic := '0';
  signal isreceiving:  std_logic := '0';
  function isReadout(self : std_logic_vector) return boolean is

  begin 

    return self = x"00001234";

  end function;
  
  function isValid(self : optional_trigger_bit_t_a) return boolean is
      
  begin 
    
    for j in self'range loop 
       if self(j).valid = '1' then 
         return true;
       end if;
     end loop;
     return false;
     
   end function;
   
   function u_diff(lhs, rhs : STD_LOGIC_VECTOR) return STD_LOGIC_VECTOR is 
     variable ret : STD_LOGIC_VECTOR(lhs'range):= (others => '0');
   begin
     if lhs > rhs then
       ret := lhs - rhs;
     else
       ret := rhs - lhs;
     end if;
    return ret;

  end function;
begin
  
  
    BUSA_CLR_out <= trigger_out_valid;
    readout_counter <= counter;
    
    
  process(globals.clk) is 
    variable rx : axisStream_32_master_a(RX_m2s'range) :=  (others => axisStream_32_master_null);
    
    variable buff: std_logic_vector(31 downto 0);
    variable buff2: std_logic_vector(31 downto 0);
  begin
    if rising_edge(globals.clk) then 
      pull(rx, RX_s2m);
    
      buff := (others => '0');
      buff2 := (others => '0');
      timeStamp <= timeStamp + 1;
      if u_diff(last_trigger_timeStamp , timeStamp)(15 downto 0) > trigger_time_window then
        last_trigger_timeStamp_valid <= '0';
      end if;
      
      if isReadout(read_out) or reset_sl = '1' then
       -- counter <= (others => '0');
        timestamp_out_reset <= timeStamp(63 downto 32);
      end if;
      

      if isValid(edgedetection_tb_out) and  all_ready_to_send(rx)   then
       
        send_data(rx(2), timeStamp(63 downto 32));
        send_data(rx(3), timeStamp(31 downto 0));
        buff(4 downto 0) := edgedetection_tb_out(1).trigger_bit(5 downto 1);
        buff(9 downto 5) := edgedetection_tb_out(2).trigger_bit(5 downto 1);
        buff(14 downto 10) := edgedetection_tb_out(3).trigger_bit(5 downto 1);
        buff(19 downto 15) := edgedetection_tb_out(4).trigger_bit(5 downto 1);
        buff(24 downto 20) := edgedetection_tb_out(5).trigger_bit(5 downto 1);
        buff(29 downto 25) := edgedetection_tb_out(6).trigger_bit(5 downto 1);
        send_data(rx(0) , buff );

        buff2(4 downto 0) := edgedetection_tb_out(7).trigger_bit(5 downto 1);
        buff2(9 downto 5) := edgedetection_tb_out(8).trigger_bit(5 downto 1);
        buff2(14 downto 10) := edgedetection_tb_out(9).trigger_bit(5 downto 1);
        buff2(19 downto 15) := edgedetection_tb_out(10).trigger_bit(5 downto 1);
        send_data(rx(1), buff2 );
        


         
        
        
      end if;
      if isValid(edgedetection_tb_out) and  edgedetection_tb_out(conv_integer(trigger_ASIC)).trigger_bit  = trigger_ASIC_mask then
          last_trigger_timeStamp <= timeStamp;
          last_trigger_timeStamp_valid <= '1';
      end if;
  

     push(rx, RX_m2s);

    end if;
  end process;
  
  buffer_fifo: for I in RX_m2s'range  generate
    b_fifo : entity work.fifo_cc_axi_32 generic map (
      DATA_WIDTH => 32,
      DEPTH => 8
    ) port map (
      clk      => globals.clk,
      rst      => reset_sl,
      RX_m2s   => RX_m2s(I),
      RX_s2m   =>  RX_s2m(I),

      TX_m2s  => TX_m2s(I),
      TX_s2m  => TX_s2m(I)
    );
  end generate;


  

  
  process(globals.clk) is 
    variable tx : axisStream_32_master_a(RX_m2s'range) :=  (others => axisStream_32_master_null);
    variable rx_buff : axisStream_32_slave_a(RX_m2s'range) :=  (others => axisStream_32_slave_null);
    --variable buff : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    --variable buff2 : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    --variable buff_ts : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    --variable buff_ts_fine : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    variable full_timeStamp: STD_LOGIC_VECTOR(63 downto 0) := (others => '0');

  begin 
    if rising_edge(globals.clk) then 
      pull(rx_buff, TX_m2s);
      pull(tx, out_RX_s2m);
      --buff := (others => '0');
      --buff2 := (others => '0');
      --buff_ts := (others => '0');
      --buff_ts_fine := (others => '0');
		disgrard_event <= '0';
		isreceiving <= '0';
    
    if isReadout(read_out) or reset_sl = '1' then
      counter <= (others => '0');
    end if;
    
      if all_isReceivingData(rx_buff) and all_ready_to_send(tx) then 
			isreceiving <= '1';
        --observe_data(rx_buff(2),buff_ts);
        --observe_data(rx_buff(3),buff_ts_fine);
        
        full_timeStamp := get_data(rx_buff(2))&get_data(rx_buff(3));
        --full_timeStamp( 31 downto 0) := get_data(rx_buff(3));
		  
        if No_trigger_const = No_trigger then
          counter <= counter +1;
          disgrard_event <= '1';

          send_data(tx(0),get_data(rx_buff(0))); 
          send_data(tx(1),get_data(rx_buff(1)));
          send_data(tx(2),get_data(rx_buff(2)));
          send_data(tx(3),get_data(rx_buff(3)));      

          data_read(rx_buff(0));
          data_read(rx_buff(1));
          data_read(rx_buff(2));
          data_read(rx_buff(3));
        elsif u_diff(full_timeStamp, timeStamp)(15 downto 0) > trigger_time_window then
			    disgrard_event <= '1';
          -- dump data
          data_read(rx_buff(0));
          data_read(rx_buff(1));
          data_read(rx_buff(2));
          data_read(rx_buff(3));
          --read_data(rx_buff(0),buff);
          --read_data(rx_buff(1),buff2);
          --read_data(rx_buff(2),buff_ts);
          --read_data(rx_buff(3),buff_ts_fine);  
        elsif  last_trigger_timeStamp_valid ='1' and  u_diff(full_timeStamp, last_trigger_timeStamp)(15 downto 0) < trigger_time_window then
          --read_data(rx_buff(0),buff);
          --read_data(rx_buff(1),buff2);
          --read_data(rx_buff(2),buff_ts);
          --read_data(rx_buff(3),buff_ts_fine);     
          counter <= counter +1;
          disgrard_event <= '1';
          
          send_data(tx(0),get_data(rx_buff(0))); 
          send_data(tx(1),get_data(rx_buff(1)));
          send_data(tx(2),get_data(rx_buff(2)));
          send_data(tx(3),get_data(rx_buff(3)));      
          
          data_read(rx_buff(0));
          data_read(rx_buff(1));
          data_read(rx_buff(2));
          data_read(rx_buff(3));
        end if;
        
       

      end if;


      push(tx, out_RX_m2s);
      push(rx_buff, TX_s2m);
    end if;
  end process;

  output_fifo: for I in RX_m2s'range  generate
    outfifo2 : entity work.fifo_cc_axi_32 generic map (
      DATA_WIDTH => 32,
      DEPTH => 7
    ) port map (
      clk      => globals.clk,
      rst      => reset_sl,
      RX_m2s   => out_RX_m2s(I),
      RX_s2m   => out_RX_s2m(I),

      TX_m2s  => out_TX_m2s(I),
      TX_s2m  => out_TX_s2m(I)
    );
  end generate;
  
  
  process(globals.clk) is 
   variable out_rx : axisStream_32_slave_a(RX_m2s'range) :=  (others => axisStream_32_slave_null);
    
    variable buff : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    variable buff2 : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    
    
    
    variable buff_ts : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    variable buff_ts_fine : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    
  begin 
    if rising_edge(globals.clk) then 
      pull(out_rx, out_TX_m2s);

      buff := (others => '0');
      buff2 := (others => '0');
      buff_ts := (others => '0');
      buff_ts_fine := (others => '0');
      trigger_out_valid <= '0';
      
      if all_isReceivingData(out_rx)  and isReadout(read_out) then 
        read_data(out_rx(0),buff);
        read_data(out_rx(1),buff2);
        read_data(out_rx(2),buff_ts);
        read_data(out_rx(3),buff_ts_fine);
        trigger_out_valid <= '1';
      end if;
      
     TARGET_TB_out_out_buffer(1)(5 downto 1) <= buff(4 downto 0) ;
     TARGET_TB_out_out_buffer(2)(5 downto 1) <= buff(9 downto 5) ;
     TARGET_TB_out_out_buffer(3)(5 downto 1) <= buff(14 downto 10);
     TARGET_TB_out_out_buffer(4)(5 downto 1) <= buff(19 downto 15);
     TARGET_TB_out_out_buffer(5)(5 downto 1) <= buff(24 downto 20);
     TARGET_TB_out_out_buffer(6)(5 downto 1) <= buff(29 downto 25);
      

      TARGET_TB_out_out_buffer(7)(5 downto 1)<= buff2(4 downto 0);
      TARGET_TB_out_out_buffer(8)(5 downto 1)<= buff2(9 downto 5);
      TARGET_TB_out_out_buffer(9)(5 downto 1)<= buff2(14 downto 10);
      TARGET_TB_out_out_buffer(10)(5 downto 1)<= buff2(19 downto 15);
      
      timestamp_out <= buff_ts;
      timestamp_out_fine <= buff_ts_fine;
      current_timestamp_out <= timeStamp(31 downto 0);

      
     
     
      push(out_rx, out_TX_s2m);
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
  

    TARGET_TB_out(I)(5 downto 1) <=  TARGET_TB_out_out_buffer(I) when trigger_switch(0) = '1' else TARGET_TB_in(I)(5 downto 1);

    
    
   trig_scaler :  entity work.trigger_bit_scaler 
     generic map(
        asic_number => I
      ) port map(
        globals => globals,
        reg_out    => i_reg_out(i),
        edgedetection_tb_out => edgedetection_tb_out(I)
      );
    
  end generate GEN_REG;
  
  reg_merger:   entity work.register_merger 
    generic map(
      Num_of_inputs => i_reg_out'length,
      index_counter_max=>991 -- prime number
    ) port map(
      clk => globals.clk,

      reg_in   =>i_reg_out,
      reg_out => reg_out
    );
  --reg_out <= i_reg_out(4);
  
  process(globals.clk) is 

  begin 
    if rising_edge(globals.clk) then


      reset_slv <= (others => '0');
      read_data_s( i_reg,  trigger_mask1,        register_val.trigger_mask);
      read_data_s( i_reg,  trigger_switch,       register_val.trigger_switch);
      read_data_s( i_reg,  counter_max_slv,      register_val.trigger_maxCount);
      read_data_s( i_reg,  reset_slv,            register_val.trigger_reset);
      read_data_s( i_reg,  trigger_ASIC,         register_val.trigger_ASIC);
      read_data_s( i_reg,  trigger_ASIC_mask ,   register_val.trigger_ASIC_mask);
      read_data_s( i_reg,  trigger_time_window , register_val.trigger_time_window);
      read_data_s( i_reg,  No_trigger,           register_val.no_trigger);
      
      reset_sl    <=    reset_slv(0); 

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