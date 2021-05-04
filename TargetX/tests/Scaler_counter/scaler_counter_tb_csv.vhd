


library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use work.type_conversions_pgk.all;
use work.CSV_UtilityPkg.all;



use work.scaler_counter_IO_pgk.all;


entity scaler_counter_reader_et  is
    generic (
        FileName : string := "./scaler_counter_in.csv"
    );
    port (
        clk : in std_logic ;
        data : out scaler_counter_reader_rec
    );
end entity;   

architecture Behavioral of scaler_counter_reader_et is 

  constant  NUM_COL    : integer := 6;
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

  integer_to_sl(csv_r_data(0), data.clk);
  integer_to_sl(csv_r_data(1), data.rst);
  integer_to_slv(csv_r_data(2), data.increment_channel);
  integer_to_sl(csv_r_data(3), data.increment_valid);
  integer_to_sl(csv_r_data(4), data.cycle_over);
  integer_to_sl(csv_r_data(5), data.b_increment);


end Behavioral;
---------------------------------------------------------------------------------------------------
    


library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use work.type_conversions_pgk.all;
use work.CSV_UtilityPkg.all;



use work.scaler_counter_IO_pgk.all;

entity scaler_counter_writer_et  is
    generic ( 
        FileName : string := "./scaler_counter_out.csv"
    ); port (
        clk : in std_logic ;
        data : in scaler_counter_writer_rec
    );
end entity;

architecture Behavioral of scaler_counter_writer_et is 
  constant  NUM_COL : integer := 8;
  signal data_int   : c_integer_array(NUM_COL - 1 downto 0)  := (others=>0);
begin

    csv_w : entity  work.csv_write_file 
        generic map (
            FileName => FileName,
            HeaderLines=> "clk; rst; increment_channel; increment_valid; cycle_over; b_increment; b_addrb; b_doutb",
            NUM_COL =>   NUM_COL 
        ) port map(
            clk => clk, 
            Rows => data_int
        );


  sl_to_integer(data.clk, data_int(0) );
  sl_to_integer(data.rst, data_int(1) );
  slv_to_integer(data.increment_channel, data_int(2) );
  sl_to_integer(data.increment_valid, data_int(3) );
  sl_to_integer(data.cycle_over, data_int(4) );
  sl_to_integer(data.b_increment, data_int(5) );
  slv_to_integer(data.b_addrb, data_int(6) );
  slv_to_integer(data.b_doutb, data_int(7) );


end Behavioral;
---------------------------------------------------------------------------------------------------
    

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use work.type_conversions_pgk.all;
use work.CSV_UtilityPkg.all;


use work.scaler_counter_IO_pgk.all;

entity scaler_counter_tb_csv is 
end entity;

architecture behavior of scaler_counter_tb_csv is 
  signal clk : std_logic := '0';
  signal data_in : scaler_counter_reader_rec := scaler_counter_reader_rec_null;
  signal data_out : scaler_counter_writer_rec := scaler_counter_writer_rec_null;

begin 

  clk_gen : entity work.ClockGenerator generic map ( CLOCK_period => 10 ns) port map ( clk => clk );

  csv_read : entity work.scaler_counter_reader_et 
    generic map (
        FileName => "./scaler_counter_tb_csv.csv" 
    ) port map (
        clk => clk ,data => data_in
    );
 
  csv_write : entity work.scaler_counter_writer_et
    generic map (
        FileName => "./scaler_counter_tb_csv_out.csv" 
    ) port map (
        clk => clk ,data => data_out
    );
  

data_out.rst <= data_in.rst;
data_out.increment_channel <= data_in.increment_channel;
data_out.increment_valid <= data_in.increment_valid;
data_out.cycle_over <= data_in.cycle_over;
data_out.b_increment <= data_in.b_increment;


DUT :  entity work.scaler_counter  port map(

  clk => clk,
  rst => data_out.rst,
  increment_channel => data_out.increment_channel,
  increment_valid => data_out.increment_valid,
  cycle_over => data_out.cycle_over,
  b_increment => data_out.b_increment,
  b_addrb => data_out.b_addrb,
  b_doutb => data_out.b_doutb
    );

end behavior;
---------------------------------------------------------------------------------------------------
    