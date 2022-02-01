

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.std_logic_arith.all;
use work.CSV_UtilityPkg.all;


-- Start Include user packages --
use work.xgen_axistream_32.all;
use work.roling_register_p.all;

-- End Include user packages --

package register_single_register_tb_IO_pgk is


type register_single_register_tb_writer_rec is record
        clk : std_logic;  
    rst : std_logic;  
    rx_m2s : axisstream_32_m2s;  
    rx_s2m : axisstream_32_s2m;  
    register_debug_out : std_logic;  
    register_out : registert;  

end record;



type register_single_register_tb_reader_rec is record
        clk : std_logic;  
    rst : std_logic;  
    rx_m2s : axisstream_32_m2s;  

end record;


end register_single_register_tb_IO_pgk;

package body register_single_register_tb_IO_pgk is

end package body register_single_register_tb_IO_pgk;

        