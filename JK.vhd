library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

entity JK is
	port(J,K : in std_logic;
	     Q : out std_logic
	);
end JK;

architecture Behavioral of JK is
	signal aux : std_logic;
begin

	aux <= (J AND NOT aux) OR (NOT K AND aux);
	Q <= aux;
	
end Behavioral;


