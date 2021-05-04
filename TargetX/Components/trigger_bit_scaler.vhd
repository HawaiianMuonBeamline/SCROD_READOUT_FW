library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;
  use work.roling_register_p.all;
  use work.optional_trigger_bits_p.all;
  use work.klm_scint_globals.all;
  use ieee.std_logic_unsigned.all;


entity trigger_bit_scaler is
  generic (
    asic_number : integer 
  );
  port (
    globals : globals_t   := globals_t_null;
    reg_out         : out registerT := registerT_null;
    edgedetection_tb_out :  in optional_trigger_bit_t := optional_trigger_bit_t_null
  );
end entity;

architecture rtl of trigger_bit_scaler is

  
  signal scaler_index : STD_LOGIC_VECTOR(0 downto 0) := (others => '0');
  signal buffer_sclarer_out_high : STD_LOGIC_VECTOR(15 downto 0):= (others => '0');
  
  
  signal scaler_counter_low : STD_LOGIC_VECTOR(15 downto 0):= (others => '0');
  constant scaler_counter_low_max : STD_LOGIC_VECTOR(15 downto 0):= (others => '1');
  signal scaler_counter_high : STD_LOGIC_VECTOR(15 downto 0):= (others => '0');
  
  signal scaler_counter_high_max : STD_LOGIC_VECTOR(15 downto 0):= (others => '0');
  constant header : STD_LOGIC_VECTOR(3 downto 0) := x"f";
  signal   i_reg           :  registerT:= registerT_null;
  
  signal   ADDR     : integer := 5;
  signal increment_channel : std_logic_vector(ADDR-1 downto 0) := (others => '0');
  signal increment_valid   : std_logic := '0';
  
   signal i_Cycle_over : std_logic := '0';
   

   signal B_increment : std_logic  :=  '0';
   signal B_addrb     : std_logic_vector(ADDR-1 downto 0) := (others => '0');
   signal B_doutb     : std_logic_vector(32-1 downto 0) := (others => '0');
begin
  i_Scaler_counter : entity work.Scaler_counter  generic map(
      DATA     => 32,
      ADDR     => ADDR 
    ) port map (
      clk => globals.clk,
      rst => '0',
      increment_channel => increment_channel,
      increment_valid  =>increment_valid,
      
      Cycle_over => i_Cycle_over,

      B_increment => B_increment, 
      B_addrb  => B_addrb,
      B_doutb  => B_doutb
    );
  

  process(globals.clk) is
  begin
    if rising_edge(globals.clk) then 
      scaler_counter_low <= scaler_counter_low +1;
      increment_valid <= '0';
      i_Cycle_over <= '0';
      B_increment <='0';
      
      if is_valid(edgedetection_tb_out) then 
        increment_channel <= get_data(edgedetection_tb_out)(5 downto 1);
        increment_valid <= '1';
      end if;
      if scaler_counter_low >= scaler_counter_low_max then
        scaler_counter_high <= scaler_counter_high +1;
        scaler_counter_low <= (others => '0');
      end if;
      
      if scaler_counter_high >= scaler_counter_high_max then
        i_Cycle_over <= '1';
		    scaler_counter_high <= (others => '0');
      end if;


      
      reg_out.address <= reg_addr_to_slv(
          reg_addr_ctr(
            channel => B_addrb, 
            asic   =>  std_logic_vector(to_unsigned(asic_number,8)) , 
            header => header,
            Lower_higher => scaler_index(0) 
          ));
      
      if scaler_index(0) = '0' then 
        reg_out.value <= B_doutb(15 downto 0);
        buffer_sclarer_out_high(15 downto 0) <= B_doutb(31 downto 16);
        B_increment <='1';
      else 
        reg_out.value <= buffer_sclarer_out_high;
      end if;
      scaler_index <= scaler_index +1;

      
      read_data_s( i_reg,  scaler_counter_high_max   , register_val.scaler_max_counter );
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