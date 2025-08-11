library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity sipo is
    Port (
        clk          : in  STD_LOGIC;
        rst          : in  STD_LOGIC;
        serial_in    : in  STD_LOGIC;
        InputRdy     : in  STD_LOGIC;  
        parallel_out : out STD_LOGIC_VECTOR(1 to 13); 
        word_ready   : out STD_LOGIC    
    );
end sipo;

architecture Behavioral of sipo is
    signal shift_reg  : STD_LOGIC_VECTOR(1 to 13) := (others => '0');
    signal out_reg    : STD_LOGIC_VECTOR(1 to 13) := (others => '0');
    signal count      : integer range 0 to 12 := 0;
    signal ready_r    : STD_LOGIC := '0';
begin

    process(clk, rst)
    begin
        if rst = '1' then
            shift_reg  <= (others => '0');
            out_reg    <= (others => '0');
            count      <= 0;
            ready_r    <= '0';
        elsif rising_edge(clk) then
            ready_r <= '0';  
            if InputRdy = '1' then
                shift_reg <= shift_reg(2 to 13) & serial_in;
                if count = 12 then
                    out_reg <= shift_reg(2 to 13) & serial_in; 
                    ready_r <= '1';
                    shift_reg <= (others => '0');
                    count <= 0;
                else
                    count <= count + 1;
                end if;
            end if;
        end if;
    end process;

    parallel_out <= out_reg;
    word_ready   <= ready_r;

end Behavioral;