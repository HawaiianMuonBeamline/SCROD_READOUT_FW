library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;

package roling_register_p is

  type registerT is record 
    address : std_logic_vector(15 downto 0);
    value   : std_logic_vector(15 downto 0);
    new_value : std_logic;
  end record;

  constant registerT_null : registerT := (
    address => (others => '0'),
    value   => (others => '0'),
    new_value => '0'
  );

  type registerT_a is array (natural range <>) of registerT;

 -- procedure read_data(self : in registerT; value :out  STD_LOGIC_VECTOR; addr :in integer);


  procedure read_data_s(self : in registerT; signal value :out  STD_LOGIC_VECTOR ; addr :in integer);

  
  procedure timeWindow(signal OutData : inout std_logic; timeCounter : STD_LOGIC_VECTOR; StartTime : STD_LOGIC_VECTOR; EndTime : STD_LOGIC_VECTOR);
  procedure timeWindow(signal OutData : inout std_logic_vector; timeCounter : STD_LOGIC_VECTOR; StartTime : STD_LOGIC_VECTOR; EndTime : STD_LOGIC_VECTOR; InData : in std_logic_vector);
  
  
  type register_val_t is record
    Global_reset    : integer; 
    Global_update   : integer; 
    DAC_LOAD_PERIOD : integer;
    DAC_LATCH_PERIOD_PERIOD   : integer;
    DAC_Wait                  : integer;
    DAC_full_reset           : integer;
    
    Shift_register_clk_High   : integer;
    Shift_register_clk_Period : integer;
    shift_register_clk_start  : integer;
    shift_register_clk_stop   : integer;
    shift_register_select_start :integer;
    shift_register_select_stop : integer;
    shift_register_select_done : integer;
    
    REGCLR : integer;

    WR_enable_min       :  integer;
    WR_enable_max       :  integer;
    
    WR_ADDRCLR_min      :  integer;
    WR_ADDRCLR_max      :  integer;
    WR_RolingCounterMax : integer;
    wr_always_brake     : integer;
    wr_soft_trigger : integer;

    
    RD_ENA_min :  integer;
    RD_ENA_max :  integer; 
    
    RD_ROWSEL_S_min :integer;
    RD_ROWSEL_S_max :integer;
    
    RD_COLSEL_S_min :  integer;
    RD_COLSEL_S_max :  integer; 
    
    CLR_min :  integer;
    CLR_max :  integer;  
    
    RAMP_min : integer;
    RAMP_max : integer;
    
    RolingCounterMax : integer;
    willkSkip         : integer;
    
    serielOutConverter_invert_bit_order : integer;
    serielOutConverter_notMask : integer;
    pedestal_channel: integer;
    pedestal_row: integer;
    pedestal_column: integer;
    pedestal_asic   : integer;
    pedestal_useMem : integer;
    pedestal_start : integer;

    trigger_mask   : integer;
    trigger_switch : integer;
    trigger_maxCount : integer;
    trigger_reset    : integer;
    MppcAdcAsicN   : integer;
    MppcAdcChanN : integer;
    MppcAdcData  : integer;
    ADCdebug   : integer;
  end record;

  constant register_val : register_val_t := (
    Global_reset                 => 12345,
    Global_update                => 12346,
    DAC_LOAD_PERIOD              => 100,
    DAC_LATCH_PERIOD_PERIOD      => 101,
    DAC_Wait                     => 102,
    DAC_full_reset               => 103,
    
    Shift_register_clk_High      => 120,
    Shift_register_clk_Period    => 121,
    shift_register_clk_start     => 122,
    shift_register_clk_stop      => 123,
    shift_register_select_start  => 124,
    shift_register_select_stop   => 125,
    shift_register_select_done   => 126,
    
    REGCLR                       => 149,
    wr_soft_trigger              => 146,
    wr_always_brake              => 147,
    WR_RolingCounterMax          => 148,
    WR_enable_min                => 150,
    WR_enable_max                => 151,

    WR_ADDRCLR_min               => 152,
    WR_ADDRCLR_max               => 153,

    RD_ENA_min                   => 154,
    RD_ENA_max                   => 155,

    RD_ROWSEL_S_min             => 156,
    RD_ROWSEL_S_max             => 157,

    RD_COLSEL_S_min             => 158,
    RD_COLSEL_S_max             => 159 ,

    CLR_min                     => 160,
    CLR_max                     => 161,
    
    RAMP_min                    => 162,
    RAMP_max                    => 163,
    
    RolingCounterMax            => 164,
    willkSkip                   => 165,
    
    serielOutConverter_invert_bit_order => 170,
    serielOutConverter_notMask => 171,
    trigger_mask => 4180,
    trigger_switch => 4181,
    trigger_maxCount => 4182,
    trigger_reset    => 4183,
    
    pedestal_channel => 190,
    pedestal_row   => 191,
    pedestal_column => 192,
    pedestal_asic   => 193,
    pedestal_useMem => 194,
    pedestal_start             => 200,
    
    MppcAdcAsicN  =>  4001,   -- REGISTER 60 in old firmware
    MppcAdcChanN  =>  4002,
    MppcAdcData   =>  4003,
    ADCdebug   =>  4004
  );

  
  
  constant gRegisterDelay: integer := 10;
end package;

package body roling_register_p is
  --procedure read_data(self : in registerT; value :out  std_logic_vector ; addr :in integer) is 
  --  variable m1 : integer := 0;
  --  variable m2 : integer := 0;
  --  variable m : integer := 0;
  --begin 
  --  m1 := value'length;
  --  m2 := self.value'length;

  --  if (m1 < m2) then 
  --    m := m1;
  --  else 
  --    m := m2;
  --  end if;


  --  if to_integer(signed(self.address)) = addr then
  --    value(   m - 1 downto 0) := self.value(  m - 1 downto 0);
  --  end if;
  --end procedure;


  procedure read_data_s(self : in registerT;signal value :out  std_logic_vector ; addr :in integer) is 
    variable m1 : integer := 0;
    variable m2 : integer := 0;
    variable m : integer := 0;
  begin
    m1 := value'length;
    m2 := self.value'length;

    if (m1 < m2) then 
      m := m1;
    else 
      m := m2;
    end if;

    if to_integer(signed(self.address)) = addr then
      value(m - 1 downto 0) <= self.value(  m - 1 downto 0);
    end if; 
  end procedure;

  procedure timeWindow(signal OutData : inout std_logic; timeCounter : STD_LOGIC_VECTOR; StartTime : STD_LOGIC_VECTOR; EndTime : STD_LOGIC_VECTOR) is
    
  begin 
    OutData<='0';
    if StartTime < timeCounter and timeCounter< EndTime then
      OutData <= '1';
    end if;
    
  end procedure;
  
  procedure timeWindow(signal OutData : inout std_logic_vector; timeCounter : STD_LOGIC_VECTOR; StartTime : STD_LOGIC_VECTOR; EndTime : STD_LOGIC_VECTOR; InData : in std_logic_vector) is
  begin 
    OutData <= (others => '0');
    if StartTime < timeCounter  and timeCounter < EndTime then
      OutData <= InData;
    end if;
  end procedure;
end package body;