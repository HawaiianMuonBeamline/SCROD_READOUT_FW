
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.CSV_UtilityPkg.all;


-- Start Include user packages --
use work.roling_register_p.all;
use work.optional_trigger_bits_p.all;
use work.klm_scint_globals.all;

-- End Include user packages --

package trigger_bit_scaler_IO_pgk is


  type trigger_bit_scaler_writer_rec is record
    globals : globals_t;  
    reg_out : registert;  
    edgedetection_tb_out : optional_trigger_bit_t;  

  end record;

  constant trigger_bit_scaler_writer_rec_null : trigger_bit_scaler_writer_rec := ( 
    globals => globals_t_null,
    reg_out => registert_null,
    edgedetection_tb_out => optional_trigger_bit_t_null
  );
    


  type trigger_bit_scaler_reader_rec is record
    globals : globals_t;  
    edgedetection_tb_out : optional_trigger_bit_t;  

  end record;

  constant trigger_bit_scaler_reader_rec_null : trigger_bit_scaler_reader_rec := ( 
    globals => globals_t_null,
    edgedetection_tb_out => optional_trigger_bit_t_null
  );
    
end trigger_bit_scaler_IO_pgk;

package body trigger_bit_scaler_IO_pgk is

end package body trigger_bit_scaler_IO_pgk;

    