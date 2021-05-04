library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;

entity Scaler_counter is
  generic (
    DATA     : integer := 32;
    ADDR     : integer := 5
  );
  port (
    clk: in  std_logic;
    rst: in  std_logic;
    increment_channel : in  std_logic_vector(ADDR-1 downto 0) := (others => '0');
    increment_valid   : in  std_logic := '0';
    
    
    Cycle_over : in  std_logic := '0';
    
    
    B_increment : in  std_logic  :=  '0';
    B_addrb  : out  std_logic_vector(ADDR-1 downto 0) := (others => '0');
    B_doutb  : out std_logic_vector(DATA-1 downto 0) := (others => '0')
  );
end entity;

architecture rtl of Scaler_counter is

  type state_t is (
    idle,
    wating_for_loading_data_from_ram,
    writing_to_ram,
    
    
    cycleover_state0,
    cycleover_state1,
    cycleover_state2
  );
  signal i_state : state_t := idle;
  signal A_wea    :  std_logic := '0';
  signal A_addra  :  std_logic_vector(ADDR-1 downto 0) := (others => '0');
  signal A_dina   : std_logic_vector(DATA-1 downto 0):= (others => '0');
  -- Port B
  signal A_addrb  : std_logic_vector(ADDR-1 downto 0) := (others => '0');
  signal A_doutb  : std_logic_vector(DATA-1 downto 0) := (others => '0');
  
  
  signal B_wea    :  std_logic := '0';
  signal B_addra  :  std_logic_vector(ADDR-1 downto 0) := (others => '0');
  signal B_dina   : std_logic_vector(DATA-1 downto 0):= (others => '0');

  
  signal copy_index : std_logic_vector(ADDR-1 downto 0) := (others => '0');
  constant copy_index_max : std_logic_vector(ADDR-1 downto 0) := (others => '1');
  
    signal B_addrb1  : std_logic_vector(ADDR-1 downto 0) := (others => '0');
    signal B_addrb2  : std_logic_vector(ADDR-1 downto 0) := (others => '0');

begin
  
  i_bramA : entity work.bram_sdp_cc generic map (
    DATA     => DATA,
    ADDR     => ADDR
  ) port map (
    -- Port A
    clk   => clk,
    wea    => A_wea,
    addra =>  A_addra ,
    dina   => A_dina ,
    -- Port B
    addrb  => A_addrb,
    doutb  => A_doutb  
  );
  i_bramB : entity work.bram_sdp_cc generic map (
    DATA     => DATA,
    ADDR     => ADDR
  ) port map (
    -- Port A
    clk   => clk,
    wea    => B_wea,
    addra =>  B_addra ,
    dina   => B_dina ,
    -- Port B 
    addrb  => B_addrb1,
    doutb  => B_doutb  
  );
  
  process(clk) is
    
  begin
    if rising_edge(clk) then 
      A_wea <= '0';
      B_wea <= '0';
      case (i_state) is
        when idle =>
          if (increment_valid = '1') then 
            i_state <= wating_for_loading_data_from_ram;
            A_addrb <= increment_channel;
            
          end if;
        when wating_for_loading_data_from_ram =>
          i_state <= writing_to_ram;
        when writing_to_ram =>
          i_state <= idle;
          
          
          A_dina <=  STD_LOGIC_VECTOR( UNSIGNED(A_doutb) + 1);
          A_wea <= '1';
          A_addra <= A_addrb;
        
        when cycleover_state0 =>
          i_state <= cycleover_state1;
          A_addrb <= copy_index;
          
          
        when cycleover_state1 =>
          i_state <= cycleover_state2;
          
        when cycleover_state2 =>
          i_state <= cycleover_state0;
          
          A_wea   <= '1';
          A_addra  <= copy_index;
          A_dina  <= (others => '0');
 
          B_dina <= A_doutb;
          B_addra <= copy_index;
          B_wea <= '1';
          
          copy_index <= STD_LOGIC_VECTOR( UNSIGNED(copy_index) + 1);
          if copy_index = copy_index_max then
            i_state <= idle;
            copy_index <= (others => '0');
          end if;
          
        when others => 
          i_state <= idle;
      end case;
      
      if Cycle_over = '1' then
        i_state<= cycleover_state0;
        copy_index <= (others => '0');
      end if;
      
        --B_addrb  <= B_addrb2;
        B_addrb <= B_addrb1;
      if B_increment = '1' then
        B_addrb1 <= STD_LOGIC_VECTOR( UNSIGNED(B_addrb1) +1);
      end if;

    end if;
  end process;
  

end architecture;