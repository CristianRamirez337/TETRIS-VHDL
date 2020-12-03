library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

ENTITY DISPLAY IS
	PORT (
		CLK : IN std_logic;
		D3 :  IN std_logic_VECTOR(3 DOWNTO 0);
		D2 :  IN std_logic_VECTOR(3 DOWNTO 0);
		D1 :  IN std_logic_VECTOR(3 DOWNTO 0);
		D0 :  IN std_logic_VECTOR(3 DOWNTO 0);
		S8 :  OUT std_logic_VECTOR (7 DOWNTO 0);
		EN :  OUT std_logic_VECTOR (3 DOWNTO 0)
	);
END DISPLAY;

ARCHITECTURE Behavioral OF DISPLAY IS

	SIGNAL STATE, NEW_STATE: std_logic_VECTOR(3 DOWNTO 0) := "1000"; 
	SIGNAL DN : std_logic_VECTOR(3 DOWNTO 0) := "0000";
	
	
BEGIN

	PROCESS (CLK)
	BEGIN
		IF (CLK = '1' AND CLK'EVENT) THEN
			STATE <= NEW_STATE;
		END IF;
	END PROCESS;


	NEW_STATE <= "0001" WHEN (STATE = "1000") ELSE
	             "0010" WHEN (STATE = "0001") ELSE
	             "0100" WHEN (STATE = "0010") ELSE
	             "1000" WHEN (STATE = "0100") ELSE
	             "0001";
 
	DN <= D0 WHEN (STATE = "0001") ELSE
	      D1 WHEN (STATE = "0010") ELSE
	      D2 WHEN (STATE = "0100") ELSE
	      D3 WHEN (STATE = "1000") ELSE
	      "1111";
	 
	EN <= NOT STATE;

	S8 <=   "11000000" WHEN DN = "0000" ELSE
	        "11111001" WHEN DN = "0001" ELSE
	        "10100100" WHEN DN = "0010" ELSE
	        "10110000" WHEN DN = "0011" ELSE
	        "10011001" WHEN DN = "0100" ELSE
	        "10010010" WHEN DN = "0101" ELSE
	        "10000010" WHEN DN = "0110" ELSE
			  "11111000" WHEN DN = "0111" ELSE
	        "10000000" WHEN DN = "1000" ELSE
	        "10010000" WHEN DN = "1001" ELSE
	        "10001000" WHEN DN = "1010" ELSE
	        "10000011" WHEN DN = "1011" ELSE
	        "11000110" WHEN DN = "1100" ELSE
	        "10100001" WHEN DN = "1101" ELSE
	        "10000110" WHEN DN = "1110" ELSE
	        "10001110";
	

END Behavioral;

