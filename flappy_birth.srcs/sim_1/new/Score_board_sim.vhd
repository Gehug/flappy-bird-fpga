----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/26/2023 12:31:52 PM
-- Design Name: 
-- Module Name: Score_board_sim - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Score_board_sim is
--  Port ( );
end Score_board_sim;

architecture Behavioral of Score_board_sim is
component Scoreboard is
    Port ( 
    
        CLK191Hz  : in    STD_LOGIC;
        reset     : in   STD_LOGIC;
        between_pipe : in BOOLEAN;
        Seven_Segment : out STD_LOGIC_VECTOR (6 downto 0);
        an : out STD_LOGIC_VECTOR(3 downto 0);
        score_mode : in STD_LOGIC
        );
end component Scoreboard;

signal CLK191Hz: STD_LOGIC:='0';
signal reset: STD_LOGIC:='0';
signal between_pipe: BOOLEAN;
signal Seven_Segment: STD_LOGIC_VECTOR (6 downto 0):="1000000";
signal an : STD_LOGIC_VECTOR(3 downto 0);
signal score_mode: STD_LOGIC:='0';

signal current_score: INTEGER := 0;
signal high_score: INTEGER := 0;

begin
     UUT: Scoreboard 
     port map(CLK191Hz => CLK191Hz, reset=>reset, between_pipe=>between_pipe, Seven_Segment=>Seven_Segment, an=>an, score_mode=>score_mode);
 
    CLK191Hz <= not CLK191Hz after 5 ns; -- clock simulatie

 
 
     process -- simuleer wanneer er een punt gescoord word
     begin
      wait for 50 ns;
      between_pipe <= true;
      wait for 5 ns;
      between_pipe <= false;
      wait for 5 ns;
     end process;
     
     
     process -- simuleer dat speler het spel faalt
     begin 
        wait for 250 ns;
        reset <= '1';
        wait for 5 ns;
        reset <= '0';
        wait for 1000 ns;
     end process;
     
     process -- simuleer dat speler score modus veranderd van momentele score naar highscore
     begin 
        wait for 350 ns;
        score_mode <= '1'; -- verandere score modus naar high score
        wait for 1000 ns;
     end process;
 
     
    process(CLK191Hz) -- de score in INT formaat bekijken
    begin
    if rising_edge(CLK191Hz) then
      if reset = '1' then
        current_score <= 0; -- reset
      else
        if between_pipe then -- Als speler zich tussen de pipe bevind --> verhoog momentele score
          current_score <= current_score + 1; 
          if current_score + 1 > high_score then -- Als momentele score hoger is dan de current_score --> maak current_score de high_score
            high_score <= current_score + 1;
          end if;
        end if;
      end if;
    end if;
    end process;


end Behavioral;
