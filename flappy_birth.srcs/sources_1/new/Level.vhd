library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity Level is
    Port ( 
        level_mode : in STD_LOGIC;
        pipe_gap : out std_logic_vector(10 downto 0);
        started : in STD_LOGIC

    );
end Level;

architecture Behavioral of Level is

Signal level1: std_logic_vector(10 downto 0):= "00010000010";
Signal level2: std_logic_vector(10 downto 0):= "00001100000";

begin

process(level_mode) -- check het na welk skill level de user wilt gebruiken
begin
    if (level_mode = '0' and started = '0') then -- vergroot de pipe gap
        pipe_gap <= level1;
     elsif (level_mode = '1' and started = '0') then -- verklein de pipe gap
        pipe_gap <= level2;
    end if;
end process;


end Behavioral;
