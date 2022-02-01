library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;


use work.roling_register_p.all;


entity register_single_bit_receiver is
    port (
        clk : in std_logic;
        rst : in std_logic;
        register_in : in std_logic;

        register_out : out registerT :=registerT_null
    );
end entity;


architecture rtl of register_single_bit_receiver is

    signal i_counter : integer := 0;
    signal i_buff : std_logic_vector(31 downto 0) := (others => '0');
    type state_t is (waitingForHeader, receivingData);
    signal i_state : state_t := waitingForHeader;
  
begin
    process(clk)
   
    variable buff : std_logic_vector(31 downto 0) := (others => '0');


    begin



        if rising_edge(clk) then



          register_out <= registerT_null;
          buff :=   register_in & buff(31 downto 1);
			    i_buff <= buff;
          i_counter <= i_counter + 1;

          case i_state is
            when waitingForHeader => 
              if buff = Register_signle_bit_header then 
                i_state <= receivingData;
                i_counter <= 0;
                buff := (others =>'0');
              end if;
            when receivingData =>
              if i_counter >= 31 then
                register_out.address <= buff(15 downto 0);
                register_out.value <= buff(31 downto 16);
                register_out.new_value <= '1';
                i_counter <= 0;
                i_state <= waitingForHeader;
                buff := (others =>'0');
              end if;


            when others =>
              i_state <= waitingForHeader;
          end case;  


     

        end if;

    end process;
    
end architecture;