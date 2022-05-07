library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;


use work.xgen_axistream_32.all;
use work.roling_register_p.all;

entity register_single_bit_sender is
    port (
        clk : in std_logic;
        rst : in std_logic;
        
        RX_m2s : in   axisStream_32_m2s;
        RX_s2m : out  axisStream_32_s2m;

        register_out : out std_logic:='0'

    );
end entity;


architecture rtl of register_single_bit_sender is
    signal i_counter : integer := 0;
    type state_t is (idle, sendHeader, sendData);
    signal i_state : state_t := idle;

  
begin


    process(clk) is
    variable rx: axisStream_32_slave := axisStream_32_slave_null;
    variable buff : std_logic_vector(31 downto 0) := (others =>'0');
    
    begin

        if rising_edge(clk) then

            pull(rx, RX_m2s);  
            i_counter <= i_counter + 1;

            case i_state is 
                when idle =>
                    if isReceivingData(rx) then                    
                        read_data(rx, buff);
                        i_counter <= 0;

                        i_state <= sendHeader;

                    end if;

                when sendHeader =>
                    register_out <= Register_signle_bit_header(i_counter); 
                    if i_counter >= 31 then
                        i_state <= sendData;
                        i_counter <= 0;
                    end if;

                when sendData =>
                    register_out <= buff(i_counter); 
                    if i_counter >= 31 then
                        i_state <= idle;
                        i_counter <= 0;
                    end if;

                when others =>
                    i_state <= idle;
            end case;

            push (rx , RX_s2m);  

        end if;
    end process;


end architecture;
