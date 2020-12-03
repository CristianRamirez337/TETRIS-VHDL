LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
 
ENTITY VGA IS
	PORT(CLK25 : IN STD_LOGIC;
			 RGB_IN	 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
			 RGB_IN2	 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
			 RED      : OUT STD_LOGIC;         
			 GREEN    : OUT STD_LOGIC;
			 BLUE     : OUT STD_LOGIC;
			 Hs_OUT   : OUT STD_LOGIC; -- HORIZONTAL SYNC         
			 Vs_OUT   : OUT STD_LOGIC; -- VERTICAL SYNC
			 GAMEOVER : IN STD_LOGIC;
			 HS_AUX, VS_AUX	 : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
			 );   
END VGA;
 
ARCHITECTURE BEHAVIORAL OF VGA IS
	
	SIGNAL Hs : STD_LOGIC_VECTOR (9 DOWNTO 0);
	SIGNAL Vs : STD_LOGIC_VECTOR (9 DOWNTO 0);
	
	BEGIN
 
	PROCESS (CLK25)
		BEGIN
		IF CLK25'EVENT AND CLK25 = '1' THEN
-------------------------------- AQUI EMPIEZA EL MARGEN DE LA PANTALLA --------------------------------
				-- LINEA VERTICAL DERECHA
				IF Hs = "0111000010" AND Vs >= "0011000011" AND Vs <= "0111100000" THEN -- X = 640, Y [50,480] 				
					IF GAMEOVER = '1' THEN
						RED <= '1';
						GREEN <= '1';
						BLUE <= '1';
					ELSE
						RED <= '0';
						GREEN <= '1';
						BLUE <= '0';
					END IF;
				-- LINEA VERTICAL IZQUEIERDA
				ELSIF HS = "0100101100" AND VS >= "0011000011" AND VS <= "0111100000"  THEN -- X = 150, Y[50,480]
					IF GAMEOVER = '1' THEN
						RED <= '1';
						GREEN <= '1';
						BLUE <= '1';
					ELSE
						RED <= '0';
						GREEN <= '1';
						BLUE <= '0';
					END IF;
				-- LINEA HORIZONTAL INFERIOR	
				ELSIF HS >= "0100101100" AND Hs <= "0111000010" AND VS = "0111100000" THEN -- X[150, 640], Y = 480
					IF GAMEOVER = '1' THEN
						RED <= '1';
						GREEN <= '1';
						BLUE <= '1';
					ELSE
						RED <= '0';
						GREEN <= '1';
						BLUE <= '0';
					END IF;
				-- LINEA HORIZONTAL SUPERIOR
				ELSIF HS >= "0100101100" AND Hs <= "0111000010" AND VS = "0011000011" THEN --X[150, 640], Y = 50
					IF GAMEOVER = '1' THEN
						RED <= '1';
						GREEN <= '1';
						BLUE <= '1';
					ELSE
						RED <= '0';
						GREEN <= '1';
						BLUE <= '0';
					END IF;
-------------------------------- AQUI TERMINA EL MARGEN DE LA PANTALLA --------------------------------

---------------------- SECCION PARA DESLEGAR LOS CUADROS DE ACUERDO A LA MEMORIA ----------------------
				ELSIF HS > "0010010110" AND Hs < "1010000000" AND VS > "0011000011" AND VS < "0111100000" THEN --X(150,640), Y(50,480) 
						RED <= RGB_IN(2);
						GREEN <= RGB_IN(1);
						BLUE <= RGB_IN(0);
				ELSIF HS > "0010010110" AND Hs < "1010000000" AND VS > "0000110010" AND VS < "0011000011" THEN --X(150,640), Y(50,480) 
						RED <= RGB_IN2(2);
						GREEN <= RGB_IN2(1);
						BLUE <= RGB_IN2(0);
			
------------------ TERMINA SECCION PARA DESLEGAR LOS CUADROS DE ACUERDO A LA MEMORIA ------------------
				ELSE                     
					RED <= '0' ;
					GREEN <= '0' ;
					BLUE <= '0';
				END IF;

				IF (HS > "0000000000" )AND (HS < "0001100001" ) THEN -- DESDE EL CONTEO 97 EN HORIZONTAL
					HS_OUT <= '0';
				ELSE
					HS_OUT <= '1';
				END IF;
				
				IF (VS > "0000000000" ) AND (VS < "0000000011" ) THEN -- DESDE  EL CONTEO DE 3 EN VERTICAL
					VS_OUT <= '0';
				ELSE
					VS_OUT <= '1';
				END IF;
				
				HS <= HS + "0000000001" ;
				
				IF (HS= "1100100000") THEN    -- Hasta 800 
					VS <= VS + "0000000001";       
					HS <= "0000000000";
				ELSE NULL;
				END IF;
				
				IF (VS= "1000001001") THEN                 
					VS <= "0000000000";
				END IF;
			END IF;
			
	END PROCESS;

		HS_AUX <= HS;
		VS_AUX <= VS;
	
END BEHAVIORAL;

