library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use IEEE.std_logic_misc.or_reduce;

 use work.klm_scint_globals.all;
use work.tdc_pkg.all;
 use work.roling_register_p.all;


entity Trigger_bits_probe_out is

  port (
      globals        : in globals_t;
      TARGET_TB      : in tb_vec_type;
      sl_Trigger_out : out std_logic
  );
end entity;

architecture rtl of Trigger_bits_probe_out is
    signal i_trigger_out : std_logic := '0';
    signal i_trigger_counter : unsigned(15 downto 0):= (others => '0');


    signal   i_reg           :  registerT:= registerT_null;
    signal i_trigger_bit_mode : STD_LOGIC_VECTOR(15 downto 0):= (others => '0');
begin


 process(globals.clk)
  variable v_trigger_out_vec: std_logic_vector(TARGET_TB'range) := (others =>'0');
  begin
    if rising_edge(globals.clk) then
    i_trigger_counter <= i_trigger_counter + 1;
    
    for i in TARGET_TB'range loop
        if or_reduce(i_trigger_bit_mode) = '0' and (or_reduce(TARGET_TB(i)) ='1') then
            v_trigger_out_vec(i) := '1';
        elsif or_reduce(i_trigger_bit_mode) = '0' then
            v_trigger_out_vec(i) := '0';
        end if;
    end loop;

    if or_reduce(i_trigger_bit_mode) = '0' then
      i_trigger_out <= or_reduce(v_trigger_out_vec);
    elsif or_reduce(i_trigger_bit_mode) = '1'  and i_trigger_counter >= unsigned( i_trigger_bit_mode) then
      i_trigger_out <= not i_trigger_out;
      i_trigger_counter <= (others => '0');
    end if;

    read_data_s( i_reg,  i_trigger_bit_mode   , register_val.tb_scaler_mode );
    end if;
  end process;

    sl_Trigger_out <= i_trigger_out;


   reg_buffer : entity work.registerBuffer generic map (
    Depth =>  10
  ) port map (

    clk => globals.clk,
    registersIn   => globals.reg,
    registersOut  => i_reg
  );

end architecture;