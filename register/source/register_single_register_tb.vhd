library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;


use work.xgen_axistream_32.all;
use work.roling_register_p.all;

entity register_single_register_tb is
    port (
        clk : in std_logic;
        rst : in std_logic;
        RX_m2s : in   axisStream_32_m2s;
        RX_s2m : out  axisStream_32_s2m;
        register_debug_out : out std_logic ;

        register_out : out registerT
    );
end entity;



architecture rtl of register_single_register_tb is
  signal i_register : std_logic := '0';
begin
    register_debug_out  <= i_register;

    sender: entity work.register_single_bit_sender port map (

        clk => clk,
        rst => rst ,
        
        RX_m2s => RX_m2s,
        RX_s2m => RX_s2m,


        register_out => i_register
    
    );


    reader : entity work.register_single_bit_receiver port map (
        clk => clk ,
        rst => rst, 
        register_in => i_register,

        register_out => register_out

    );

end architecture;