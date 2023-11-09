library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Game is
  Port (
    -- Clock
    CLK_100MHz : in    STD_LOGIC;

    -- VGA display
    HS        : out   STD_LOGIC;
    VS        : out   STD_LOGIC;
    color     : out   STD_LOGIC_VECTOR (7 downto 0);

    -- Inputs
    btn        : in    STD_LOGIC;
    sensor     : in    STD_LOGIC;
    score_mode : in    STD_LOGIC;
    input_mode : in    STD_LOGIC;
    level_mode : in    STD_LOGIC;
    
    -- Outputs
    Seven_Segment : out STD_LOGIC_VECTOR (6 downto 0);
    an : out STD_LOGIC_VECTOR(3 downto 0)
  );
end Game;

architecture Behavioral of Game is

  -- Clock divider at 25MHz
  Signal clk_div: STD_LOGIC_VECTOR (27 downto 0);
  alias CLK25MHz: STD_LOGIC is clk_div(1); -- VGA clock (100MHz / 4)
  alias CLK191Hz: STD_LOGIC is clk_div(18); -- Pipe scrolling en collision clock (100MHz / 520)
  alias CLK48Hz: STD_LOGIC is clk_div(20); -- Fly clock (100MHz / 2083)
  alias CLK_BG: STD_LOGIC_VECTOR (6 downto 0) is clk_div(27 downto 21); -- Background animation clock (100MHz / 160)
  alias CLK333Hz : STD_LOGIC is clk_div(23); -- 333 Hz clock (100MHz / 300300)
  alias CLK500Hz : STD_LOGIC is clk_div(19); -- 500 Hz clock (100MHz / 200000)

   
  -- VGA display component -> regelt alle pixel die naar scherm gestuurd worden
  component vga_controller_640_60
    Port (
      rst       : in    STD_LOGIC;
      pixel_clk : in    STD_LOGIC;
      HS        : out   STD_LOGIC; 
      VS        : out   STD_LOGIC; 
      blank     : out   STD_LOGIC; 
      hcount    : out   STD_LOGIC_VECTOR (10 downto 0); 
      vcount    : out   STD_LOGIC_VECTOR (10 downto 0)
    );
  end component ;
  Signal blank:  STD_LOGIC;
  Signal hcount: STD_LOGIC_VECTOR (10 downto 0);
  Signal vcount: STD_LOGIC_VECTOR (10 downto 0);

  -- Display component -> regelt alle sprites en symbolen en kleuren hiervan en ook dat die zich op de juiste positie bevinden op het scherm
  component Display
    Port (
      CLK_BG    : in   STD_LOGIC_VECTOR (6 downto 0);
      blank     : in   STD_LOGIC;
      hcount    : in   STD_LOGIC_VECTOR (10 downto 0);
      vcount    : in   STD_LOGIC_VECTOR (10 downto 0);
      altitude  : in   STD_LOGIC_VECTOR (10 downto 0);
      pos_pipe1 : in   STD_LOGIC_VECTOR (10 downto 0);
      alt_pipe1 : in   STD_LOGIC_VECTOR (10 downto 0);
      pos_pipe2 : in   STD_LOGIC_VECTOR (10 downto 0);
      alt_pipe2 : in   STD_LOGIC_VECTOR (10 downto 0);
      pipe_gap : in STD_LOGIC_VECTOR (10 downto 0);
      color     : out   STD_LOGIC_VECTOR (7 downto 0)
    );
  end component ;

  -- Fly component -> zal speler omhoog en naar beneden bewegen (afhankelijk van de user input)
  component Fly
    PORT (
      CLK48Hz  : in    STD_LOGIC;
      CLK_100MHz : in STD_LOGIC;
      reset    : in    STD_LOGIC;
      btn      : in    STD_LOGIC;
      sensor   :   in  STD_LOGIC;
      input_mode   :   in  STD_LOGIC;
      started  : out   STD_LOGIC;
      altitude : out   STD_LOGIC_VECTOR(10 downto 0)
    );
  END component ;
  Signal altitude : STD_LOGIC_VECTOR(10 downto 0); -- (momentele) hoogte van de speler
  Signal started : STD_LOGIC; -- '1' als spel is gestart, '0' als spel is gestopt

  -- Pipes component-> zal de pipe naar vooren bewegen en herlokeren wanneer deze uit beeld is gegaan
  component Pipe
    Port (
      pos_def : STD_LOGIC_VECTOR(10 downto 0); -- default horizontale positie
      alt_random : STD_LOGIC_VECTOR(10 downto 0); -- random hoogte
      CLK191Hz : in    STD_LOGIC;
      reset    : in    STD_LOGIC;
      started  : in    STD_LOGIC;
      alt_pipe : out   STD_LOGIC_VECTOR(10 downto 0);
      pos_pipe : out   STD_LOGIC_VECTOR(10 downto 0)
    );
  END component ;
  Signal pos_pipe1 : STD_LOGIC_VECTOR(10 downto 0); -- (momentele) horizontale positie van de pipe1
  Signal alt_pipe1 : STD_LOGIC_VECTOR(10 downto 0); -- (momentele) hoogte van de pipe1
  
  Signal pos_pipe2 : STD_LOGIC_VECTOR(10 downto 0); 
  Signal alt_pipe2 : STD_LOGIC_VECTOR(10 downto 0);

  -- Collision component --> is verandwoordelijke voor de detectie van de speler die een pipe raakt of een speler die het speelveld verlaat
  component Collision
    PORT ( CLK191Hz  : in    STD_LOGIC;
           altitude  : in    STD_LOGIC_VECTOR(10 downto 0);
           alt_pipe1 : in    STD_LOGIC_VECTOR(10 downto 0);
           pos_pipe1 : in    STD_LOGIC_VECTOR(10 downto 0);
           alt_pipe2 : in    STD_LOGIC_VECTOR(10 downto 0);
           pos_pipe2 : in    STD_LOGIC_VECTOR(10 downto 0);
           reset     : out   STD_LOGIC;
           between_pipe : out BOOLEAN;
           pipe_gap : in STD_LOGIC_VECTOR (10 downto 0)
    );
  END component ;
  
  -- Scoreboard component --> is verandwoordelijk voor score van de speler te tonen op de 7segmenten display  
  component Scoreboard is 
    Port ( CLK191Hz  : in    STD_LOGIC;
           reset     : in   STD_LOGIC;
           between_pipe : in BOOLEAN;
           Seven_Segment : out STD_LOGIC_VECTOR (6 downto 0);
           an : out STD_LOGIC_VECTOR(3 downto 0);
           score_mode : in STD_LOGIC
           );
  end component Scoreboard;
  
  -- Level component --> is verandwoordelijk om het spel aan te passen naar gekozen moeilijkheidsgraad van de speler
  component Level is
        Port ( 
            level_mode : in STD_LOGIC;
            pipe_gap : out std_logic_vector(10 downto 0);
            started : in STD_LOGIC
        );
   end component Level;
   
   -- PositionGenerator component -> zorgt voor een random verticale posisitie tussen min_alt_pipe en max_alt_pipe
   component PositionGenerator is 
    Port ( min_alt_pipe : in STD_LOGIC_VECTOR (10 downto 0);
           max_alt_pipe : in STD_LOGIC_VECTOR (10 downto 0);
           random_alt_pipe : out STD_LOGIC_VECTOR (10 downto 0);
           clk : in STD_LOGIC;
           rst : in STD_LOGIC
        );
end component PositionGenerator;
  
  Signal reset : STD_LOGIC; -- reset='1' als er een collision is gebeurt (speler tegen pipe gebots of speler uit het speelveld gegaan)
  Signal between_pipe : BOOLEAN; -- Als speler zich (verticaal) tussen 2 pipes bevind
  Signal pipe_gap: STD_LOGIC_VECTOR(10 downto 0):= "00001100000"; -- de afstand tussen de 2 pipes (verticale afstand)
  signal random_alt_pipe1: std_logic_vector(10 downto 0):="00100001110"; -- random positie verticale van pipe1
  signal random_alt_pipe2: std_logic_vector(10 downto 0):="00010010110"; -- random positie verticale van pipe2
  

begin

  -- Clock divider at 50MHz
  clk_div <= clk_div + 1 when rising_edge(CLK_100MHz);

  -- VGA display
  VM : vga_controller_640_60
  port map (
    rst => '0',  -- keep reset off
    pixel_clk => CLK25MHz,
    HS => HS,
    VS => VS,
    blank => blank,
    hcount => hcount,
    vcount => vcount
  );

  -- Display generation
  DM : Display
  port map (
    CLK_BG => CLK_BG,
    blank => blank,
    hcount => hcount,
    vcount => vcount,
    altitude => altitude,
    pos_pipe1 => pos_pipe1,
    alt_pipe1 => alt_pipe1,
    pos_pipe2 => pos_pipe2,
    alt_pipe2 => alt_pipe2,
    pipe_gap => pipe_gap,
    color => color
  );

  -- Fly
  FM : Fly
  port map (
    CLK48Hz => CLK48Hz,
    CLK_100MHz=> CLK_100MHz,
    reset => reset,
    btn => btn,
    sensor => sensor,
    input_mode => input_mode,
    started => started,
    altitude => altitude
  );

  -- Pipe 1
  PM1 : Pipe
  port map (
    pos_def => "01011000000", -- (640+64)
    alt_random => random_alt_pipe1,
    CLK191Hz => CLK191Hz,
    reset => reset,
    started => started,
    pos_pipe => pos_pipe1,
    alt_pipe => alt_pipe1
  );

  -- Pipe 2
  PM2 : Pipe
  port map (
    pos_def => "00101100000", -- (640+64)/2
    alt_random => random_alt_pipe2,
    CLK191Hz => CLK191Hz,
    reset => reset,
    started => started,
    pos_pipe => pos_pipe2,
    alt_pipe => alt_pipe2
  );
 

  -- Collision
  CM : Collision
  port map (
    CLK191Hz => CLK191Hz,
    altitude => altitude,
    pos_pipe1 => pos_pipe1,
    alt_pipe1 => alt_pipe1,
    pos_pipe2 => pos_pipe2,
    alt_pipe2 => alt_pipe2,
    reset => reset,
    between_pipe => between_pipe, 
    pipe_gap => pipe_gap
    );
  
   -- Scoreboard
  SB : Scoreboard
  port map (
    CLK191Hz => CLK191Hz,
    reset => reset,
    between_pipe => between_pipe,
    Seven_Segment => Seven_Segment,
    an => an,
    score_mode => score_mode
  );
  
  -- Level 
  LV: level
  port map(
    pipe_gap => pipe_gap,
    level_mode => level_mode,
    started => started
  );
  
  -- PositionGenerator 1
  PG1: PositionGenerator
  port map(
    min_alt_pipe=>"00010010110", 
    max_alt_pipe=>"00100001110", 
    random_alt_pipe=>random_alt_pipe1, 
    clk=>CLK500Hz, 
    rst=>'0'
  );
  
  -- PositionGenerator 2
  PG2: PositionGenerator
  port map(
    min_alt_pipe=>"00010010110", 
    max_alt_pipe=>"00100001110", 
    random_alt_pipe=>random_alt_pipe2, 
    clk=>CLK333Hz, 
    rst=>'0'
  );
     
end Behavioral;
