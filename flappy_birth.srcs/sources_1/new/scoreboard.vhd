library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.all;

entity Scoreboard is
    Port ( 
    
        CLK191Hz  : in    STD_LOGIC;
        reset     : in   STD_LOGIC;
        between_pipe : in BOOLEAN;
        Seven_Segment : out STD_LOGIC_VECTOR (6 downto 0);
        an : out STD_LOGIC_VECTOR(3 downto 0);
        score_mode : in STD_LOGIC
        );
end Scoreboard;

architecture Behavioral of Scoreboard is

-- IntTo7segment_decoder component -> is verantwoordelijk om score (int) op het 7segment display te tonen
component IntTo7segment_decoder is Port ( 
    score_in : in INTEGER;
    Seven_Segment : out STD_LOGIC_VECTOR (6 downto 0)
);
end component;
    
    Signal current_score : INTEGER := 0; -- momentele score  -- disable (enkel voor simultatie)
    Signal high_score : INTEGER := 0; -- hoogste score behaald -- disable (enkel voor simultatie)
    Signal score_in : INTEGER := 0; -- score die naar de 7segment worden gestuurd
    signal segment_reg : STD_LOGIC_VECTOR(1 downto 0) := "00"; -- welke segment display moet worden aangesproken worden

begin

    units_7seg : IntTo7segment_decoder
    port map (
    score_in => score_in,
    Seven_Segment => Seven_Segment
    );
      
      
    -- Score optellen en resetten
    process(CLK191Hz) 
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
    
        
    process(CLK191Hz, reset) -- 0 tot 3 counter --> stuurt AN inputs aan van de 7segment display
    begin
      if reset = '1' then
          segment_reg <= "00";  -- Reset 
      elsif rising_edge(CLK191Hz) then
          if segment_reg = "11" then
              segment_reg <= "00";  -- Reset
          else
              segment_reg <= segment_reg + 1;  -- verhoog te counter
          end if;
      end if;
    end process;
    
    process(segment_reg) -- Multiplexing
    begin
       if score_mode = '0' then -- als score_mode gelijk is aan momentele score
           case (segment_reg) is
              when "00" =>
                 an <= "1110";
                 score_in <= current_score mod 10; -- stuur de eenheden van de current score naar laatste 7segement display
              when "01" =>
                 an <= "1101";
                 score_in <= (current_score / 10) mod 10; -- stuur de tientallen van de current score naar meeste voorlaaste 7segement display
              when "10" =>
                 an <= "1011";
                 score_in <= (current_score / 100) mod 10; -- stuur de hondertallen van de current score naar meeste 2de 7segement display
              when "11" =>
                 an <= "0111";
                 score_in <= 0; -- stuur altijd een 0 naar de eerste 7segement display
              when others =>
                 an <= "1111"; -- stop alle 7segement displays als de register een ander waarde heeft dan 0 1 2 3 (binaire)
           end case;
         else -- als score_mode gelijk is aan hoogste score
            case (segment_reg) is
              when "00" =>
                 an <= "1110";
                 score_in <= high_score mod 10; -- stuur de eenheden van de high score naar laatste 7segement display
              when "01" =>
                 an <= "1101";
                 score_in <= (high_score / 10) mod 10; -- stuur de tientallen van de high score naar meeste voorlaaste 7segement display
              when "10" =>
                 an <= "1011";
                 score_in <= (high_score / 100) mod 10; -- stuur de hondertallen van de high score naar meeste 2de 7segement display
              when "11" =>
                 an <= "0111";
                 score_in <= 0; -- stuur altijd een 0 naar de eerste 7segement display
              when others =>
                 an <= "1111"; -- stop alle 7segement displays als de register een ander waarde heeft dan 0 1 2 3 (binaire)
           end case;
         end if;
         
    end process;
    
end Behavioral;
