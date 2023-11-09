library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Pipe is

    Port ( 
           pos_def : STD_LOGIC_VECTOR(10 downto 0); -- default horizontale positie
           alt_random : STD_LOGIC_VECTOR(10 downto 0); -- random verticale positie
           CLK191Hz : in  STD_LOGIC; -- clock waarmee de pipe naar voor of achter beweegt
           reset    : in  STD_LOGIC; -- '1' als er een collision is gebeurt
           started  : in  STD_LOGIC; -- '1' als spel bezig is
           alt_pipe : out STD_LOGIC_VECTOR(10 downto 0); -- verticale positie
           pos_pipe : out STD_LOGIC_VECTOR(10 downto 0) -- horizontale positie
           );
end Pipe;

architecture Behavioral of Pipe is

  Signal pos : STD_LOGIC_VECTOR(10 downto 0);
  Signal alt : STD_LOGIC_VECTOR(10 downto 0):= alt_random;
  Signal random_alt_pipe : STD_LOGIC_VECTOR (10 downto 0);

  -- positie naar waar deze moet geteleporteerd worden als deze uit het scherm is
  Constant pos_bordure : STD_LOGIC_VECTOR(10 downto 0) := "01011000000";
begin

  -- beweeg de pipe
  clockActive: process(CLK191Hz, reset, started)
	begin
    if reset='1' or started='0' then
      pos <= pos_def; -- reset naar default positie
    else
      if rising_edge(CLK191Hz) then
        if pos > "00000000000" and started='1' then
          pos <= pos - 1; -- beweeg de pipe naar links
        else
          alt <= alt_random; -- geef de pipe een random hoogte
          pos <= pos_bordure; -- reset naar rechter border
        end if;
      else
        pos <= pos; -- blijf op dezelfde positie
      end if;
    end if;
	end process;

  alt_pipe <= alt; -- verticale positie is altijd zelfde
  pos_pipe <= pos;
end Behavioral;
