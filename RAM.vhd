LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY RAM IS
	PORT ( InRGB : IN  STD_LOGIC_VECTOR (2 downto 0);
		clk: IN STD_LOGIC;
		Wrt_EN: IN STD_LOGIC; -- Write Enable
		ADDRESS: IN STD_LOGIC_VECTOR(8 DOWNTO 0); --Address 8 DOWNTO 5 es horizontal, y lo demas vertical
		OutRGB : OUT  STD_LOGIC_VECTOR (2 downto 0);
		X: IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		Y: IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		LECTURA : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
	);
END RAM;

ARCHITECTURE Behavioral OF RAM IS
	-- Se?ales para memoria
	TYPE MATRIX IS ARRAY(1 to 19, 1 to 10) OF STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL memoria: MATRIX:=(
	("000","000","000","000","000","000","000","000","000","000"),
	("000","000","000","000","000","000","000","000","000","000"),
	("000","000","000","000","000","000","000","000","000","000"),
	("000","000","000","000","000","000","000","000","000","000"),
	("000","000","000","000","000","000","000","000","000","000"),
	("000","000","000","000","000","000","000","000","000","000"),
	("000","000","000","000","000","000","000","000","000","000"),
	("000","000","000","000","000","000","000","000","000","000"),
	("000","000","000","000","000","000","000","000","000","000"),
	("000","000","000","000","000","000","000","000","000","000"),
	("000","000","000","000","000","000","000","000","000","000"),
	("000","000","000","000","000","000","000","000","000","000"),
	("000","000","000","000","000","000","000","000","000","000"),
	("000","000","000","000","000","000","000","000","000","000"),
	("000","000","000","000","000","000","000","000","000","000"),
	("000","000","000","000","000","000","000","000","000","000"),
	("000","000","000","000","000","000","000","000","000","000"),
	("000","000","000","000","000","000","000","000","000","000"),
	("000","000","000","000","000","000","000","000","000","000"));

begin
	

	OutRGB <= memoria(conv_integer(ADDRESS(4 downto 0)),conv_integer(ADDRESS(8 downto 5)));
	LECTURA <= memoria(conv_integer(X),conv_integer(Y));
	PROCESS(CLK)
		BEGIN
			IF rising_edge(CLK) THEN
				IF Wrt_EN = '1' THEN
					memoria(conv_integer(X),conv_integer(Y)) <= InRGB; -- (Y,X)
				ELSE NULL;
				END IF;
  			ELSE NULL;
			END IF;
	END PROCESS;

END Behavioral;

