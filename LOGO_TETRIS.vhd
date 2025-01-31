LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY LOGO_TETRIS IS
	PORT(
		CLK25: IN STD_LOGIC;
		HS,VS: IN STD_LOGIC_VECTOR(9 DOWNTO 0);
		GAMEOVER: IN STD_LOGIC;
		OutRGB: OUT STD_LOGIC_VECTOR( 2 DOWNTO 0)
	);
END LOGO_TETRIS;

ARCHITECTURE Behavioral OF LOGO_TETRIS IS

	COMPONENT RAM_TETRIS IS
		 PORT ( InRGB : IN  STD_LOGIC_VECTOR (2 downto 0);
				  clk: IN STD_LOGIC;
				  Wrt_EN: IN STD_LOGIC; -- Write Enable
				  ADDRESS: IN STD_LOGIC_VECTOR(8 DOWNTO 0);
				  GAMEOVER: IN STD_LOGIC;
				  OutRGB : OUT  STD_LOGIC_VECTOR (2 downto 0)
			);
	END COMPONENT;
	
	COMPONENT DECODER_LOGO IS
		PORT(CLK: IN STD_LOGIC;
			HS,VS: IN STD_LOGIC_VECTOR(9 DOWNTO 0);
			HS_OUT: OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
			VS_OUT: OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
		);
	END COMPONENT;

	-- POSICION X
	SIGNAL X_POS: STD_LOGIC_VECTOR(4 DOWNTO 0):= "00001";
	--POSICION Y
	SIGNAL Y_POS: STD_LOGIC_VECTOR(3 DOWNTO 0):= "1000";
	
	SIGNAL CLK4Hz: STD_LOGIC;
	SIGNAL WRT_ENABLE: STD_LOGIC;
	SIGNAL InRGB: STD_LOGIC_VECTOR (2 downto 0);
	SIGNAL ADDRESS, ADDRESS_WRT: STD_LOGIC_VECTOR(8 DOWNTO 0);
	SIGNAL ADDRESS_DECODER_H: STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL ADDRESS_DECODER_v: STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL CONTADOR: STD_LOGIC_VECTOR(11 DOWNTO 0):=(OTHERS=>'0');
	
	BEGIN
	
		PROCESS(CLK25)
			BEGIN
				IF RISING_EDGE(CLK25) THEN
					IF CONTADOR = "1011111010111100001000" THEN
						CLK4Hz <= NOT CLK4Hz;
						CONTADOR <= (OTHERS=>'0');
					ELSE
						CONTADOR <= CONTADOR + 1;
					END IF;
				ELSE NULL;
				END IF;
		END PROCESS;
	
	RAM_LOGO: RAM_TETRIS PORT MAP(InRGB, CLK25, WRT_ENABLE, ADDRESS, GAMEOVER, OUTRGB);
	DECODER_LOGO1: DECODER_LOGO PORT MAP(CLK25, Hs, Vs, ADDRESS_DECODER_H, ADDRESS_DECODER_V);
	ADDRESS <= ADDRESS_DECODER_H& ADDRESS_DECODER_V;
	
		CONTORNO: PROCESS(CLK4Hz)
			BEGIN
				IF rising_edge(CLK4Hz) THEN
					
					
					IF ADDRESS = "100000100" THEN
						WRT_ENABLE <= '1';
						IF InRGB = "010" THEN
							InRGB <= "111";
						ELSE
							InRGB <= "010";
						END IF;
					ELSE
						WRT_ENABLE <= '0';
					END IF;
				ELSE 
					NULL;
				END IF;
		END PROCESS;


END Behavioral;

