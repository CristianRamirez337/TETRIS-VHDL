LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY DECODER_LOGO IS
	PORT(CLK: IN STD_LOGIC;
		HS,VS: IN STD_LOGIC_VECTOR(9 DOWNTO 0);
		HS_OUT: OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
		VS_OUT: OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
	);
END DECODER_LOGO;

ARCHITECTURE Behavioral OF DECODER_LOGO IS

	SIGNAL HSAux, VSaux: INTEGER;
BEGIN
	
	HSAux <= CONV_INTEGER(HS);
	VSAux <= CONV_INTEGER(VS);

	PROCESS(HS) --X(150,640), Y(50,480) 
		BEGIN IF RISING_EDGE(CLK) THEN
			IF (HSAux > 150 and HSAux <  165) THEN
				HS_OUT <= "00001";
			ELSIF (HSAux > 165 and HSAux <  180) THEN
				HS_OUT <= "00010";
			ELSIF (HSAux > 180 and HSAux <  195) THEN
				HS_OUT <= "00011";
			ELSIF (HSAux > 195 and HSAux <  210) THEN
				HS_OUT <= "00100";
			ELSIF (HSAux > 210 and HSAux <  225) THEN
				HS_OUT <= "00101";
			ELSIF (HSAux > 225 and HSAux <  240) THEN
				HS_OUT <= "00110";
			ELSIF (HSAux > 240 and HSAux <  255) THEN
				HS_OUT <= "00111";
			ELSIF (HSAux > 255 and HSAux <  270) THEN
				HS_OUT <= "01000";
			ELSIF (HSAux > 270 and HSAux <  285) THEN
				HS_OUT <= "01001";
			ELSIF (HSAux > 285 and HSAux < 300 ) THEN
				HS_OUT <= "01010";
			ELSIF (HSAux > 300 and HSAux < 315 ) THEN
				HS_OUT <= "01011";
			ELSIF (HSAux > 315 and HSAux < 330 ) THEN
				HS_OUT <= "01100";
			ELSIF (HSAux > 330 and HSAux < 345 ) THEN
				HS_OUT <= "01101";
			ELSIF (HSAux > 345 and HSAux < 360 ) THEN
				HS_OUT <= "01110";
			ELSIF (HSAux > 360 and HSAux < 375 ) THEN
				HS_OUT <= "01111";
			ELSIF (HSAux > 375 and HSAux < 390 ) THEN
				HS_OUT <= "10000";
			ELSIF (HSAux > 390 and HSAux < 405 ) THEN
				HS_OUT <= "10001";
			ELSIF (HSAux > 405 and HSAux < 420 ) THEN
				HS_OUT <= "10010";
			ELSIF (HSAux > 420 and HSAux < 435 ) THEN
				HS_OUT <= "10011";
			ELSIF (HSAux > 435 and HSAux < 450 ) THEN
				HS_OUT <= "10100";
			ELSIF (HSAux > 450 and HSAux < 465 ) THEN
				HS_OUT <= "10101";
			ELSIF (HSAux > 465 and HSAux < 480 ) THEN
				HS_OUT <= "10110";
			ELSIF (HSAux > 480 and HSAux < 495 ) THEN
				HS_OUT <= "10111";
			ELSIF (HSAux > 495 and HSAux < 510 ) THEN
				HS_OUT <= "11000";
			ELSIF (HSAux > 510 and HSAux < 525 ) THEN
				HS_OUT <= "11001";
			ELSIF (HSAux > 525 and HSAux < 540 ) THEN
				HS_OUT <= "11010";
			ELSIF (HSAux > 540 and HSAux < 555 ) THEN
				HS_OUT <= "11011";
			ELSIF (HSAux > 555 and HSAux < 570 ) THEN
				HS_OUT <= "11100";
			ELSIF (HSAux > 570 and HSAux < 585 ) THEN
				HS_OUT <= "11101";
			ELSIF (HSAux > 585 and HSAux < 600 ) THEN
				HS_OUT <= "11110";
			ELSIF (HSAux > 600 and HSAux < 615 ) THEN
				HS_OUT <= "11111";
			ELSE
				HS_OUT <= "00000";
			END IF;
			ELSE NULL; END IF;
	END PROCESS;
	
	PROCESS(VSAux) --X(150,640), Y(50,480) 
		BEGIN IF RISING_EDGE(CLK) THEN
			IF (VSAux > 75 and VSAux <  89) THEN
				VS_OUT <= "0001";
			ELSIF (VSAux > 90 and VSAux <  104) THEN
				VS_OUT <= "0010";
			ELSIF (VSAux > 105 and VSAux <  119) THEN
				VS_OUT <= "0011";
			ELSIF (VSAux > 120 and VSAux <  134) THEN
				VS_OUT <= "0100";
			ELSIF (VSAux > 135 and VSAux <  149) THEN 
				VS_OUT <= "0101";
			ELSIF (VSAux > 150 and VSAux <  164) THEN
				VS_OUT <= "0110";
			ELSIF (VSAux > 165 and VSAux <  179) THEN
				VS_OUT <= "0111";
			ELSIF (VSAux > 180 and VSAux <  194) THEN
				VS_OUT <= "1000";
			ELSE
				VS_OUT <= "0000";
			END IF;
			ELSE NULL; END IF;
	END PROCESS;
END Behavioral;

