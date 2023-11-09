library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;

entity Fly is
    Port ( CLK48Hz  :   in  STD_LOGIC;
           CLK_100MHz : in  STD_LOGIC;
           reset    :   in  STD_LOGIC;
           btn      :   in  STD_LOGIC;
           sensor   :   in  STD_LOGIC;
           input_mode   :   in  STD_LOGIC;
           started  :   out STD_LOGIC;
           altitude :   out STD_LOGIC_VECTOR(10 downto 0) );
end Fly;

architecture Behavioral of Fly is

-- FlyCounter component -> zorgt er voor dat wanneer de speler de knop/sensor indrukt/triggert dat de "fly" Signal voor 0.15 seconden '1' zal zijn.
component FlyCounter is
    Port ( clk : in STD_LOGIC;
           user_input : in STD_LOGIC;
           fly : out STD_LOGIC);
end component FlyCounter;

  Signal is_started : STD_LOGIC := '0'; -- '1' is het spel gestart

  -- Positie (verticale)
  Signal pos_alti : STD_LOGIC_VECTOR(10 downto 0) := "00011110000"; -- momentele verticale positie speler
  Constant pos_alti_def : STD_LOGIC_VECTOR(10 downto 0) := "00011110000"; -- default verticale positie speler  

  -- Snelheid
  Signal vit_alti : STD_LOGIC_VECTOR(10 downto 0) := "00000000000"; -- momentele snelheid
  Constant vit_alti_def : STD_LOGIC_VECTOR(10 downto 0) := "00000000000"; -- default snelheid
  Signal fly : STD_LOGIC := '0';
  Signal user_input : STD_LOGIC := '0';
begin
  
  
  -- FlyCounter
  FC: FlyCounter 
  port map(clk=>CLK_100MHz, user_input=>user_input, fly=>fly);
  
  -- Selecteer input type (sensor of knop)
  process(input_mode)
  begin
    if input_mode = '0' then
        user_input <= btn; -- gebruik knop als input
    else
        user_input <= sensor; -- gebruik sensor als input
    end if;
  end process;

  -- Beweeg speler (omhoog of omlaag)
  btnActive: process(CLK48Hz, reset)
	begin
    if reset='1' then -- als er een collision is gebeurt reset character naar default locatie en snelheid
      pos_alti <= pos_alti_def;
      vit_alti <= vit_alti_def;
      is_started <= '0';
    else
      if rising_edge(CLK48Hz) then
        -- Start beweging wanneer de game in gestart.
        if is_started='1' then
          pos_alti <= pos_alti + vit_alti; 
        else
          pos_alti <= pos_alti; 
        end if;

        -- als fly = 1 dan is de knop/sensor ingedrukt
        if fly='1' then
          vit_alti <= vit_alti - "00000000001"; -- vlieg omhoog
          is_started <= '1'; -- start de game
        else
          -- limiteer snelheid wanner deze te hoog is
          if vit_alti < "00000000100" then
            vit_alti <= vit_alti + "00000000001"; -- vlieg omlaag (zwaarte kracht)
          else
            vit_alti <= vit_alti; -- limiteer snelheid
          end if;
          is_started <= is_started;
        end if;
      else
        pos_alti <= pos_alti;
        vit_alti <= vit_alti;
        is_started <= is_started;
      end if;
    end if;
	end process;

  altitude <= pos_alti;
  started <= is_started;

end Behavioral;
