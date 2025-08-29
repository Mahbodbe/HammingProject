LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY packet IS
    PORT (
        inputRdy : IN STD_LOGIC;
        RST : IN STD_LOGIC;
        input : IN STD_LOGIC;
        output : OUT STD_LOGIC;
        outputRdy : OUT STD_LOGIC;
        clk : IN STD_LOGIC;
        error : OUT STD_LOGIC
    );
END packet;

ARCHITECTURE Behavioral OF packet IS
 
    COMPONENT encoder
        PORT (
            data : IN STD_LOGIC_VECTOR (1 TO 8);
            odd_mode : IN STD_LOGIC;
            data_out : OUT STD_LOGIC_VECTOR (1 TO 13)
        );
    END COMPONENT;

    COMPONENT decoder
        PORT (
            data : IN STD_LOGIC_VECTOR (1 TO 13);
            data_out : OUT STD_LOGIC_VECTOR (1 TO 8);
            valid : OUT STD_LOGIC
        );
    END COMPONENT;

    COMPONENT ram8x32
        PORT (
            clk : IN STD_LOGIC;
            rst : IN STD_LOGIC;
            writeEn : IN STD_LOGIC;
            readEn : IN STD_LOGIC;
            writeAdr : IN STD_LOGIC_VECTOR (1 TO 5);
            readAdr : IN STD_LOGIC_VECTOR (1 TO 5);
            wr_data : IN STD_LOGIC_VECTOR (1 TO 8);
            output : OUT STD_LOGIC_VECTOR (1 TO 8);
            outputRdy : OUT STD_LOGIC
        );
    END COMPONENT;

    COMPONENT ALU
        PORT (
            operand_a : IN STD_LOGIC_VECTOR (1 TO 8);
            operand_b : IN STD_LOGIC_VECTOR (1 TO 8);
            func_code : IN STD_LOGIC_VECTOR (1 TO 8);
            result : OUT STD_LOGIC_VECTOR (1 TO 8)
        );
    END COMPONENT;

    COMPONENT controlunit IS
        PORT (
            clk : IN STD_LOGIC;
            reset : IN STD_LOGIC;
            data_in : IN STD_LOGIC_VECTOR (1 TO 8);
            ram_read_add : OUT STD_LOGIC_VECTOR (1 TO 8);
            ram_write_data : OUT STD_LOGIC_VECTOR (1 TO 8);
            ram_write_add : OUT STD_LOGIC_VECTOR (1 TO 8);
            ram_data : IN STD_LOGIC_VECTOR (1 TO 8);
            Error : OUT STD_LOGIC;
            ram_data_en : IN STD_LOGIC;
            read_en : OUT STD_LOGIC;
            write_en : OUT STD_LOGIC;
            valid : IN STD_LOGIC;
            data_to_alu1 : OUT STD_LOGIC_VECTOR(1 TO 8);
            data_to_alu2 : OUT STD_LOGIC_VECTOR(1 TO 8);
            data_alu : IN STD_LOGIC_VECTOR(1 TO 8);
            data_to_encode : OUT STD_LOGIC_VECTOR(1 TO 32);
            alu_function : OUT STD_LOGIC_VECTOR(1 TO 8);
            read_data : OUT STD_LOGIC

        );
    END COMPONENT;

    COMPONENT sipo IS
        PORT (
            clk : IN STD_LOGIC;
            rst : IN STD_LOGIC;
            serial_in : IN STD_LOGIC;
            InputRdy : IN STD_LOGIC;
            parallel_out : OUT STD_LOGIC_VECTOR(1 TO 13);
            word_ready : OUT STD_LOGIC
        );
    END COMPONENT;

    COMPONENT devider IS
        PORT (
            DIN : IN STD_LOGIC_VECTOR (1 TO 32);
            DOUT : OUT STD_LOGIC_VECTOR (1 TO 8);
            clk : IN STD_LOGIC;
            enable : IN STD_LOGIC;
            out_en : OUT STD_LOGIC
        );
    END COMPONENT;

    COMPONENT piso IS
        PORT (
            DIN : IN STD_LOGIC_VECTOR (1 TO 13);
            IN_EN : IN STD_LOGIC;
            DOUT : OUT STD_LOGIC;
            clk : IN STD_LOGIC;
            OUT_EN : OUT STD_LOGIC
        );
    END COMPONENT;
    SIGNAL data_out_c : STD_LOGIC_VECTOR(1 TO 8);
    SIGNAL data_out_s : STD_LOGIC_VECTOR(1 TO 13) := (OTHERS => '0');

    SIGNAL ram_write_en : STD_LOGIC;
    SIGNAL ram_write_add : STD_LOGIC_VECTOR(1 TO 8);
    SIGNAL ram_write_data : STD_LOGIC_VECTOR(1 TO 8);
    SIGNAL ram_readRDY : STD_LOGIC;
    SIGNAL to_encode_en : STD_LOGIC := '0';
    SIGNAL to_ram_en : STD_LOGIC := '0';
    SIGNAL ram_read_add : STD_LOGIC_VECTOR(1 TO 8);
    SIGNAL ram_read_data : STD_LOGIC_VECTOR(1 TO 8);
    SIGNAL alu_data1 : STD_LOGIC_VECTOR(1 TO 8);
    SIGNAL alu_data2 : STD_LOGIC_VECTOR(1 TO 8);
    SIGNAL alu_function : STD_LOGIC_VECTOR(1 TO 8);
    SIGNAL alu_res : STD_LOGIC_VECTOR(1 TO 8);
    SIGNAL error_signal : STD_LOGIC;
    SIGNAL data_to_encode2 : STD_LOGIC_VECTOR(1 TO 32);

    SIGNAL word13 : STD_LOGIC_VECTOR(1 TO 13);
    SIGNAL word_ready : STD_LOGIC;
    SIGNAL decoded_comb : STD_LOGIC_VECTOR(1 TO 8);
    SIGNAL valid_comb : STD_LOGIC;

    SIGNAL data_in_c_reg : STD_LOGIC_VECTOR(1 TO 8) := (OTHERS => '0');
    SIGNAL valid_c_reg : STD_LOGIC := '0';
    SIGNAL send_pulse : STD_LOGIC := '0';
BEGIN
    bb0 : sipo
    PORT MAP(
        clk => clk,
        rst => RST,
        serial_in => input,
        InputRdy => inputRdy,
        parallel_out => word13,
        word_ready => word_ready
    );

    bb1 : encoder
    PORT MAP(
        data => data_out_c,
        odd_mode => '0',
        data_out => data_out_s
    );

    bb2 : decoder
    PORT MAP(
        data => word13,
        data_out => decoded_comb,
        valid => valid_comb
    );

    bb3 : ram8x32
    PORT MAP(
        clk => clk,
        rst => RST,
        writeEn => ram_write_en,
        readEn => to_ram_en,
        writeAdr => ram_write_add(4 TO 8),
        readAdr => ram_read_add(4 TO 8),
        wr_data => ram_write_data,
        output => ram_read_data,
        outputRdy => ram_readRDY
    );

    bb4 : ALU
    PORT MAP(
        operand_a => alu_data1,
        operand_b => alu_data2,
        func_code => alu_function,
        result => alu_res
    );

    bb5 : controlunit
    PORT MAP(
        clk => clk,
        reset => RST,
        valid => valid_c_reg,
        data_in => data_in_c_reg,
        write_en => ram_write_en,
        ram_write_add => ram_write_add,
        ram_write_data => ram_write_data,
        read_en => to_ram_en,
        read_data => to_encode_en,
        ram_data_en => ram_readRDY,
        ram_read_add => ram_read_add,
        ram_data => ram_read_data,
        data_to_alu1 => alu_data1,
        data_to_alu2 => alu_data2,
        alu_function => alu_function,
        data_alu => alu_res,
        Error => error_signal,
        data_to_encode => data_to_encode2
    );

    bb6 : devider
    PORT MAP(
        clk => clk,
        DIN => data_to_encode2,
        DOUT => data_out_c,
        enable => to_encode_en,
        out_en => send_pulse
    );
    bb7 : piso
    PORT MAP(
        clk => clk,
        DIN => data_out_s,
        IN_EN => send_pulse,
        DOUT => output,
        OUT_EN => outputRdy
    );

    PROCESS (clk, RST)
    BEGIN
        IF RST = '1' THEN
            data_in_c_reg <= (OTHERS => '0');
            valid_c_reg <= '0';
        ELSIF rising_edge(clk) THEN
            valid_c_reg <= '0';
            IF word_ready = '1' THEN
                data_in_c_reg <= decoded_comb;
                IF valid_comb = '1' THEN
                    valid_c_reg <= '1';
                END IF;
            END IF;
        END IF;
    END PROCESS;

    error <= error_signal;

END Behavioral;