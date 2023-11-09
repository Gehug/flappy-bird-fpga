library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.all;


entity Collision is
    Port ( CLK191Hz  : in    STD_LOGIC;
           altitude  : in    STD_LOGIC_VECTOR(10 downto 0);
           alt_pipe1 : in    STD_LOGIC_VECTOR(10 downto 0);
           pos_pipe1 : in    STD_LOGIC_VECTOR(10 downto 0);
           alt_pipe2 : in    STD_LOGIC_VECTOR(10 downto 0);
           pos_pipe2 : in    STD_LOGIC_VECTOR(10 downto 0);
           reset     : out   STD_LOGIC;
           between_pipe : out BOOLEAN:=false;
           pipe_gap : in STD_LOGIC_VECTOR (10 downto 0)
           );
end Collision;

architecture Behavioral of Collision is

  Signal do_reset : STD_LOGIC;

  -- Altitude collision
  Signal altitude_ok : BOOLEAN;
  Constant max_altitude : STD_LOGIC_VECTOR(10 downto 0) := "00110010000";
  Constant min_altitude : STD_LOGIC_VECTOR(10 downto 0) := "00000000000";

  -- Pipe collision
  Signal pipe1_ok : BOOLEAN;
  Signal pipe2_ok : BOOLEAN;
  Constant bird_X : STD_LOGIC_VECTOR (10 downto 0) := "00001000000";
  Constant bird_size : STD_LOGIC_VECTOR (10 downto 0) := "00000100000";
  Constant pipe_width : STD_LOGIC_VECTOR (10 downto 0) := "00001000000";



begin
   
  altitude_ok <= (min_altitude < altitude) and (altitude < max_altitude); -- als speler zich binnen de spelomgeving begint
  pipe1_ok <= (pos_pipe1 < bird_X) or 
              (pos_pipe1 > bird_X + bird_size + pipe_width) or 
              ((altitude > alt_pipe1) and
               (altitude + bird_size < alt_pipe1 + pipe_gap)); -- als speler postitie niet overlapt met pipe1
  pipe2_ok <= (pos_pipe2 < bird_X) or 
              (pos_pipe2 > bird_X + bird_size + pipe_width) or 
              ((altitude > alt_pipe2) and
               (altitude + bird_size < alt_pipe2 + pipe_gap)); -- als speler postitie niet overlapt met pipe2

  do_reset <= '0' when altitude_ok and pipe1_ok and pipe2_ok else '1'; -- als alle collision oke zijn, doe geen reset anders wel
  reset <= do_reset when rising_edge(CLK191Hz);  -- syncroniseer de reset
  
  -- Check of de speler zich tussen een pipe bevind (gebruikt door scoreboard)
  process(CLK191Hz)
  begin
    if rising_edge(CLK191Hz) then
        between_pipe <= (pos_pipe1 = bird_X) or (pos_pipe2 = bird_X);
    end if;
  end process;
 

end Behavioral;
