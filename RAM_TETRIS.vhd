LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY RAM_TETRIS IS
    PORT ( InRGB : IN  STD_LOGIC_VECTOR (2 downto 0);
				  clk: IN STD_LOGIC;
				  Wrt_EN: IN STD_LOGIC; -- Write Enable
				  ADDRESS: IN STD_LOGIC_VECTOR(8 DOWNTO 0);
				  GAMEOVER: IN STD_LOGIC;
				  OutRGB : OUT  STD_LOGIC_VECTOR (2 downto 0)
			  );
END RAM_TETRIS;

ARCHITECTURE Behavioral OF RAM_TETRIS IS
	-- Se?ales para memoria
	TYPE MATRIX IS ARRAY(1 to 8, 1 to 31) OF STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL memoria: MATRIX:=(
	("111","010","010","010","010","010","010","010","010","010","010","010","010","010","010","010","010","010","010","010","010","010","010","010","010","010","010","010","010","010","111"),
	("010","100","100","100","100","100","100","001","001","001","100","100","100","100","100","100","110","110","110","110","000","011","011","011","011","011","101","101","101","101","010"),
	("010","100","100","100","100","100","100","001","001","000","100","100","100","100","100","100","110","110","000","000","110","011","011","011","011","011","101","000","000","000","010"),
	("010","000","000","100","100","000","000","001","001","001","000","000","100","100","000","000","110","110","000","000","110","000","000","011","000","000","101","101","101","101","010"),
	("010","000","000","100","100","000","000","001","001","000","000","000","100","100","000","000","110","110","110","110","000","000","000","011","000","000","000","000","000","101","010"),
	("010","000","000","100","100","000","000","001","001","001","000","000","100","100","000","000","110","110","000","000","110","011","011","011","011","011","000","000","000","101","010"),
	("010","000","000","100","100","000","000","001","001","001","000","000","100","100","000","000","110","110","000","000","110","011","011","011","011","011","101","101","101","101","010"),
	("111","010","010","010","010","010","010","010","010","010","010","010","010","010","010","010","010","010","010","010","010","010","010","010","010","010","010","010","010","010","111"));

begin
	
	PROCESS(CLK)
		BEGIN
			IF rising_edge(CLK) THEN
				IF Wrt_EN = '1' THEN
					memoria(conv_integer(ADDRESS(3 downto 0)),conv_integer(ADDRESS(8 downto 4))) <= InRGB; -- (Y,X)
				ELSE
					if GAMEOVER = '1' then
					memoria <= (
					("111","111","111","111","111","111","111","111","111","111","111","111","111","111","111","111","111","111","111","111","111","111","111","111","111","111","111","111","111","111","111"),
					("100","100","100","100","001","001","001","001","100","000","000","000","100","001","001","001","100","100","100","001","000","000","000","001","100","100","100","001","001","001","000"),
					("100","000","000","000","001","000","000","001","100","100","000","100","100","001","000","000","100","000","100","001","000","000","000","001","100","000","000","001","000","000","001"),
					("100","000","000","000","001","000","000","001","100","000","100","000","100","001","001","001","100","000","100","001","000","000","000","001","100","100","100","001","000","000","001"),
					("100","000","100","100","001","001","001","001","100","000","100","000","100","001","000","000","100","000","100","001","000","000","000","001","100","000","000","001","001","001","000"),
					("100","000","000","100","001","000","000","001","100","000","000","000","100","001","000","000","100","000","100","000","001","000","001","000","100","000","000","001","000","000","001"),
					("100","100","100","100","001","000","000","001","100","000","000","000","100","001","001","001","100","100","100","000","000","001","000","000","100","100","100","001","000","000","001"),
					("111","111","111","111","111","111","111","111","111","111","111","111","111","111","111","111","111","111","111","111","111","111","111","111","111","111","111","111","111","111","111"));
	
					else memoria <= (("111","010","010","010","010","010","010","010","010","010","010","010","010","010","010","010","010","010","010","010","010","010","010","010","010","010","010","010","010","010","111"),
					("010","100","100","100","100","100","100","001","001","001","100","100","100","100","100","100","110","110","110","110","000","011","011","011","011","011","101","101","101","101","010"),
					("010","100","100","100","100","100","100","001","001","000","100","100","100","100","100","100","110","110","000","000","110","011","011","011","011","011","101","000","000","000","010"),
					("010","000","000","100","100","000","000","001","001","001","000","000","100","100","000","000","110","110","000","000","110","000","000","011","000","000","101","101","101","101","010"),
					("010","000","000","100","100","000","000","001","001","000","000","000","100","100","000","000","110","110","110","110","000","000","000","011","000","000","000","000","000","101","010"),
					("010","000","000","100","100","000","000","001","001","001","000","000","100","100","000","000","110","110","000","000","110","011","011","011","011","011","000","000","000","101","010"),
					("010","000","000","100","100","000","000","001","001","001","000","000","100","100","000","000","110","110","000","000","110","011","011","011","011","011","101","101","101","101","010"),
					("111","010","010","010","010","010","010","010","010","010","010","010","010","010","010","010","010","010","010","010","010","010","010","010","010","010","010","010","010","010","111"));
					end if;
					
					OutRGB <= memoria(conv_integer(ADDRESS(3 downto 0)),conv_integer(ADDRESS(8 downto 4)));
				END IF;
  			ELSE NULL;
			END IF;
	END PROCESS;
	
		


END Behavioral;


--("000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000"),
--	("000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000"),
--	("000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000"),
--	("000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000"),
--	("000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000"),
--	("000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000"),
--	("000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000"),
--	("000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000"));

