library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;
  use work.tdc_pkg.all;

package trigger_bits_data_pack is
  
  type tb_package is record
    data : trigger_bits_t ;
    TimeStamp : std_logic_vector(63 downto 0) ;
  end record;
  
  constant tb_package_null : tb_package := (
   data => (others =>  (others => '0')),
   timeStamp => (others => '0')
 );
  
  type tb_package_a is array (natural range <>) of tb_package;
end package;

package body trigger_bits_data_pack is
end package body;