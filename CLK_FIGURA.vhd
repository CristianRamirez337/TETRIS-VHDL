library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

entity CLK_FIGURA is
  port (clock : in std_logic;
        Clock_segundo : out std_logic
  ) ;
end CLK_FIGURA;

architecture comportamiento of CLK_FIGURA is
    signal cont : std_logic_vector(25 downto 0) := (OTHERS => '0');
    signal clockout : std_logic;
	 
begin
    process( clock )
    begin
        if clock = '1' and clock'event then
            if cont = 5_500_000 then
                clockout <= not clockout;
                cont <= "00000000000000000000000000";
            else cont <= cont + '1';
            end if ;
        else null;
        end if ;
    end process ;

    clock_segundo <= clockout;

end comportamiento;