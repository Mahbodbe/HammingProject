library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RAM8x32 is
    Port (
        clk         : in  STD_LOGIC;
        rst         : in  STD_LOGIC;
        writeEn     : in  STD_LOGIC;
        readEn      : in  STD_LOGIC;
        writeAdr    : in  STD_LOGIC_VECTOR (1 to 5); -- 32 = 2^5
        readAdr     : in  STD_LOGIC_VECTOR (1 to 5);
        wr_data     : in  STD_LOGIC_VECTOR (1 to 8);
        output      : out STD_LOGIC_VECTOR (1 to 8);
        outputRdy   : out STD_LOGIC
    );
end RAM8x32;

architecture Behavioral of RAM8x32 is
    type ram_type is array(0 to 31) of STD_LOGIC_VECTOR(1 to 8);
    signal RAM : ram_type ;
    signal read_counter : integer range 0 to 1 := 0;  
    signal read_pending : std_logic := '0';
    signal read_address_latched : STD_LOGIC_VECTOR (1 to 5);
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                RAM <= (others => (others => '0'));
                output <= (others => '0');
                outputRdy <= '0';
                read_counter <= 0;
                read_pending <= '0';
                read_address_latched <= (others => '0');
            else
                if writeEn = '1' then
                    RAM(to_integer(unsigned(writeAdr))) <= wr_data;
                end if;

                if readEn = '1' then
                    read_pending <= '1';
                    read_counter <= 1;  
                    read_address_latched <= readAdr;
                    outputRdy <= '0';
                elsif read_pending = '1' then
                    if read_counter > 0 then
                        read_counter <= read_counter - 1;
                        outputRdy <= '0';
                    else
                        output <= RAM(to_integer(unsigned(read_address_latched)));
                        outputRdy <= '1';
                        read_pending <= '0';
                    end if;
                else
                    outputRdy <= '0';
                end if;
            end if;
        end if;
    end process;
end Behavioral;