LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY TETRIS_MAIN IS
	PORT (
		CLK, BRIGHT, BLEFT, BDOWN, BRESET, BGIRO: IN STD_LOGIC;
		RED, GREEN , BLUE, Hs_OUT, Vs_OUT: OUT STD_LOGIC;
		LEDOUT, BUZZER, LEDIN   : OUT STD_LOGIC;
		S8 : out  STD_LOGIC_VECTOR (7 downto 0);
      EN : out  STD_LOGIC_VECTOR (3 downto 0)
	);
END TETRIS_MAIN;

ARCHITECTURE Behavioral OF TETRIS_MAIN IS

	COMPONENT VGA IS
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
	END COMPONENT;
	
	COMPONENT LOGO_TETRIS IS
		PORT(
			CLK25: IN STD_LOGIC;
			HS,VS: IN STD_LOGIC_VECTOR(9 DOWNTO 0);
			GAMEOVER: IN STD_LOGIC;
			OutRGB: OUT STD_LOGIC_VECTOR( 2 DOWNTO 0)
		);
	END COMPONENT;
	
	COMPONENT RAM IS
    PORT ( InRGB : IN  STD_LOGIC_VECTOR (2 downto 0);
			  clk: IN STD_LOGIC;
			  Wrt_EN: IN STD_LOGIC := '0'; -- Write Enable
			  ADDRESS: IN STD_LOGIC_VECTOR(8 DOWNTO 0); --Address 8 DOWNTO 5 es horizontal, y lo demas vertical
           OutRGB : OUT  STD_LOGIC_VECTOR (2 downto 0);
			  X: IN STD_LOGIC_VECTOR(4 DOWNTO 0);
			  Y: IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			  LECTURA : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
			  );	
	END COMPONENT;
	
	COMPONENT DECODER IS
		PORT(
			HS,VS: IN STD_LOGIC_VECTOR(9 DOWNTO 0);
			HS_OUT: OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
			VS_OUT: OUT STD_LOGIC_VECTOR(4 DOWNTO 0)
		);
	END COMPONENT;
	
	COMPONENT CLK_25MHz IS
		 PORT ( CLK : IN  STD_LOGIC;
				  CLKOUT : OUT  STD_LOGIC);
	END COMPONENT;
	
	COMPONENT CLK_500HZ IS
		PORT (
			MCLK : IN STD_LOGIC;
			CLKOUT : OUT STD_LOGIC
		);
	END COMPONENT;
	
	COMPONENT DEBOUNCE IS
		PORT (
			CLK : IN STD_LOGIC;
			DIN : IN STD_LOGIC;
			QOUT : OUT STD_LOGIC);
	END COMPONENT;
	
	COMPONENT CLK_FIGURA IS
		PORT (clock : in std_logic;
				  Clock_segundo : out std_logic
		  ) ;
	END COMPONENT;
	
	COMPONENT CLK_FIGURA2 is
	  port (clock : in std_logic;
			  Clock_segundo : out std_logic
	  ) ;
	end COMPONENT;
	
	COMPONENT DISPLAY IS
	PORT (
		CLK : IN std_logic;
		D3 :  IN std_logic_VECTOR(3 DOWNTO 0);
		D2 :  IN std_logic_VECTOR(3 DOWNTO 0);
		D1 :  IN std_logic_VECTOR(3 DOWNTO 0);
		D0 :  IN std_logic_VECTOR(3 DOWNTO 0);
		S8 :  OUT std_logic_VECTOR (7 DOWNTO 0);
		EN :  OUT std_logic_VECTOR (3 DOWNTO 0)
	);
	END COMPONENT;
	
	COMPONENT JK IS
		port(J,K : in std_logic;
			  Q : out std_logic
		);
	END COMPONENT;
	
	COMPONENT lfsr1 IS  PORT (
		 RESET  : IN  STD_LOGIC;
		 CLK    : IN  STD_LOGIC;
		 COUNT  : OUT STD_LOGIC_VECTOR (2 DOWNTO 0)
	  );
	END COMPONENT;
	
	-- Se?ales memoria RAM
	SIGNAL InRGB, INRGB2 : STD_LOGIC_VECTOR (2 downto 0);
	SIGNAL Wrt_EN : STD_LOGIC := '0'; -- Write Enable
	SIGNAL ADDRESS, ADDRESS2: STD_LOGIC_VECTOR(8 DOWNTO 0); --Address 8 DOWNTO 5 es horizontal, y lo demas vertical
	SIGNAL OutRGB, OUTRGB2, LECTURA, LECTURA_ANT : STD_LOGIC_VECTOR (2 downto 0);
	SIGNAL X, AUXX: STD_LOGIC_VECTOR(4 DOWNTO 0) := "00001";
	SIGNAL Y, AUX: STD_LOGIC_VECTOR(3 DOWNTO 0) := "0110";
	
	-- Se?ales DECODER
	SIGNAL ADDRESS_DECODER_H: STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL ADDRESS_DECODER_V: STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL HS,VS: STD_LOGIC_VECTOR(9 DOWNTO 0);
	
	-- SeÑales para movimiento con botones
	SIGNAL UP, PDOWN , DOWN, LEFT, RIGHT, RESET, PLEFT, PRIGHT, ABAJO, ABAJO2, ABAJOFINAL, PABAJO, GIRO, PGIRO, PRESET: std_logic;
	
	-- SeÑales de reloj
	SIGNAL CLK25      : STD_LOGIC;
	SIGNAL CLKFIGURA, CLKFIGURA2  : STD_LOGIC;
	SIGNAL CLK500     : STD_LOGIC;
	SIGNAL CLK025     : STD_LOGIC;
	
	--SEÑALES DE LA MAQUINA DE ESTADOS
	SIGNAL ESTADO : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL FIGURA : STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL BORRANDO, SHIF : STD_LOGIC := '0';
 	SIGNAL ESTADOGIRO : STD_LOGIC := '0'; 
	SIGNAL CONTBOR : STD_LOGIC_VECTOR(2 DOWNTO 0) := "000";
	
	--FLIP FLOP QUE BAJA
	SIGNAL J,K,Q, KDE, QDE, KIZ, QIZ,QGIRO, KGIRO : STD_LOGIC;
	SIGNAL GAMEOVER, LLENO : STD_LOGIC;
	
	-- DISPLAYS
	SIGNAL A,B,C,D : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";
	
	--SEÑALES DE NUMEROS ALEATORIOS
	SIGNAL RESETNA : STD_LOGIC;
	SIGNAL NUEVAFIGURA : STD_LOGIC_VECTOR(2 DOWNTO 0);
	

	
	BEGIN
	
	-- RELOJES
	CLK25MHz: CLK_25MHz PORT MAP(CLK, CLK25); 
	CLK1SEG: CLK_FIGURA PORT MAP(CLK, CLKFIGURA);
	CLK500HZ: CLK_500HZ PORT MAP(CLK,CLK500);
	CLK05S: CLK_FIGURA2 PORT MAP(CLK, CLKFIGURA2);
	
	--DEBOUNCE DE BOTONES
	DB1 : DEBOUNCE PORT MAP(CLK500, BRIGHT, PRIGHT);
	DB2 : DEBOUNCE PORT MAP(CLK500, BLEFT,  PLEFT);
	DB3 : DEBOUNCE PORT MAP(CLK25, PRIGHT, RIGHT);
	DB4 : DEBOUNCE PORT MAP(CLK25, PLEFT, LEFT);
	DB5 : DEBOUNCE PORT MAP(CLK25, CLKFIGURA , ABAJO);
	DB6 : DEBOUNCE PORT MAP(CLK25, CLKFIGURA2 , ABAJO2);
	DB7 : DEBOUNCE PORT MAP(CLK500, BRESET, PRESET);
	DB8 : DEBOUNCE PORT MAP(CLK25, PRESET, RESET);
	DB9 : DEBOUNCE PORT MAP(CLK500, BGIRO, PGIRO);
	DB10 : DEBOUNCE PORT MAP(CLK25, PGIRO, GIRO);
	
	-- Memoria RAM
	RAM1: RAM PORT MAP(INRGB, CLK25, WRT_EN, ADDRESS, OUTRGB,X,Y,LECTURA);
	
	--DECODER DE LA MEMORIA AL VGA
	DECODER1: DECODER PORT MAP(Hs, Vs, ADDRESS_DECODER_H, ADDRESS_DECODER_V);
	
	-- VGA
	VGA1: VGA PORT MAP (CLK25, OutRGB, OUTRGB2, RED, GREEN, BLUE, Hs_OUT, Vs_OUT, GAMEOVER ,HS, VS);
	
	--Como accerder a la memoria
	ADDRESS  <= ADDRESS_DECODER_H & ADDRESS_DECODER_V;
	
	--LOGO TETRIS
	LOGO: LOGO_TETRIS PORT MAP(CLK25, HS, VS, GAMEOVER, OutRGB2);
	
	--Led de Reloj de 1 segundo
	LEDOUT <= Q;--CLKFIGURA;
	
	-- NUMERO ALEATORIO
	NA: lfsr1 PORT MAP (RESETNA, CLK25, NUEVAFIGURA);
	 	 
	--DECLARACION DE COLOR DEACUERO A LA FIGURA ACTUAL
	INRGB <=  "000" WHEN BORRANDO = '1' OR (SHIF = '1' AND X = "00001") ELSE 
			  LECTURA_ANT WHEN SHIF = '1' ELSE INRGB2;
	INRGB2 <= "110" WHEN FIGURA = "000" ELSE 
				 "011" WHEN FIGURA = "001" ELSE "000";
	
	--EMPIEZA MAQUINA DE ESTADOS
	PROCESS(X,Y,CLK25, ESTADO, FIGURA)
	BEGIN
			IF RISING_EDGE(CLK25) THEN
			LECTURA_ANT <= LECTURA;
				IF ESTADO = "00000000" THEN
					RESETNA <= '0';
				--ESTADO 0 DE AQUI SE VA DEPENDIENDO LA FIGURA QUE ES
					IF FIGURA = "000" THEN 
						ESTADO <= "00000001";
					ELSIF FIGURA = "001" THEN
						ESTADO <= "00100011";
					ELSE ESTADO <= "00000001";
					END IF;
				--ESTADO 1 SE EMPIEZA EL PROCESO DEL CUADRO
				ELSIF ESTADO = "00000001" THEN
					IF X > "10010" THEN
						ESTADO <= "00000010";
						WRT_EN <= '1';
					ELSE 
					ESTADO <= "00000110";--SE VA AL ESTADO 6 Y CHECA SI HAY ALGO ABAJO DE EL PARA REINICIAR O CONTINUAR CON SU PASO
					X <= X + 1;
					END IF;
				--ESTADO 2 SE PINTA PORQUE LLEGASTE AL FONDO VA DESDE EL 2 AL 5 Y REINICIA EL CONTADOR PARA OTRA FIGURA
				ELSIF ESTADO = "00000010" THEN 
						Y <= Y + 1;
						ESTADO <= "00000011";
				ELSIF ESTADO <= "00000011" THEN
						X <= X - 1;
						ESTADO <= "00000100";
				ELSIF ESTADO <= "00000100" THEN 
						Y <= Y - 1;
						ESTADO <= "00000101";
				ELSIF ESTADO <= "00000101" THEN
						WRT_EN <= '0';
						X <= X + 1;
						ESTADO <= "00011101"; --SE VA AL ESTADO DE CHECAR LAS COLUMANOS DEL CUADRADO
				--ESTADO 6 - 7 CHECARA QUE NO HAY ALGO ABAJO DE EL PARA PODER PINTAR O SI NO CONTINUAR CON SU CAMINO
				ELSIF ESTADO = "00000110" THEN 
					--ESTADO <= "00001000";
					IF LECTURA = "000" THEN
						Y <= Y+1;
						ESTADO <= "00000111";
					ELSE 
						IF(X = "00010") THEN
							GAMEOVER <= '1';
							ESTADO <= "00100010";
						ELSE 
							GAMEOVER <= '0';
							X <= X - 1;
							ESTADO <= "00011101"; --SE VA AL ESTADO DE CHECAR LAS COLUMANOS DEL CUADRADO
						END IF;
						
					END IF;
				ELSIF ESTADO = "00000111" THEN
					IF LECTURA = "000" THEN
						ESTADO <= "00001000";
						X <= X - 1;
						Y <= Y - 1;
					ELSE
						IF(X = "00010") THEN
							GAMEOVER <= '1';
							ESTADO <= "00100010";
						ELSE 
							GAMEOVER <= '0';
							X <= X - 1;
							ESTADO <= "00011101";
							Y <= Y - 1;
						END IF;
						--ESTADO <= "00000000";
						--X <= "00001";
						
					END IF;
				--ESTADO 8 VER QUE BOTON FUE APLANADO DERECHA, IZQUIERDA, GIRO,  O ABAJO
				ELSIF ESTADO = "00001000" THEN
					--BOTON ABAJO
					IF Q = '1' THEN
						K <= '1';
						WRT_EN <= '1';
						X <= X + 1;
						IF FIGURA = "000" THEN
							ESTADO <= "00001001";
						ELSIF ESTADOGIRO = '0' THEN
							ESTADO <= "00101001";
						ELSE
							ESTADO <= "10001001";
						END IF;
					--BOTON DERECHA
					ELSIF QDE = '1' THEN
						IF FIGURA = "000" THEN
							ESTADO <= "00001111";
						ELSIF ESTADOGIRO = '0' THEN
							ESTADO <= "00101110";
						ELSE
							ESTADO <= "10010001";
						END IF;
						KDE <= '1';
					--BOTON IZQUIERDA
					ELSIF QIZ = '1' THEN
						IF FIGURA = "000" THEN
							ESTADO <= "00010110";
						ELSIF ESTADOGIRO = '0' THEN
							ESTADO <= "00111011";
						ELSE 
							ESTADO <= "10010101";
						END IF;
						KIZ <= '1';
					--BOTON GIRO
					ELSIF QGIRO = '1' THEN
						IF FIGURA = "001" THEN
							KGIRO <= '1';
							IF ESTADOGIRO = '0' THEN
								ESTADO <= "10011001";
							ELSE
								ESTADO <= "10100011";
							END IF;
						ELSE ESTADO <= "00000000";
						END IF;
					ELSE ESTADO <= "00000000";
					END IF;
				--ESTADO 9 - 14 PINTAR LAS POSICIONES EN LAS QUE ESTAS Y BORRAR
					--PINTANDO
				ELSIF ESTADO = "0001001" THEN
					K <= '0';
					Y <= Y +1;
					ESTADO <= "00001010";
				ELSIF ESTADO = "00001010" THEN
					X <= X - 1;
					ESTADO <= "00001011";
				ELSIF ESTADO = "00001011" THEN
					Y <= Y - 1;
					ESTADO <= "00001100";
				ELSIF ESTADO = "00001100" THEN
					BORRANDO <= '1';
					X <= X - 1;
					ESTADO <= "00001101";
					--BORRANDO
				ELSIF ESTADO = "00001101" THEN
					Y <= Y + 1;
					ESTADO <= "00001110";
				ELSIF ESTADO = "00001110" THEN
					BORRANDO <= '0';
					WRT_EN <= '0';
					ESTADO <= "00000000";
					X <= X + "00010";
					Y <= Y - 1;
				--ESTADO 15 - 21  PINTA PARA MOVERSE A LA DERECHA
				ELSIF ESTADO = "00001111" THEN
					KDE <= '0';
					IF Y < "1001" THEN
						ESTADO <= "00010000";
						Y <= Y + "0010";
					ELSE
						ESTADO <= "00000000";
					END IF;
				ELSIF ESTADO = "00010000" THEN
					IF LECTURA = "000" THEN 
						ESTADO <= "00010001";
						X <= X - 1;
					ELSE
						ESTADO <= "00000000";
						Y <= Y - "0010";
					END IF;
				ELSIF ESTADO = "00010001" THEN
					IF LECTURA = "000" THEN 
						ESTADO <= "00010010";
						WRT_EN <= '1'; 
					ELSE 
						ESTADO <= "00000000";
						Y <= Y - "0010";
						X <= X + 1;
					END IF;
				ELSIF ESTADO <= "00010010" THEN
					X <= X + 1;
					ESTADO <= "00010011";
				ELSIF ESTADO = "00010011" THEN 
					BORRANDO <= '1';
					Y <= Y - "0010";
					ESTADO <= "00010100";
				ELSIF ESTADO = "00010100" THEN
					X <= X - 1;
					ESTADO <= "00010101";
				ELSIF ESTADO = "00010101" THEN
					X <= X + 1;
					Y <= Y + 1;
					BORRANDO <= '0';
					WRT_EN <= '0';
					ESTADO  <= "00000000";
				--ESTADO 21 - 28 SE DETECTO EL MOVIMIENTO IZQUIERDO SE VERIFICA QUE SE PUEDA REALIZAR EN CASO DE PINTA Y BORRA
				ELSIF ESTADO = "00010110" THEN
					KIZ <= '0';
					IF Y > "0001" THEN
						ESTADO <= "00010111";
						Y <= Y - 1; 
					ELSE ESTADO <= "00000000";
					END IF;
				ELSIF ESTADO = "00010111" THEN
					IF LECTURA = "000" THEN
						ESTADO <= "00011000";
						X <= X - 1;
					ELSE
						ESTADO <= "00000000";
						Y <= Y+1;
					END IF;
				ELSIF ESTADO = "00011000" THEN 
					IF LECTURA = "000" THEN
						WRT_EN <= '1';
						ESTADO <= "00011001";
					ELSE
						ESTADO <= "00000000";
						X <= X + 1;
						Y <= Y + 1;
					END IF;
				ELSIF ESTADO = "00011001" THEN 
					X <= X + 1;
					ESTADO <= "00011010";
				ELSIF ESTADO = "00011010" THEN
					BORRANDO <= '1';
					Y <= Y + "0010";
					ESTADO <= "00011011";
				ELSIF ESTADO = "00011011" THEN
					X <= X - 1;
					ESTADO <= "00011100";
				ELSIF ESTADO = "00011100" THEN
					X <= X + 1;
					Y <= Y - "0010";
					BORRANDO <= '0';
					WRT_EN <= '0';
					ESTADO  <= "00000000";
				--ESTADO 29 SE CHECA SI LA FILA ESTA LLENA
				ELSIF ESTADO = "00011101" THEN
					Y <= "0001";
					AUX <= Y;
					ESTADO <= "00011110";
				ELSIF ESTADO = "00011110" THEN
					IF CONTBOR = "100" THEN
						--NUEVA FIGURA
						Y <= AUX;
						X <= "00001";
						ESTADO <= "10000000";
						CONTBOR <= "000";
					ELSIF Y = "1011" THEN
						LLENO <= '1';
						SHIF  <= '1';
						AUXX  <= X;
						Y <= "0001";
						ESTADO <= "00100000";
						CONTBOR <= CONTBOR + 1;
						--ESTADO <= "00000000";
						X <= "00001";
					ELSIF LECTURA > "000" THEN
						Y <= Y + 1;
						ESTADO <= "00011110";
					ELSE
						LLENO <= '0';
						X <= X - 1;
						CONTBOR <= CONTBOR + 1;
						ESTADO <= "00011110";
						Y <= "0001";
					END IF;
				ELSIF ESTADO = "00011111" THEN
					IF Y = "1011" THEN
						Y <= AUX;
						X <= AUXX;
						WRT_EN <= '0';
						SHIF <= '0';
						ESTADO <= "00011101";
					ELSIF X = AUXX THEN
						X <= "00001";
						Y <= Y + 1;
						ESTADO <= "00011111";
					ELSE
						X <= X + 1;
						ESTADO <= "00011111";
					END IF;
				ELSIF ESTADO = "00100000" THEN
					WRT_EN <= '1';
					ESTADO <= "00011111";
					IF B = "1001" AND C = "1001" AND D = "1001" THEN
						A <= A + 1;
						B <= "0000";
						C <= "0000";
						D <= "0000";
					ELSIF C = "1001" AND D = "1001" THEN
						B <= B + 1;
						C <= "0000";
						D <= "0000";
					ELSIF D = "1001" THEN
						C <= C + 1;
						D <= "0000";
					ELSE 
						D <= D + 1;
					END IF;
				--ESTADO RESET
				ELSIF ESTADO = "00100001" THEN
					IF Y = "1011" THEN
						Y <= "0110";
						X <= "00001";
						WRT_EN <= '0';
						BORRANDO <= '0';
						ESTADO <= "00000000";
						A <= "0000";
						B <= "0000";
						C <= "0000";
						D <= "0000";
					ELSIF X = "10011" THEN
						X <= "00001";
						Y <= Y + 1;
						
					ELSE
						X <= X + 1;
						
					END IF;
				ELSIF ESTADO = "00100010" THEN
					IF (RESET = '1') THEN
						ESTADO <= "00100001";
						GAMEOVER <= '0';
						BORRANDO <= '1';
						WRT_EN <= '1';
						X <= "00001";
						Y <= "0001";
					ELSE
						ESTADO <= "00100010";
					END IF;
				-----------------------------------------------------------------------------------------------------------
				--ESTADO 35 FIGURA L INCIAL CHECA SI YA LLEGO AL FONDO
				ELSIF ESTADO = "00100011" THEN
					IF ESTADOGIRO = '0' THEN
						IF X > "10000" THEN
							WRT_EN <= '1';
							ESTADO <= "00100100";
						ELSE
							ESTADO <= "00101000";
							X <= X + "00011";
							--SE VA A IR A CHECAR SI HAY ALGO ABAJO DE EL
						END IF;
					ELSE
						IF X > "10010" THEN
							WRT_EN <= '1';
							ESTADO <= "10000001";
						ELSE
							X <= X + 1;
							ESTADO <= "10000101";
						END IF;
					END IF;
				-----------------------------------------------------------------------------------------------------------
				--ESTADO 36 - 39 PINTA LOS CUADROS CUANDO YA LLEGASTE AL FINAL
				ELSIF ESTADO = "00100100" THEN
					X <= X + 1;
					ESTADO <= "00100101";
				ELSIF ESTADO = "00100101" THEN
					X <= X + 1;
					ESTADO <= "00100110";
				ELSIF ESTADO = "00100110" THEN
					X <= X - "00011";
					ESTADO <= "00100111";
				ELSIF ESTADO = "00100111" THEN
					WRT_EN <= '0';
					X <= X + "00011";	
					ESTADO <= "00011101";
				------------------------------------------------------------------------------------------------------------
				--VERIFICAR QUE NO HAYA NADA ABAJO
				ELSIF ESTADO = "00101000" THEN
					IF LECTURA = "000" THEN
						ESTADO <= "00001000"; --VER QUE BOTON FUE APLANADO
						X <= X - "00011";
					ELSE 
						--HAY UNA FIGURA ABAJO DE EL
						IF X = "00100" THEN
							GAMEOVER <= '1';
							ESTADO   <= "00100010";
						ELSE
							X <= X - 1;
							GAMEOVER <= '0';
							ESTADO <= "00011101"; --CHECAR SI YA ESTA LLENA
						END IF;
					END IF;
				--MOVIMIENTO HACIA ABAJO L VERTICAL
				-------------------------------------------------------------------------------------------------------------
				ELSIF ESTADO = "00101001" THEN
					K <= '0';
					X <= X + 1;
					ESTADO <= "00101010";
				ELSIF ESTADO = "00101010" THEN 
					X <= X +1;
					ESTADO <= "00101011";
				ELSIF ESTADO = "00101011" THEN 
					X <= X - "00011";
					ESTADO <= "00101100";
				ELSIF ESTADO = "00101100" THEN 
					BORRANDO <= '1';
					X <= X - 1;
					ESTADO <= "00101101";
				ELSIF ESTADO = "00101101" THEN
					BORRANDO <= '0';
					WRT_EN <= '0';
					X <= X + "00010";
					ESTADO <= "00000000";
					
				--FIGURA L MOVERSE A LA DERECHA FIGURA L VERTICAL
				-----------------------------------------------------------------------------------------------------------
				ELSIF ESTADO = "00101110" THEN
					KDE <= '0';
					IF Y < 10 THEN
						ESTADO <= "00101111";
						Y <= Y + 1;
					ELSE
						ESTADO <= "00100011";
					END IF;
				ELSIF ESTADO = "00101111" THEN
					IF LECTURA = "000" THEN
						X <= X + 1;
						ESTADO <= "00110000";					
					ELSE
						Y <= Y - 1;
						ESTADO <= "00100011";
					END IF;
				ELSIF ESTADO = "00110000" THEN
					IF LECTURA = "000" THEN
						X <= X + 1;
						ESTADO <= "00110001";
					ELSE
						Y <= Y - 1;
						X <= X - 1;
						ESTADO <= "00100011";
					END IF;
				ELSIF ESTADO = "00110001" THEN
					IF LECTURA = "000" THEN
						X <= X - "00011";
						ESTADO <= "00110010";
					ELSE
						Y <= Y -1;
						X <= X - "00010";
						ESTADO <= "00100011";
					END IF;
				ELSIF ESTADO = "00110010" THEN
					IF LECTURA = "000" THEN
						WRT_EN <= '1';
						ESTADO <= "00110011";
					ELSE
						Y <= Y - 1;
						X <= X + 1;
						ESTADO <= "00100011";
					END IF;
				ELSIF ESTADO = "00110011" THEN
					X <= X + 1;
					ESTADO <= "00110100";
				ELSIF ESTADO = "00110100" THEN
					X <= X + 1;
					ESTADO <= "00110101";
				ELSIF ESTADO = "00110101" THEN
					X <= X + 1;
					ESTADO <= "00110110";
				ELSIF ESTADO = "00110110" THEN
					BORRANDO <= '1';
					Y <= Y - 1;
					ESTADO <= "00110111";
				ELSIF ESTADO = "00110111" THEN
					X <= X - 1;
					ESTADO <= "00111000";
				ELSIF ESTADO = "00111000" THEN
					X <= X - 1;
					ESTADO <= "00111001";
				ELSIF ESTADO = "00111001" THEN
					X <= X - 1;
					ESTADO <= "00111010";
				ELSIF ESTADO = "00111010" THEN
					WRT_EN <= '0';
					BORRANDO <= '0';
					X <= X + 1;
					Y <= Y + 1;
					ESTADO <= "00100011";
				---------------------------------------------------------------------------------------------------
				--MOVIMIENTO A LA IZQUIERDA FIGURA L VERTICAL
				ELSIF ESTADO = "00111011" THEN
					KIZ <= '0';
					IF Y > 1 THEN
						ESTADO <= "00111100";
						Y <= Y - 1;
					ELSE
						ESTADO <= "00100011";
					END IF;
				ELSIF ESTADO = "00111100" THEN
					IF LECTURA = "000" THEN
						X <= X + 1;
						ESTADO <= "00111101";					
					ELSE
						Y <= Y + 1;
						ESTADO <= "00100011";
					END IF;
				ELSIF ESTADO = "00111101" THEN
					IF LECTURA = "000" THEN
						X <= X + 1;
						ESTADO <= "00111110";
					ELSE
						Y <= Y + 1;
						X <= X - 1;
						ESTADO <= "00100011";
					END IF;
				ELSIF ESTADO = "00111110" THEN
					IF LECTURA = "000" THEN
						X <= X - "00011";
						ESTADO <= "00111111";
					ELSE
						Y <= Y + 1;
						X <= X - "00010";
						ESTADO <= "00100011";
					END IF;
				ELSIF ESTADO = "00111111" THEN
					IF LECTURA = "000" THEN
						WRT_EN <= '1';
						ESTADO <= "01000000";
					ELSE
						Y <= Y + 1;
						X <= X + 1;
						ESTADO <= "00100011";
					END IF;
				ELSIF ESTADO = "01000000" THEN
					X <= X + 1;
					ESTADO <= "01000001";
				ELSIF ESTADO = "01000001" THEN
					X <= X + 1;
					ESTADO <= "01000010";
				ELSIF ESTADO = "01000010" THEN
					X <= X + 1;
					ESTADO <= "01000011";
				ELSIF ESTADO = "01000011" THEN
					BORRANDO <= '1';
					Y <= Y + 1;
					ESTADO <= "01000100";
				ELSIF ESTADO = "01000100" THEN
					X <= X - 1;
					ESTADO <= "01000101";
				ELSIF ESTADO = "01000101" THEN
					X <= X - 1;
					ESTADO <= "01000110";
				ELSIF ESTADO = "01000110" THEN
					X <= X - 1;
					ESTADO <= "01000111";
				ELSIF ESTADO = "01000111" THEN
					WRT_EN <= '0';
					BORRANDO <= '0';
					X <= X + 1;
					Y <= Y - 1;
					ESTADO <= "00100011";
				---------------------------------------------------------------------------------------------------
				--ESTADO QUE CREA NUEVOS NUMEROS ALEATORIOS FIGURA L HORIZONTAL
				ELSIF ESTADO = "10000000" THEN
					RESETNA <= '1';
					FIGURA <= NUEVAFIGURA;
					ESTADO <= "00000000";
					ESTADOGIRO <= '0';
					IF Y = "1010" THEN
						Y <= Y - 1;
					ELSE NULL;
					END IF;
				-------------------------------------------------------------------------------------------------------------
				--LLEGASTE AL FONDO FIGURA L HORIZONTAL
				ELSIF ESTADO = "10000001" THEN
					Y <= Y + 1;
					ESTADO <= "10000010";
				ELSIF ESTADO = "10000010" THEN
					Y <= Y + 1;
					ESTADO <= "10000011";
				ELSIF ESTADO = "10000011" THEN
					Y <= Y - "0011";
					ESTADO <= "10000100";
				ELSIF ESTADO = "10000100" THEN
					WRT_EN <= '0';
					Y <= Y+1;
					ESTADO <= "00011101";
				-------------------------------------------------------------------------------------------------------------
				--VERIFICAR QUE NO HAYA NADA ABAJO FIGURA L HORIZONTAL
				ELSIF ESTADO = "10000101" THEN
					IF LECTURA = "000" THEN
						Y <= Y + 1;
						ESTADO <= "10000110";
					ELSE
						IF X = "00010" THEN
							GAMEOVER <= '1';
							ESTADO   <= "00100010";
						ELSE
							X <= X - 1;
							GAMEOVER <= '0';
							ESTADO <= "00011101";
						END IF;
					END IF;
				ELSIF ESTADO = "10000110" THEN 
					IF LECTURA = "000" THEN
						Y <= Y + 1;
						ESTADO <= "10000111";
					ELSE
						IF X = "00010" THEN
							GAMEOVER <= '1';
							ESTADO   <= "00100010";
						ELSE
							X <= X - 1;
							Y <= Y - 1;
							GAMEOVER <= '0';
							ESTADO <= "00011101";
						END IF;
					END IF;
				ELSIF ESTADO = "10000111" THEN
					IF LECTURA = "000" THEN
						Y <= Y - "0011";
						ESTADO <= "10001000";
					ELSE
						IF X = "00010" THEN
							GAMEOVER <= '1';
							ESTADO   <= "00100010";
						ELSE
							X <= X - 1;
							Y <= Y - "0010";
							GAMEOVER <= '0';
							ESTADO <= "00011101";
						END IF;
					END IF;
				ELSIF ESTADO = "10001000" THEN
					IF LECTURA = "000" THEN
						Y <= Y + 1;
						X <= X - 1;
						ESTADO <= "00001000"; -- CHECAR QUE BOTON FUE APLANADO
					ELSE
						IF X = "00010" THEN
							GAMEOVER <= '1';
							ESTADO   <= "00100010";
						ELSE
							X <= X - 1;
							Y <= Y + 1;
							GAMEOVER <= '0';
							ESTADO <= "00011101";
						END IF;
					END IF;
				--MOVIMIENTO VERTICAL DE LA FIGURA L HORIZONTAL
				-----------------------------------------------------------------------------------------------------------
				ELSIF ESTADO = "10001001" THEN
					K <= '0';
					Y <= Y + 1;
					ESTADO <= "10001010";
				ELSIF ESTADO = "10001010" THEN
					Y <= Y + 1;
					ESTADO <= "10001011";
				ELSIF ESTADO = "10001011" THEN
					Y <= Y - "0011";
					ESTADO <= "10001100";
				ELSIF ESTADO = "10001100" THEN
					X <= X - 1;
					BORRANDO <= '1';
					ESTADO <= "10001101";
				ELSIF ESTADO = "10001101" THEN
					Y <= Y + 1;
					ESTADO <= "10001110";
				ELSIF ESTADO = "10001110" THEN
					Y <= Y+ 1;
					ESTADO <= "10001111";
				ELSIF ESTADO = "10001111" THEN
					Y <= Y + 1;
					ESTADO <= "10010000";
				ELSIF ESTADO = "10010000" THEN
					BORRANDO <= '0';
					WRT_EN <= '0';
					Y <= Y - "0010";
					X <= X + 1;
					ESTADO <= "00000000";
				----------------------------------------------------------------------------------------------------------
				--MOVIMIENTO A LA DERECHA FIGURA L HORIZONTAL
				ELSIF ESTADO = "10010001" THEN
					KDE <= '0';
					IF Y < "1000" THEN
						Y <= Y + "0011";
						ESTADO <= "10010010";
					ELSE
						ESTADO <= "00100011";
					END IF;
				ELSIF ESTADO = "10010010" THEN
					IF LECTURA = "000" THEN
						WRT_EN <= '1';
						ESTADO <= "10010011";
					ELSE
						Y <= Y - "0011";
						ESTADO <= "00100011";
					END IF;
				ELSIF ESTADO = "10010011" THEN
					BORRANDO <= '1';
					Y <= Y - "0100";
					ESTADO <= "10010100";
				ELSIF ESTADO = "10010100" THEN
					BORRANDO <= '0';
					WRT_EN <= '0';
					Y <= Y + "0010";
					ESTADO <= "00100011";
				---------------------------------------------------------------------------------------------------------------
				--MOVIMIENTO A LA IZQUIERDA FIGURA L HORIZONTAL
				ELSIF ESTADO = "10010101" THEN
					KIZ <= '0';
					IF Y > "0010" THEN
						Y <= Y - "0010";
						ESTADO <= "10010110";
					ELSE
						ESTADO <= "00100011";
					END IF;
				ELSIF ESTADO = "10010110" THEN
					IF LECTURA = "000" THEN
						WRT_EN <= '1';
						ESTADO <= "10010111";
					ELSE
						Y <= Y + "0010";
						ESTADO <= "00100011";
					END IF;
				ELSIF ESTADO = "10010111" THEN
					BORRANDO <= '1';
					Y <= Y + "0100";
					ESTADO <= "10011000";
				ELSIF ESTADO = "10011000" THEN
					BORRANDO <= '0';
					WRT_EN <= '0';
					Y <= Y - "0011";
					ESTADO <= "00100011";
				---------------------------------------------------------------------------------------------------------------
				--GIRO DE LA FIGURA L DE VERTICAL A HORIZONTAL
				ELSIF ESTADO = "10011001" THEN
					KGIRO <= '0';
					IF(Y > "0001" AND Y < "1001") THEN
						Y <= Y + 1;
						ESTADO <= "10011010";
					ELSE
						ESTADO <= "00000000";
					END IF;
				ELSIF ESTADO = "10011010" THEN
					IF LECTURA = "000" THEN
						Y <= Y + 1;
						ESTADO <= "10011011";
					ELSE
						Y <= Y - 1;
						ESTADO <= "00000000";
					END IF;
				ELSIF ESTADO = "10011011" THEN
					IF LECTURA = "000" THEN
						Y <= Y - "0011";
						ESTADO <= "10011100";
					ELSE
						Y <= Y - "0010";
						ESTADO <= "00000000";
					END IF;
				ELSIF ESTADO  = "10011100" THEN
					IF LECTURA = "000" THEN
						WRT_EN <= '1';
						ESTADO <= "10011101";
					ELSE
						Y <= Y + 1;
						ESTADO <= "00000000";
					END IF;
				ELSIF ESTADO = "10011101" THEN
					Y <= Y + "0010";
					ESTADO <= "10011110";
				ELSIF ESTADO = "10011110" THEN
					Y <= Y + 1;
					ESTADO <= "10011111";
				ELSIF ESTADO = "10011111" THEN
					BORRANDO <= '1';
					Y <= Y - "0010";
					X <= X - 1;
					ESTADO <= "10100000";
				ELSIF ESTADO = "10100000" THEN
					X <= X + "00010";
					ESTADO <= "10100001";
				ELSIF ESTADO <= "10100001" THEN
					X <= X + 1;
					ESTADO <= "10100010";
				ELSIF ESTADO <= "10100010" THEN
					WRT_EN <= '0';
					BORRANDO <= '0';
					ESTADOGIRO <= '1';
					X <= X - "00010";
					ESTADO <= "00000000";
				--------------------------------------------------------------------------------------------------------------
				--ESTADO GIRO FIGURA L DE HORIZONTAL A VERTICAL
				ELSIF ESTADO = "10100011" THEN
					KGIRO <= '0';
					IF(X > "00001" AND X < "10001") THEN
						X <= X + 1;
						ESTADO <= "10100100";
					ELSE
						ESTADO <= "00000000";
					END IF;
				ELSIF ESTADO = "10100100" THEN
					IF LECTURA = "000" THEN
						X <= X + 1;
						ESTADO <= "10100101";
					ELSE
						X <= X - 1;
						ESTADO <= "00000000";
					END IF;
				ELSIF ESTADO = "10100101" THEN
					IF LECTURA = "000" THEN
						X <= X - "0011";
						ESTADO <= "10100110";
					ELSE
						X <= X - "0010";
						ESTADO <= "00000000";
					END IF;
				ELSIF ESTADO  = "10100110" THEN
					IF LECTURA = "000" THEN
						WRT_EN <= '1';
						ESTADO <= "10100111";
					ELSE
						X <= X + 1;
						ESTADO <= "00000000";
					END IF;
				ELSIF ESTADO = "10100111" THEN
					X <= X + "0010";
					ESTADO <=  "10101000";
				ELSIF ESTADO = "10101000" THEN
					X <= X + 1;
					ESTADO <= "10101001";
				ELSIF ESTADO = "10101001" THEN
					BORRANDO <= '1';
					X <= X - "0010";
					Y <= Y - 1;
					ESTADO <= "10101010";
				ELSIF ESTADO = "10101010" THEN
					Y <= Y + "00010";
					ESTADO <= "10101011";
				ELSIF ESTADO <= "10101011" THEN
					Y <= Y + 1;
					ESTADO <= "10101100";
				ELSIF ESTADO <= "10101100" THEN
					WRT_EN <= '0';
					BORRANDO <= '0';
					ESTADOGIRO <= '0';
					Y <= Y - "00010";
					ESTADO <= "00000000";
				-------------------------------------------------------------------------------------------------------------
				
				--CUALQUIER INICIO DE ESTADO RARO SE REINICIA AL ESTADO CERO
				ELSE ESTADO <= "00000000";

				END IF;
			ELSE NULL;
			END IF;
	END PROCESS;
	
	--LED INDICADOR
	LEDIN <= LLENO;
	
	
	--BUZZER
	BUZZER <= GAMEOVER;
	abajoFinal <= (abajo and NOT BDOWN ) or ( ABAJO2 AND BDOWN);
	
	--FLIP FLOPS JK PARA BOTONES
	GIRAN: JK PORT MAP(GIRO,KGIRO,QGIRO);
	BAJAR: JK PORT MAP(abajoFinal,K,Q);
	MOVERDERECHA: JK PORT MAP(RIGHT,KDE,QDE);
	MOVERIZQUIERDA: JK PORT MAP(LEFT,KIZ, QIZ);
	
	--DESPLEGA EL PUNTAJE ACTUAL
	PUNTAJES: DISPLAY PORT MAP(CLK500, A, B, C, D, S8, EN);
	
END Behavioral;


