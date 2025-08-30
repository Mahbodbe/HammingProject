LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY controlunit IS
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        data_in : IN STD_LOGIC_VECTOR (1 TO 8);
        ram_read_add : OUT STD_LOGIC_VECTOR (1 TO 8);
        ram_write_data : OUT STD_LOGIC_VECTOR (1 TO 8);
        ram_write_add : OUT STD_LOGIC_VECTOR (1 TO 8);
        ram_data : IN STD_LOGIC_VECTOR (1 TO 8); -- data from RAM
        ram_data_en : IN STD_LOGIC;
        Error : OUT STD_LOGIC;
        read_en : OUT STD_LOGIC;
        write_en : OUT STD_LOGIC;
        valid : IN STD_LOGIC; -- input byte valid
        data_to_alu1 : OUT STD_LOGIC_VECTOR(1 TO 8);
        data_to_alu2 : OUT STD_LOGIC_VECTOR(1 TO 8);
        data_alu : IN STD_LOGIC_VECTOR(1 TO 8); -- ALU result
        data_to_encode : OUT STD_LOGIC_VECTOR(1 TO 32); -- response packet
        alu_function : OUT STD_LOGIC_VECTOR(1 TO 8);
        read_data : OUT STD_LOGIC
    );
END controlunit;

ARCHITECTURE Behavioral OF controlunit IS
    TYPE state_type IS (
        IDLE, -- waiting for packet start
        RECEIVE_FUNC, -- received first byte (function/opcode)
        RECEIVE_PACKET, -- collect remaining packet bytes
        CHECK_CHECKSUM, -- verify checksum
        EXECUTE_OP, -- decode function and begin operation
        WAIT1_READ1, -- de-assert read strobe, wait for RAM
        WAIT2_READ1, -- handle returned RAM data (first read)
        WAIT1_READ2, -- de-assert second read strobe
        WAIT2_READ2, -- handle returned RAM data (second read)
        PERFORM_ALU, -- present operands to ALU
        ALU_WAIT, -- wait for ALU result to appear
        WRITE_SETUP, -- prepare RAM writeback of ALU result
        WRITE_RESULT, -- finish writeback and clear strobe
        SEND_RESPONSE, -- build/send response packet
        ERROR_STATE, -- error handling/indication
        WRITE_RAM, -- single write transaction
        ARRAY_LOOP, -- array processing loop (iterate elements)
        ARRAY_READ_REQ, -- request read of array element
        ARRAY_READ_WAIT, -- wait for array element from RAM
        ARRAY_ALU_WAIT, -- wait for ALU result for array element
        ARRAY_HOLD, -- finish array write and increment index
        ARRAY_ALU, -- start ALU for array element
        ARRAY_WRITE, -- write array element result back to RAM
        INDIRECT_WAIT1, -- wait stage after first indirect read
        INDIRECT_WAIT2, -- fetch indirect address and issue read
        INDIRECT_WAIT21, -- de-assert read strobe for indirect
        INDIRECT_WAIT22 -- handle returned indirect-read data
    );
    SIGNAL state : state_type := IDLE;

    TYPE packet_array IS ARRAY (1 TO 7) OF STD_LOGIC_VECTOR(1 TO 8);
    SIGNAL packet_data : packet_array;

    SIGNAL byte_count : INTEGER RANGE 0 TO 7 := 0;
    SIGNAL packet_length : INTEGER RANGE 0 TO 7 := 0;
    SIGNAL checksum_calc : unsigned(1 TO 16) := (OTHERS => '0');
    SIGNAL func : STD_LOGIC_VECTOR(1 TO 8) := (OTHERS => '0');

    SIGNAL addr1 : STD_LOGIC_VECTOR(1 TO 8) := (OTHERS => '0');
    SIGNAL addr2 : STD_LOGIC_VECTOR(1 TO 8) := (OTHERS => '0');
    SIGNAL dest_addr : STD_LOGIC_VECTOR(1 TO 8) := (OTHERS => '0');
    SIGNAL data : STD_LOGIC_VECTOR(1 TO 8) := (OTHERS => '0');
    SIGNAL length : STD_LOGIC_VECTOR(1 TO 8) := (OTHERS => '0');

    SIGNAL alu_op1 : STD_LOGIC_VECTOR(1 TO 8) := (OTHERS => '0');
    SIGNAL alu_op2 : STD_LOGIC_VECTOR(1 TO 8) := (OTHERS => '0');

    SIGNAL current_index : unsigned(1 TO 8) := (OTHERS => '0');
    SIGNAL temp_addr : STD_LOGIC_VECTOR(1 TO 8) := (OTHERS => '0');
    SIGNAL temp_addr_2 : STD_LOGIC_VECTOR(1 TO 8) := (OTHERS => '0');

    SIGNAL alu_res : STD_LOGIC_VECTOR(1 TO 8) := (OTHERS => '0');
    CONSTANT Read_function_r : STD_LOGIC_VECTOR(1 TO 8) := "11001111";
BEGIN
    PROCESS (clk, reset)
        VARIABLE temp_sum : unsigned(1 TO 16);
        VARIABLE sum_slv : STD_LOGIC_VECTOR(1 TO 16); -- NEW
    BEGIN
        IF reset = '1' THEN
            state <= IDLE;
            byte_count <= 0;
            checksum_calc <= (OTHERS => '0');
            read_en <= '0';
            write_en <= '0';
            Error <= '0';
            data_to_alu1 <= (OTHERS => '0');
            data_to_alu2 <= (OTHERS => '0');
            alu_function <= (OTHERS => '0');
            ram_read_add <= (OTHERS => '0');
            ram_write_add <= (OTHERS => '0');
            ram_write_data <= (OTHERS => '0');
            data_to_encode <= (OTHERS => '0');
            current_index <= (OTHERS => '0');
            read_data <= '0';
        ELSIF rising_edge(clk) THEN
            CASE state IS
                WHEN IDLE =>
                    checksum_calc <= (OTHERS => '0');
                    byte_count <= 0;
                    read_en <= '0';
                    write_en <= '0';
                    Error <= '0';
                    IF valid = '1' THEN
                        func <= data_in;
                        packet_data(1) <= data_in;
                        checksum_calc <= resize(unsigned(data_in), 16);
                        byte_count <= 1;
                        state <= RECEIVE_FUNC;
                    END IF;

                WHEN RECEIVE_FUNC =>
                    CASE func IS
                        WHEN "00000000" | "00000001" | "00000010" | "00000011" =>
                            packet_length <= 6; -- Operand ALU
                        WHEN "11110000" =>
                            packet_length <= 5; -- Write
                        WHEN "00001111" =>
                            packet_length <= 4; -- Read
                        WHEN "00111100" | "00111101" | "00111110" | "00111111" =>
                            packet_length <= 6; -- Immediate ALU
                        WHEN "11000000" | "11000001" | "11000010" | "11000011" =>
                            packet_length <= 7; -- Array ALU
                        WHEN "00110000" | "00110001" | "00110010" | "00110011" =>
                            packet_length <= 6; -- Indirect
                        WHEN OTHERS =>
                            state <= IDLE; -- Invalid function
                    END CASE;
                    state <= RECEIVE_PACKET;

                WHEN RECEIVE_PACKET =>
                    IF valid = '1' THEN
                        byte_count <= byte_count + 1;
                        packet_data(byte_count + 1) <= data_in;
                        IF (byte_count + 1) <= (packet_length - 2) THEN
                            checksum_calc <= checksum_calc + resize(unsigned(data_in), 16);
                        END IF;
                        IF (byte_count + 1) = packet_length THEN
                            state <= CHECK_CHECKSUM;
                        END IF;
                    END IF;
                WHEN CHECK_CHECKSUM =>
                    IF STD_LOGIC_VECTOR(checksum_calc) =
                        (packet_data(packet_length - 1) & packet_data(packet_length)) THEN
                        state <= EXECUTE_OP;
                    ELSE
                        Error <= '1';
                        state <= ERROR_STATE;
                    END IF;

                WHEN ERROR_STATE =>
                    Error <= '0';
                    state <= IDLE;

                WHEN EXECUTE_OP =>
                    func <= packet_data(1);
                    IF packet_data(1) = "11110000" THEN -- Write
                        ram_write_add <= packet_data(2); -- Address 1
                        ram_write_data <= packet_data(3); -- data
                        write_en <= '1';
                        state <= WRITE_RAM;
                    ELSIF packet_data(1) = "00001111" THEN -- Read
                        ram_read_add <= packet_data(2); -- response packet
                        read_en <= '1';
                        state <= WAIT1_READ1;
                    ELSIF packet_data(1)(1 TO 4) = "0000" AND packet_data(1)(5 TO 8) <= "0011" THEN -- Operand ALU
                        addr1 <= packet_data(2); -- Address 1
                        addr2 <= packet_data(3); -- Address 2
                        dest_addr <= packet_data(4); -- Destination Address
                        ram_read_add <= packet_data(2);
                        read_en <= '1';
                        state <= WAIT1_READ1;
                    ELSIF packet_data(1)(1 TO 4) = "0011" AND packet_data(1)(5 TO 8) >= "1100" THEN -- Immediate ALU
                        addr1 <= packet_data(2); -- Address 1
                        data <= packet_data(3); -- Data
                        dest_addr <= packet_data(4); -- Destination Address
                        ram_read_add <= packet_data(2);
                        read_en <= '1';
                        state <= WAIT1_READ1;
                    ELSIF packet_data(1)(1 TO 4) = "1100" THEN -- Array ALU
                        addr1 <= packet_data(2); -- Address 1
                        data <= packet_data(3); -- Data
                        length <= packet_data(4); -- length 
                        dest_addr <= packet_data(5); -- Destination Address
                        current_index <= (OTHERS => '0');
                        state <= ARRAY_LOOP;
                    ELSIF packet_data(1)(1 TO 4) = "0011" AND packet_data(1)(5 TO 8) <= "0011" THEN -- Indirect
                        addr1 <= packet_data(2); -- Address 1
                        data <= packet_data(3); -- Data
                        dest_addr <= packet_data(4); -- Destination Address
                        ram_read_add <= packet_data(2);
                        read_en <= '1';
                        state <= INDIRECT_WAIT1;
                    END IF;

                WHEN WRITE_RAM =>
                    write_en <= '0';
                    state <= IDLE;

                WHEN WAIT1_READ1 =>
                    read_en <= '0';
                    state <= WAIT2_READ1;

                WHEN WAIT2_READ1 =>
                    IF ram_data_en = '1' THEN
                        alu_op1 <= ram_data;
                        IF func = "00001111" THEN -- For Read
                            temp_sum := resize(unsigned(Read_function_r), 16) + resize(unsigned(ram_data), 16);

                            data_to_encode(1 TO 8) <= Read_function_r;
                            data_to_encode(9 TO 16) <= ram_data;

                            sum_slv := STD_LOGIC_VECTOR(temp_sum);
                            data_to_encode(17 TO 24) <= sum_slv(1 TO 8); -- ChkH
                            data_to_encode(25 TO 32) <= sum_slv(9 TO 16); -- ChkL

                            state <= SEND_RESPONSE;

                        ELSIF func(1 TO 4) = "0011" AND func(5 TO 8) >= "1100" THEN -- Immediate
                            alu_op2 <= data;
                            alu_function <= func;
                            state <= PERFORM_ALU;

                        ELSE -- Operand
                            ram_read_add <= addr2;
                            read_en <= '1';
                            state <= WAIT1_READ2;
                        END IF;
                    END IF;
                WHEN WAIT1_READ2 =>
                    read_en <= '0';
                    state <= WAIT2_READ2;

                WHEN WAIT2_READ2 =>
                    IF ram_data_en = '1' THEN
                        alu_op2 <= ram_data;
                        alu_function <= func;
                        state <= PERFORM_ALU;
                    END IF;

                WHEN PERFORM_ALU =>
                    data_to_alu1 <= alu_op1;
                    data_to_alu2 <= alu_op2;
                    state <= ALU_WAIT;

                WHEN ALU_WAIT =>
                    alu_res <= data_alu;
                    state <= WRITE_SETUP;

                WHEN WRITE_SETUP =>
                    ram_write_add <= dest_addr;
                    ram_write_data <= alu_res;
                    write_en <= '1';
                    state <= WRITE_RESULT;

                WHEN WRITE_RESULT =>
                    write_en <= '0';
                    state <= IDLE;

                WHEN SEND_RESPONSE =>
                    read_data <= '1'; -- Trigger sending using read_en as per top module
                    state <= IDLE;

                WHEN ARRAY_LOOP =>
                    IF current_index < unsigned(length) THEN
                        temp_addr <= STD_LOGIC_VECTOR(unsigned(addr1) + current_index);
                        ram_read_add <= temp_addr;
                        read_en <= '1';
                        state <= ARRAY_READ_REQ;
                    ELSE
                        state <= IDLE;
                    END IF;

                WHEN ARRAY_READ_REQ =>
                    read_en <= '0';
                    state <= ARRAY_READ_WAIT;

                WHEN ARRAY_READ_WAIT =>
                    IF ram_data_en = '1' THEN
                        alu_op1 <= ram_data;
                        alu_op2 <= data;
                        alu_function <= func;
                        state <= ARRAY_ALU;
                    END IF;

                WHEN ARRAY_ALU =>
                    data_to_alu1 <= alu_op1;
                    data_to_alu2 <= alu_op2;
                    state <= ARRAY_ALU_WAIT;

                WHEN ARRAY_ALU_WAIT =>
                    alu_res <= data_alu;
                    temp_addr_2 <= STD_LOGIC_VECTOR(unsigned(dest_addr) + current_index);
                    state <= ARRAY_WRITE;
                WHEN ARRAY_WRITE =>
                    ram_write_add <= temp_addr_2;
                    ram_write_data <= data_alu;
                    write_en <= '1';
                    state <= ARRAY_HOLD;

                WHEN ARRAY_HOLD =>
                    write_en <= '0';
                    current_index <= current_index + 1;
                    state <= ARRAY_LOOP;

                WHEN INDIRECT_WAIT1 =>
                    read_en <= '0';
                    state <= INDIRECT_WAIT2;

                WHEN INDIRECT_WAIT2 =>
                    IF ram_data_en = '1' THEN
                        ram_read_add <= ram_data;
                        read_en <= '1';
                        state <= INDIRECT_WAIT21;
                    END IF;

                WHEN INDIRECT_WAIT21 =>
                    read_en <= '0';
                    state <= INDIRECT_WAIT22;

                WHEN INDIRECT_WAIT22 =>
                    IF ram_data_en = '1' THEN
                        alu_op1 <= ram_data;
                        alu_op2 <= data;
                        alu_function <= func;
                        state <= PERFORM_ALU;
                    END IF;

                WHEN OTHERS =>
                    state <= IDLE;
            END CASE;
        END IF;
    END PROCESS;

END Behavioral;