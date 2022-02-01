


library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use work.type_conversions_pgk.all;
use work.CSV_UtilityPkg.all;



use work.register_single_register_tb_IO_pgk.all;


entity register_single_register_tb_reader_et  is
    generic (
        FileName : string := "./register_single_register_tb_in.csv"
    );
    port (
        clk : in std_logic ;
        data : out register_single_register_tb_reader_rec
    );
end entity;   

architecture Behavioral of register_single_register_tb_reader_et is 

  constant  NUM_COL    : integer := 5;
  signal    csv_r_data : c_integer_array(NUM_COL -1 downto 0)  := (others=>0)  ;
begin

  csv_r :entity  work.csv_read_file 
    generic map (
        FileName =>  FileName, 
        NUM_COL => NUM_COL,
        useExternalClk=>true,
        HeaderLines =>  2
    ) port map (
        clk => clk,
        Rows => csv_r_data
    );

  csv_from_integer(csv_r_data(0), data.clk);
  csv_from_integer(csv_r_data(1), data.rst);
  csv_from_integer(csv_r_data(2), data.rx_m2s.last);
  csv_from_integer(csv_r_data(3), data.rx_m2s.valid);
  csv_from_integer(csv_r_data(4), data.rx_m2s.data);


end Behavioral;
---------------------------------------------------------------------------------------------------
    


library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use work.type_conversions_pgk.all;
use work.CSV_UtilityPkg.all;



use work.register_single_register_tb_IO_pgk.all;

entity register_single_register_tb_writer_et  is
    generic ( 
        FileName : string := "./register_single_register_tb_out.csv"
    ); port (
        clk : in std_logic ;
        data : in register_single_register_tb_writer_rec
    );
end entity;

architecture Behavioral of register_single_register_tb_writer_et is 
  constant  NUM_COL : integer := 10;
  signal data_int   : c_integer_array(NUM_COL - 1 downto 0)  := (others=>0);
begin

    csv_w : entity  work.csv_write_file 
        generic map (
            FileName => FileName,
            HeaderLines=> "clk; rst; rx_m2s_last; rx_m2s_valid; rx_m2s_data; rx_s2m_ready; register_debug_out; register_out_address; register_out_value; register_out_new_value",
            NUM_COL =>   NUM_COL 
        ) port map(
            clk => clk, 
            Rows => data_int
        );


  csv_to_integer(data.clk, data_int(0) );
  csv_to_integer(data.rst, data_int(1) );
  csv_to_integer(data.rx_m2s.last, data_int(2) );
  csv_to_integer(data.rx_m2s.valid, data_int(3) );
  csv_to_integer(data.rx_m2s.data, data_int(4) );
  csv_to_integer(data.rx_s2m.ready, data_int(5) );
  csv_to_integer(data.register_debug_out, data_int(6) );
  csv_to_integer(data.register_out.address, data_int(7) );
  csv_to_integer(data.register_out.value, data_int(8) );
  csv_to_integer(data.register_out.new_value, data_int(9) );


end Behavioral;
---------------------------------------------------------------------------------------------------
    

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use work.type_conversions_pgk.all;
use work.CSV_UtilityPkg.all;


use work.register_single_register_tb_IO_pgk.all;

entity register_single_register_tb_tb_csv is 
end entity;

architecture behavior of register_single_register_tb_tb_csv is 
  signal clk : std_logic := '0';
  signal data_in : register_single_register_tb_reader_rec;
  signal data_out : register_single_register_tb_writer_rec;

begin 

  clk_gen : entity work.ClockGenerator generic map ( CLOCK_period => 10 ns) port map ( clk => clk );

  csv_read : entity work.register_single_register_tb_reader_et 
    generic map (
        FileName => "./register_single_register_tb_tb_csv.csv" 
    ) port map (
        clk => clk ,data => data_in
    );
 
  csv_write : entity work.register_single_register_tb_writer_et
    generic map (
        FileName => "./register_single_register_tb_tb_csv_out.csv" 
    ) port map (
        clk => clk ,data => data_out
    );
  

  data_out.clk <=clk;
  data_out.rst <= data_in.rst;
  data_out.rx_m2s <= data_in.rx_m2s;


DUT :  entity work.register_single_register_tb  port map(

  clk => clk,
  rst => data_out.rst,
  rx_m2s => data_out.rx_m2s,
  rx_s2m => data_out.rx_s2m,
  register_debug_out => data_out.register_debug_out,
  register_out => data_out.register_out
    );

end behavior;
---------------------------------------------------------------------------------------------------
    