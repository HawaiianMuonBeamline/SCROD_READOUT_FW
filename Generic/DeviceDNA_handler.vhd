library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;
  use ieee.std_logic_unsigned.all;

  use work.roling_register_p.all;
  use work.klm_scint_globals.all;
  use work.UtilityPkg.all;

entity DeviceDNA_handler is
  port (
    globals :  in  globals_t := globals_t_null;
    reg_out :  out registerT :=  registerT_null;
    dnaOut  :  out slv(63 downto 0);
    Data_buffer_out : out Word16Array( 0 to 3) := (others => (others =>'0'))
  );
end entity;

architecture rtl of DeviceDNA_handler is
  signal i_dnaOut    : STD_LOGIC_VECTOR(63 downto 0);
  signal Data_buffer : Word16Array( 0 to 5) := (others => (others =>'0'));
begin
  
  
  dna : entity work.DeviceDna port map( 
    clk   => globals.clk,
    rst   => globals.rst,
    -- Parallel interface for current ticks value
    dnaOut   => i_dnaOut
  );
  
  Data_buffer(0) <=  x"ABCD";
  Data_buffer(1) <= i_dnaOut(15 downto 0);
  Data_buffer(2) <= i_dnaOut(31 downto 16);
  Data_buffer(3) <= i_dnaOut(47 downto 32);
  Data_buffer(4) <= i_dnaOut(63 downto 48);
  Data_buffer(5) <=  x"DCBA";
  dnaOut<= i_dnaOut;
  Data_buffer_out(0) <= Data_buffer(1);
  Data_buffer_out(1) <= Data_buffer(2);
  Data_buffer_out(2) <= Data_buffer(3);
  Data_buffer_out(3) <= Data_buffer(4);
  
  process(globals.clk) is 
    variable counter: STD_LOGIC_VECTOR(7 downto 0):= (others => '0');
  begin
    if rising_edge(globals.clk) then
      reg_out.address <= x"AA" & counter ;    
      reg_out.value   <= Data_buffer( conv_integer( counter ));    
      counter := counter+1;
      if counter > Data_buffer'length -1 then
        counter := (others => '0');
      end if;
    end if;
  end process;
end architecture;