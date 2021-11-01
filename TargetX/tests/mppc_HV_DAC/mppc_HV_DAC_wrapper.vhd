
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.STD_LOGIC_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.klm_scint_globals.all;
use work.roling_register_p.all;
use work.xgen_axistream_32.all;

entity mppc_HV_DAC_wrapper is
    port (
      globals :  in globals_t := globals_t_null;
      rst     : in std_logic := '0';
      address : in std_logic_vector(15 downto 0) := (others => '0');
      value1   : in   std_logic_vector(15 downto 0):= (others => '0');
      reg_out         : out registerT := registerT_null;  
  
      -- MPPC HV DAC
      BUSA_SCK_DAC           : out std_logic;
      BUSA_DIN_DAC           : out std_logic;
      BUSB_SCK_DAC           : out std_logic;
      BUSB_DIN_DAC           : out std_logic;
      --
      --target_tb16              : in std_logic_vector(1 to TDC_NUM_CHAN);
  
      TDC_CS_DAC               : out std_logic_vector(9 downto 0); 
  
      TDC_AMUX_S               : out std_logic_vector(3 downto 0); -- what the difference between these two?
      TOP_AMUX_S               : out std_logic_vector(3 downto 0); -- TODO: check schematic
  
      --- MPPC ADC
      SCL_MON                  : out STD_LOGIC;
      SDA_MON                  : out STD_LOGIC;
  
  
      ---
  
      --TMP                      : out std_logic_vector(31 downto 0);
  
      TDC_DONE                 : in STD_LOGIC_VECTOR(9 downto 0); -- move to readout signals
      TDC_MON_TIMING           : in STD_LOGIC_VECTOR(9 downto 0)  -- add the ref to the programming of the TX chip
  
  
    );
end entity;



architecture rtl of mppc_HV_DAC_wrapper is
    signal i_globals : globals_t := globals_t_null;
    signal i_reg : registerT;
    signal i_reg2 : registerT;

    procedure my_test(signal in_reg : inout registerT; o_reg : inout registerT) is
    begin 
      o_reg := in_reg;
    end procedure;
    procedure my_test_11(signal in_reg : inout registerT; signal o_reg : inout registerT) is
    begin 
      o_reg <= in_reg;
    end procedure;
begin



    i_globals.clk <= globals.clk;
    i_globals.rst <= rst;
    i_globals.reg.address <= address;
    i_globals.reg.value <= value1;

    reg_out.address <= i_globals.reg.address;
    reg_out.value <= i_globals.reg.value;
    dut : entity work.mppc_HV_DAC 
        port map( 
          globals => i_globals,
          reg_out => open,
      
          -- MPPC HV DAC
          BUSA_SCK_DAC => BUSA_SCK_DAC,
          BUSA_DIN_DAC => BUSA_DIN_DAC,
          BUSB_SCK_DAC => BUSB_SCK_DAC,
          BUSB_DIN_DAC => BUSB_DIN_DAC,
          --
          
      
          TDC_CS_DAC          =>TDC_CS_DAC          ,
      
          TDC_AMUX_S          =>TDC_AMUX_S          ,
          TOP_AMUX_S          =>TOP_AMUX_S          ,
      
          
          SCL_MON             =>SCL_MON             ,
          SDA_MON             =>SDA_MON             ,
      
      
          
      
          
      
          TDC_DONE            =>TDC_DONE            ,
          TDC_MON_TIMING      =>TDC_MON_TIMING      
      
      
        );

end architecture;