


library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use work.type_conversions_pgk.all;
use work.CSV_UtilityPkg.all;



use work.mppc_hv_dac_IO_pgk.all;


entity mppc_hv_dac_reader_et  is
    generic (
        FileName : string := "./mppc_hv_dac_in.csv"
    );
    port (
        clk : in std_logic ;
        data : out mppc_hv_dac_reader_rec
    );
end entity;   

architecture Behavioral of mppc_hv_dac_reader_et is 

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
  integer_to_slv(csv_r_data(5), data.tdc_done);
  integer_to_slv(csv_r_data(6), data.tdc_mon_timing);


end Behavioral;
---------------------------------------------------------------------------------------------------
    


library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use work.type_conversions_pgk.all;
use work.CSV_UtilityPkg.all;



use work.mppc_hv_dac_IO_pgk.all;

entity mppc_hv_dac_writer_et  is
    generic ( 
        FileName : string := "./mppc_hv_dac_out.csv"
    ); port (
        clk : in std_logic ;
        data : in mppc_hv_dac_writer_rec
    );
end entity;

architecture Behavioral of mppc_hv_dac_writer_et is 
  constant  NUM_COL : integer := 19;
  signal data_int   : c_integer_array(NUM_COL - 1 downto 0)  := (others=>0);
begin

    csv_w : entity  work.csv_write_file 
        generic map (
            FileName => FileName,
            HeaderLines=> "globals_clk; globals_rst; globals_reg_address; globals_reg_value; globals_reg_new_value; reg_out_address; reg_out_value; reg_out_new_value; busa_sck_dac; busa_din_dac; busb_sck_dac; busb_din_dac; tdc_cs_dac; tdc_amux_s; top_amux_s; scl_mon; sda_mon; tdc_done; tdc_mon_timing",
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
  sl_to_integer(data.busa_sck_dac, data_int(8) );
  sl_to_integer(data.busa_din_dac, data_int(9) );
  sl_to_integer(data.busb_sck_dac, data_int(10) );
  sl_to_integer(data.busb_din_dac, data_int(11) );
  slv_to_integer(data.tdc_cs_dac, data_int(12) );
  slv_to_integer(data.tdc_amux_s, data_int(13) );
  slv_to_integer(data.top_amux_s, data_int(14) );
  sl_to_integer(data.scl_mon, data_int(15) );
  sl_to_integer(data.sda_mon, data_int(16) );
  slv_to_integer(data.tdc_done, data_int(17) );
  slv_to_integer(data.tdc_mon_timing, data_int(18) );


end Behavioral;
---------------------------------------------------------------------------------------------------
    

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use work.type_conversions_pgk.all;
use work.CSV_UtilityPkg.all;


use work.mppc_hv_dac_IO_pgk.all;

entity mppc_hv_dac_tb_csv is 
end entity;

architecture behavior of mppc_hv_dac_tb_csv is 
  signal clk : std_logic := '0';
  signal data_in : mppc_hv_dac_reader_rec := mppc_hv_dac_reader_rec_null;
  signal data_out : mppc_hv_dac_writer_rec := mppc_hv_dac_writer_rec_null;

begin 

  clk_gen : entity work.ClockGenerator generic map ( CLOCK_period => 10 ns) port map ( clk => clk );

  csv_read : entity work.mppc_hv_dac_reader_et 
    generic map (
        FileName => "./mppc_hv_dac_tb_csv.csv" 
    ) port map (
        clk => clk ,data => data_in
    );
 
  csv_write : entity work.mppc_hv_dac_writer_et
    generic map (
        FileName => "./mppc_hv_dac_tb_csv_out.csv" 
    ) port map (
        clk => clk ,data => data_out
    );
  

  data_out.globals.clk <=clk;
  data_out.globals.reg <= data_in.globals.reg;
  data_out.globals.rst <= data_in.globals.rst;
  data_out.tdc_done <= data_in.tdc_done;
data_out.tdc_mon_timing <= data_in.tdc_mon_timing;


DUT :  entity work.mppc_hv_dac  port map(

  globals => data_out.globals,
  reg_out => data_out.reg_out,
  busa_sck_dac => data_out.busa_sck_dac,
  busa_din_dac => data_out.busa_din_dac,
  busb_sck_dac => data_out.busb_sck_dac,
  busb_din_dac => data_out.busb_din_dac,
  tdc_cs_dac => data_out.tdc_cs_dac,
  tdc_amux_s => data_out.tdc_amux_s,
  top_amux_s => data_out.top_amux_s,
  scl_mon => data_out.scl_mon,
  sda_mon => data_out.sda_mon,
  tdc_done => data_out.tdc_done,
  tdc_mon_timing => data_out.tdc_mon_timing
    );

end behavior;
---------------------------------------------------------------------------------------------------
    