----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/26/2023 02:36:38 PM
-- Design Name: 
-- Module Name: fly_sim - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity fly_sim is
--  Port ( );
end fly_sim;

architecture Behavioral of fly_sim is

component Fly is
    Port ( CLK48Hz  :   in  STD_LOGIC;
           CLK_100MHz : in  STD_LOGIC;
           reset    :   in  STD_LOGIC;
           btn      :   in  STD_LOGIC;
           sensor   :   in  STD_LOGIC;
           input_mode   :   in  STD_LOGIC;
           started  :   out STD_LOGIC;
           altitude :   out STD_LOGIC_VECTOR(10 downto 0) );
end component  Fly;

signal CLK48Hz: STD_LOGIC:='1';  
signal CLK_100MHz: STD_LOGIC:='0';
signal reset: STD_LOGIC:='0';
signal btn: STD_LOGIC:='0';
signal sensor: STD_LOGIC:='0';
signal input_mode: STD_LOGIC:='0';
signal started: STD_LOGIC:='0';
signal altitude: STD_LOGIC_VECTOR(10 downto 0):="00011110000";

signal pos_alti: STD_LOGIC_VECTOR(10 downto 0):="00011110000";
signal vit_alti: STD_LOGIC_VECTOR(10 downto 0):="00000000000";

signal pos_alti_def: STD_LOGIC_VECTOR(10 downto 0):="00011110000";
signal vit_alti_def: STD_LOGIC_VECTOR(10 downto 0):="00000000000";

signal flyVar: STD_LOGIC:='0';

Signal altitude_ok : BOOLEAN;
Signal do_reset : STD_LOGIC;
signal is_started: STD_LOGIC:='0';

begin

--    UUT: Fly
--    port map (CLK48Hz=>CLK48Hz, CLK_100MHz=>CLK_100MHz, reset=>reset, btn=>btn, sensor=>sensor, input_mode=>input_mode, started=>started, altitude=>altitude);
    
    CLK48Hz <= not CLK48Hz after 5 ns; -- clock simulatie
    CLK_100MHz <= CLK48Hz;
    altitude_ok <= ("00000000000" < altitude) and (altitude < "00110010000"); -- als speler zich binnen de spelomgeving begint
    do_reset <= '0' when altitude_ok else '1'; -- als alle collision oke zijn, doe geen reset anders wel
    reset <= do_reset when rising_edge(CLK_100MHz);  -- syncroniseer de reset
    
    process
    begin
        wait for 100 ns;
        flyVar <= '1';
        wait for 10 ns;
        flyVar <= '0';
        wait for 1000 ns;
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
        if flyVar='1' then
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
