
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.CSV_UtilityPkg.all;


-- Start Include user packages --
use work.klm_scint_globals.all;
use work.roling_register_p.all;
use work.xgen_axistream_32.all;

-- End Include user packages --

package mppc_hv_dac_wrapper_IO_pgk is


  type mppc_hv_dac_wrapper_writer_rec is record
    globals : globals_t;  
    rst : std_logic;  
    address : std_logic_vector ( 15 downto 0 );  
    value1 : std_logic_vector ( 15 downto 0 );  
    reg_out : registert;  
    busa_sck_dac : std_logic;  
    busa_din_dac : std_logic;  
    busb_sck_dac : std_logic;  
    busb_din_dac : std_logic;  
    tdc_cs_dac : std_logic_vector ( 9 downto 0 );  
    tdc_amux_s : std_logic_vector ( 3 downto 0 );  
    top_amux_s : std_logic_vector ( 3 downto 0 );  
    scl_mon : std_logic;  
    sda_mon : std_logic;  
    tdc_done : std_logic_vector ( 9 downto 0 );  
    tdc_mon_timing : std_logic_vector ( 9 downto 0 );  

  end record;

  constant mppc_hv_dac_wrapper_writer_rec_null : mppc_hv_dac_wrapper_writer_rec := ( 
    globals => globals_t_null,
    rst => '0',
    address => ( others => '0' ),
    value1 => ( others => '0' ),
    reg_out => registert_null,
    busa_sck_dac => '0',
    busa_din_dac => '0',
    busb_sck_dac => '0',
    busb_din_dac => '0',
    tdc_cs_dac => (others => '0'),
    tdc_amux_s => (others => '0'),
    top_amux_s => (others => '0'),
    scl_mon => '0',
    sda_mon => '0',
    tdc_done => (others => '0'),
    tdc_mon_timing => (others => '0')
  );
    


  type mppc_hv_dac_wrapper_reader_rec is record
    globals : globals_t;  
    rst : std_logic;  
    address : std_logic_vector ( 15 downto 0 );  
    value1 : std_logic_vector ( 15 downto 0 );  
    tdc_done : std_logic_vector ( 9 downto 0 );  
    tdc_mon_timing : std_logic_vector ( 9 downto 0 );  

  end record;

  constant mppc_hv_dac_wrapper_reader_rec_null : mppc_hv_dac_wrapper_reader_rec := ( 
    globals => globals_t_null,
    rst => '0',
    address => ( others => '0' ),
    value1 => ( others => '0' ),
    tdc_done => (others => '0'),
    tdc_mon_timing => (others => '0')
  );
    
end mppc_hv_dac_wrapper_IO_pgk;

package body mppc_hv_dac_wrapper_IO_pgk is

end package body mppc_hv_dac_wrapper_IO_pgk;

    