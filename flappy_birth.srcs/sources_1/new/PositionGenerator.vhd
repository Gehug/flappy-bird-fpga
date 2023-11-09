library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity PositionGenerator is
    Port ( min_alt_pipe : in STD_LOGIC_VECTOR (10 downto 0);
           max_alt_pipe : in STD_LOGIC_VECTOR (10 downto 0);
           random_alt_pipe : out STD_LOGIC_VECTOR (10 downto 0);
           clk : in STD_LOGIC;
           rst : in STD_LOGIC);
end PositionGenerator;

architecture Behavioral of PositionGenerator is

signal counter : STD_LOGIC_VECTOR (10 downto 0) := min_alt_pipe;
begin
    process(clk, rst)
    begin
        if rst = '1' then
            counter <= min_alt_pipe; -- restet counter naar minimale hoogte
        elsif rising_edge(clk) then
            if (counter = max_alt_pipe) then
                 counter <= min_alt_pipe;  -- restet counter naar minimale hoogte als max hoogte is bereikt
            else
                counter <= counter + 1; -- verhoog de counter met 1
            end if;
        end if;
    end process;
    
    random_alt_pipe <= counter;
end Behavioral;