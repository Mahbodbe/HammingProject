library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity devider is
    Port (
        DIN     : in  STD_LOGIC_VECTOR (1 to 32);
        DOUT    : out STD_LOGIC_VECTOR (1 to 8);
        clk     : in  STD_LOGIC;
        enable  : in  STD_LOGIC;
        out_en  : out STD_LOGIC
    );
end devider;

architecture Behavioral of devider is

signal idx   : integer range 0 to 3 := 0;
signal busy  : std_logic := '0';
signal one_R : std_logic := '1';

begin

process(clk)
begin
	if rising_edge(clk) then
		out_en <= '0';
		if busy = '0' then
			if enable = '1' and one_R = '1' then
				busy   <= '1';
				idx    <= 0;
				DOUT   <= DIN(1 to 8);
				out_en <= '1';
			end if;
		elsif busy = '1' and one_R = '1' then
			case idx is
				when 0 =>
				DOUT <= DIN(9 to 16);  out_en <= '1'; idx <= 1;
				when 1 =>
				DOUT <= DIN(17 to 24); out_en <= '1'; idx <= 2;
				when 2 =>
				DOUT <= DIN(25 to 32); out_en <= '1'; idx <= 3;
				when others =>
				one_R <= '0';
				busy <= '0';
			end case;
		end if;
	end if;
end process;
end Behavioral;