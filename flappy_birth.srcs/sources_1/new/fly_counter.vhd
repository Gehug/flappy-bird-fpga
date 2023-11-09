library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity FlyCounter is
    Port ( clk : in STD_LOGIC;
           user_input : in STD_LOGIC;
           fly : out STD_LOGIC);
end FlyCounter;

architecture Behavioral of FlyCounter is
    Constant counter_threshold : integer := 15000000; -- 15000000 * (1 / 100MHz) = 0.15 seconden
    signal counter : integer range 0 to counter_threshold;  
    signal fly_state : STD_LOGIC := '0';
    signal user_input_prev : STD_LOGIC := '0';
    signal counter_enabled : BOOLEAN := FALSE;

begin
    process(clk)
    begin
        if rising_edge(clk) then
            if user_input = '1' and user_input_prev = '0' then -- Als er een user input is en de counter nog niet gestart is
                counter <= 1; -- reset de counter
                fly_state <= '1';  -- laat de bird vliegen
                counter_enabled <= TRUE; 
            elsif counter_enabled and counter < counter_threshold then -- als de counter is gestart en niet is afgelopen
                counter <= counter + 1;
                fly_state <= '1';  -- laat de bird vliegen
            else -- in rust stand
                counter <= 0; 
                fly_state <= '0';
                counter_enabled <= FALSE; 
            end if;
            
            user_input_prev <= user_input; 
        end if;
    end process;

    fly <= fly_state; -- map deze fly state aan de uitgang van de component

end Behavioral;
