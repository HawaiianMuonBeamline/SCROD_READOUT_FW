
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.CSV_UtilityPkg.all;


-- Start Include user packages --

-- End Include user packages --

package scaler_counter_IO_pgk is

  constant ADDR     : integer := 5;
  constant data     : integer := 32;
  type scaler_counter_writer_rec is record
    clk : std_logic;  
    rst : std_logic;  
    increment_channel : std_logic_vector ( addr-1 downto 0 );  
    increment_valid : std_logic;  
    cycle_over : std_logic;  
    b_increment : std_logic;  
    b_addrb : std_logic_vector ( addr-1 downto 0 );  
    b_doutb : std_logic_vector ( data-1 downto 0 );  

  end record;

  constant scaler_counter_writer_rec_null : scaler_counter_writer_rec := ( 
    clk => '0',
    rst => '0',
    increment_channel => ( others => '0' ),
    increment_valid => '0',
    cycle_over => '0',
    b_increment => '0',
    b_addrb => ( others => '0' ),
    b_doutb => ( others => '0' )
  );
    


  type scaler_counter_reader_rec is record
    clk : std_logic;  
    rst : std_logic;  
    increment_channel : std_logic_vector ( addr-1 downto 0 );  
    increment_valid : std_logic;  
    cycle_over : std_logic;  
    b_increment : std_logic;  

  end record;

  constant scaler_counter_reader_rec_null : scaler_counter_reader_rec := ( 
    clk => '0',
    rst => '0',
    increment_channel => ( others => '0' ),
    increment_valid => '0',
    cycle_over => '0',
    b_increment => '0'
  );
    
end scaler_counter_IO_pgk;

package body scaler_counter_IO_pgk is

end package body scaler_counter_IO_pgk;

    