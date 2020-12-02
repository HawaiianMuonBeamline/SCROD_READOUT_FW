library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;
  use work.xgen_axistream_tb_package.all;
  use work.trigger_bits_data_pack.all;

entity TriggerBit_fifo is
  generic (
    depth : integer := 10
  );
  port (
    clk: in  std_logic;
    rst: in  std_logic;
    
    rx_m2s : in axisStream_tb_package_m2s := axisStream_tb_package_m2s_null;
    rx_s2m : out axisStream_tb_package_s2m := axisStream_tb_package_s2m_null;
    
    
    tx_m2s : out axisStream_tb_package_m2s := axisStream_tb_package_m2s_null;
    tx_s2m : in axisStream_tb_package_s2m := axisStream_tb_package_s2m_null
  );
end entity;

architecture rtl of TriggerBit_fifo is
  signal storage     :  tb_package_a((2**depth)-1 downto 0 ) := (others => tb_package_null);
  signal storag_last :  STD_LOGIC_VECTOR((2**depth)-1 downto 0 ) := (others => '0');
  signal head    :  UNSIGNED(depth downto 0 ) := (others => '0');
  signal tail    :  UNSIGNED(depth downto 0 ) := (others => '0');
begin
  
  tx_m2s.data <= storage( integer(tail));
  tx_m2s.last <= storag_last( integer(tail));
  
  process(clk) is
    variable v_isValid : STD_LOGIC := '0';
  begin 
    if rising_edge(clk) then 
      
      
      
      
      tx_m2s.valid <= v_isValid;
    end if;
  end process;
  
end architecture;