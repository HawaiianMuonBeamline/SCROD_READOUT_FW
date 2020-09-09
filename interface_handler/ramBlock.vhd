library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;

entity ramBlock is
  generic (
    DATA     : integer := 16;
    ADDR     : integer := 10;
    InputDelay : integer := 2;
    ouputDeley : integer := 2
  );
  port (
    -- Port A
    clk   : in  std_logic;
    wea    : in  std_logic;
    addra  : in  std_logic_vector(ADDR-1 downto 0);
    dina   : in  std_logic_vector(DATA-1 downto 0);
    -- Port B
    addrb  : in  std_logic_vector(ADDR-1 downto 0);
    doutb  : out std_logic_vector(DATA-1 downto 0)
  );
end ramBlock;

architecture rtl of ramBlock is
  
  type In_buffer_type is record
    wea    : std_logic;
    addra  : std_logic_vector(ADDR-1 downto 0);
    dina   : std_logic_vector(DATA-1 downto 0);
    addrb  : std_logic_vector(ADDR-1 downto 0);
  end record;
 
type in_buffer_type_a is array ( InputDelay -1 downto 0 ) of In_buffer_type;

signal inBuff : in_buffer_type_a;

type out_buffer_type_a is array ( ouputDeley -1 downto 0 ) of std_logic_vector(DATA-1 downto 0);

signal outBuff : out_buffer_type_a;


begin
  inBuff(inBuff'length -1).wea <= wea;
  inBuff(inBuff'length -1).addra <= addra;
  inBuff(inBuff'length -1).dina <= dina;
  inBuff(inBuff'length -1).addrb <= addrb;
  
  doutb<= outBuff(0);
  
  inPipe : process(clk) is
    
  begin
    if rising_edge(clk) then
      for i in 1 to inBuff'length -1 loop
        inBuff(i -1) <=  inBuff(i);
      end loop;
    end if;
  end process;
  
  
  outPipe : process(clk) is

  begin
    if rising_edge(clk) then
      for i in 1 to outBuff'length -1 loop
        outBuff(i -1) <=  outBuff(i);
      end loop;
    end if;
  end process;
  
  mem : entity work.bram_sdp_cc generic map(
      DATA     => DATA,
      ADDR    => ADDR
    ) port  map (
      -- Port A
      clk   => clk,
      wea   =>   inBuff(0).wea,
      addra  =>  inBuff(0).addra,
      dina   =>  inBuff(0).dina,
      -- Port B
      addrb   =>  inBuff(0).addrb,
      doutb   => outBuff(outBuff'length - 1)
    );
  
  
end architecture;