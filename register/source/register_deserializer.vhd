library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use work.roling_register_p.all;


entity register_deserializer is
  port (
      clk : in std_logic;

      register_serial_in : in std_logic;

      register_out : out registerT


  );
end entity;


architecture rtl of register_deserializer is
  
    signal i_data_buffer : std_logic_vector(32 downto 0) := (others => '0');

    signal i_counter : integer := 0;
begin

    process(clk) is 
    begin
        if rising_edge(clk) then

            i_counter <= i_counter + 1;
            i_data_buffer(32 downto 1) <= i_data_buffer(31 downto 0);
            i_data_buffer(0) <= register_serial_in;

            if i_counter = 33 then
                i_counter <= 0;
                register_out.address <= i_data_buffer(31 downto 16);
                register_out.value <= i_data_buffer(15 downto 0);
                register_out.new_value <= i_data_buffer(32);
            end if;



        end if;
    end process;


end architecture;