library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity piso is
    Port (
        DIN    : in  STD_LOGIC_VECTOR (1 to 13);
        IN_EN  : in  STD_LOGIC;
        DOUT   : out STD_LOGIC;
        clk    : in  STD_LOGIC;
        OUT_EN : out STD_LOGIC
    );
end piso;

architecture Behavioral of piso is
    signal temp1, temp2, temp3, temp4 : std_logic_vector(1 to 13) := (others => '0');
    signal counter : integer range 0 to 4 := 0;
    signal shift_count : integer range 0 to 52 := 0;
    signal temp : std_logic_vector(1 to 52) := (others => '0');
    signal start_shifting : std_logic := '0';
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if IN_EN = '1' then
                if counter = 0 then
                    temp1 <= DIN;
                    counter <= 1;
                elsif counter = 1 then
                    temp2 <= DIN;
                    counter <= 2;
                elsif counter = 2 then
                    temp3 <= DIN;
                    counter <= 3;
                elsif counter = 3 then
                    temp4 <= DIN;
                    counter <= 4;
                    temp(1 to 13) <= DIN;  
                    temp <= temp1 & temp2 & temp3 & DIN;  
                    start_shifting <= '1';
                    shift_count <= 52;
                end if;
            end if;

            if start_shifting = '1' and shift_count > 0 then
                DOUT <= temp(1);  
                temp <= temp(2 to 52) & '0';  
                OUT_EN <= '1';
                shift_count <= shift_count - 1;
            else
                OUT_EN <= '0';
                DOUT <= '0';
            end if;

        end if;
    end process;
end Behavioral;