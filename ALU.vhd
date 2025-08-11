library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ALU is
    Port (
		  --ALU_INPUT : in STD_LOGIC;
        operand_a  : in  STD_LOGIC_VECTOR (1 to 8);
        operand_b  : in  STD_LOGIC_VECTOR (1 to 8);
        func_code  : in  STD_LOGIC_VECTOR (1 to 8) := "00000000";
        result     : out STD_LOGIC_VECTOR (1 to 8)
    );
end ALU;

architecture Behavioral of ALU is
begin
    process(operand_a, operand_b, func_code)
        variable a : unsigned(1 to 8);  
        variable b : unsigned(1 to 8);
        variable r : unsigned(1 to 8);
    begin
        a := unsigned(operand_a);
        b := unsigned(operand_b);
        r := (others => '0');

        case func_code is
            when "00000000" | "00111100" | "11000000" | "00110000" =>
                r := a + b;
            when "00000001" | "00111101" | "11000001" | "00110001" =>
                r := a - b;
            when "00000010" | "00111110" | "11000010" | "00110010" =>
                r := a or b;
            when "00000011" | "00111111" | "11000011" | "00110011" =>
                r := a and b;
            when others =>
                r := (others => '0');
        end case;

        result <= std_logic_vector(r);
    end process;
end Behavioral;