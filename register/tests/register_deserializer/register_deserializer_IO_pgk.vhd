

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.std_logic_arith.all;
use work.CSV_UtilityPkg.all;


-- Start Include user packages --
use work.roling_register_p.all;

-- End Include user packages --

package register_deserializer_IO_pgk is


type register_deserializer_writer_rec is record
        clk : std_logic;  
    register_serial_in : std_logic;  
    register_out : registert;  

end record;



type register_deserializer_reader_rec is record
        clk : std_logic;  
    register_serial_in : std_logic;  

end record;


end register_deserializer_IO_pgk;

package body register_deserializer_IO_pgk is

end package body register_deserializer_IO_pgk;

        