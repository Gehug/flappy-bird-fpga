library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
 
entity IntTo7segment_decoder is Port ( 
    score_in : in INTEGER;
    Seven_Segment : out STD_LOGIC_VECTOR (6 downto 0);
    an : out STD_LOGIC_VECTOR (3 downto 0)
);
end IntTo7segment_decoder;
 
architecture Behavioral of IntTo7segment_decoder is
 
begin
 
process(score_in)
begin
    case score_in is -- multiplixer 
        when 0 =>
            Seven_Segment <= "1000000"; ---0
        when 1 =>
            Seven_Segment <= "1111001"; ---1
        when 2 =>
            Seven_Segment <= "0100100"; ---2
        when 3 =>
            Seven_Segment <= "0110000"; ---3
        when 4 =>
            Seven_Segment <= "0011001"; ---4
        when 5 =>
            Seven_Segment <= "0010010"; ---5
        when 6 =>
            Seven_Segment <= "0000010"; ---6
        when 7 =>
            Seven_Segment <= "1111000"; ---7
        when 8 =>
            Seven_Segment <= "0000000"; ---8
        when 9 =>
            Seven_Segment <= "0010000"; ---9
        when others =>
            Seven_Segment <= "1000000"; ---0
    end case;
end process;
 
end Behavioral;
