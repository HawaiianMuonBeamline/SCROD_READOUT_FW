


library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use work.type_conversions_pgk.all;
use work.CSV_UtilityPkg.all;



use work.trigger_bit_scaler_IO_pgk.all;


entity trigger_bit_scaler_reader_et  is
    generic (
        FileName : string := "./trigger_bit_scaler_in.csv"
    );
    port (
        clk : in std_logic ;
        data : out trigger_bit_scaler_reader_rec
    );
end entity;   

architecture Behavioral of trigger_bit_scaler_reader_et is 

  constant  NUM_COL    : integer := 7;
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

  integer_to_sl(csv_r_data(0), data.globals.clk);
  integer_to_sl(csv_r_data(1), data.globals.rst);
  integer_to_slv(csv_r_data(2), data.globals.reg.address);
  integer_to_slv(csv_r_data(3), data.globals.reg.value);
  integer_to_sl(csv_r_data(4), data.globals.reg.new_value);
  integer_to_slv(csv_r_data(5), data.edgedetection_tb_out.trigger_bit);
  integer_to_sl(csv_r_data(6), data.edgedetection_tb_out.valid);


end Behavioral;
---------------------------------------------------------------------------------------------------
    


library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use work.type_conversions_pgk.all;
use work.CSV_UtilityPkg.all;



use work.trigger_bit_scaler_IO_pgk.all;

entity trigger_bit_scaler_writer_et  is
    generic ( 
        FileName : string := "./trigger_bit_scaler_out.csv"
    ); port (
        clk : in std_logic ;
        data : in trigger_bit_scaler_writer_rec
    );
end entity;

architecture Behavioral of trigger_bit_scaler_writer_et is 
  constant  NUM_COL : integer := 10;
  signal data_int   : c_integer_array(NUM_COL - 1 downto 0)  := (others=>0);
begin

    csv_w : entity  work.csv_write_file 
        generic map (
            FileName => FileName,
            HeaderLines=> "globals_clk; globals_rst; globals_reg_address; globals_reg_value; globals_reg_new_value; reg_out_address; reg_out_value; reg_out_new_value; edgedetection_tb_out_trigger_bit; edgedetection_tb_out_valid",
            NUM_COL =>   NUM_COL 
        ) port map(
            clk => clk, 
            Rows => data_int
        );


  sl_to_integer(data.globals.clk, data_int(0) );
  sl_to_integer(data.globals.rst, data_int(1) );
  slv_to_integer(data.globals.reg.address, data_int(2) );
  slv_to_integer(data.globals.reg.value, data_int(3) );
  sl_to_integer(data.globals.reg.new_value, data_int(4) );
  slv_to_integer(data.reg_out.address, data_int(5) );
  slv_to_integer(data.reg_out.value, data_int(6) );
  sl_to_integer(data.reg_out.new_value, data_int(7) );
  slv_to_integer(data.edgedetection_tb_out.trigger_bit, data_int(8) );
  sl_to_integer(data.edgedetection_tb_out.valid, data_int(9) );


end Behavioral;
---------------------------------------------------------------------------------------------------
    

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use work.type_conversions_pgk.all;
use work.CSV_UtilityPkg.all;


use work.trigger_bit_scaler_IO_pgk.all;

entity trigger_bit_scaler_tb_csv is 
end entity;

architecture behavior of trigger_bit_scaler_tb_csv is 
  signal clk : std_logic := '0';
  signal data_in : trigger_bit_scaler_reader_rec := trigger_bit_scaler_reader_rec_null;
  signal data_out : trigger_bit_scaler_writer_rec := trigger_bit_scaler_writer_rec_null;

begin 

  clk_gen : entity work.ClockGenerator generic map ( CLOCK_period => 10 ns) port map ( clk => clk );

  csv_read : entity work.trigger_bit_scaler_reader_et 
    generic map (
        FileName => "./trigger_bit_scaler_tb_csv.csv" 
    ) port map (
        clk => clk ,data => data_in
    );
 
  csv_write : entity work.trigger_bit_scaler_writer_et
    generic map (
        FileName => "./trigger_bit_scaler_tb_csv_out.csv" 
    ) port map (
        clk => clk ,data => data_out
    );
  

  data_out.globals.clk <=clk;
  data_out.globals.reg <= data_in.globals.reg;
  data_out.globals.rst <= data_in.globals.rst;
  data_out.edgedetection_tb_out <= data_in.edgedetection_tb_out;


DUT :  entity work.trigger_bit_scaler  port map(

  globals => data_out.globals,
  reg_out => data_out.reg_out,
  edgedetection_tb_out => data_out.edgedetection_tb_out
    );

end behavior;
---------------------------------------------------------------------------------------------------
    