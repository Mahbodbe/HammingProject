library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity controlunit is
    Port (
        clk             : in STD_LOGIC;
        reset           : in STD_LOGIC;
        data_in         : in  STD_LOGIC_VECTOR (1 to 8);
        ram_read_add    : out  STD_LOGIC_VECTOR (1 to 8);
        ram_write_data  : out  STD_LOGIC_VECTOR (1 to 8);
        ram_write_add   : out  STD_LOGIC_VECTOR (1 to 8);
        ram_data        : in  STD_LOGIC_VECTOR (1 to 8);
		  ram_data_en 		: in STD_LOGIC;
        Error           : out STD_LOGIC;
        read_en         : out STD_LOGIC;
        write_en        : out STD_LOGIC;
        valid           : in STD_LOGIC;
        data_to_alu1    : out STD_LOGIC_VECTOR(1 to 8);
        data_to_alu2    : out STD_LOGIC_VECTOR(1 to 8);
        data_alu        : in STD_LOGIC_VECTOR(1 to 8);
        data_to_encode  : out STD_LOGIC_VECTOR(1 to 32);
        alu_function    : out STD_LOGIC_VECTOR(1 to 8);
		  read_data			: out STD_LOGIC
    );
end controlunit;

architecture Behavioral of controlunit is
    type state_type is (
        IDLE, RECEIVE_FUNC, RECEIVE_PACKET, CHECK_CHECKSUM, EXECUTE_OP,
        READ_ADDR1, WAIT1_READ1, WAIT2_READ1,
        READ_ADDR2, WAIT1_READ2, WAIT2_READ2,
        PERFORM_ALU,ALU_WAIT, WRITE_SETUP, WRITE_RESULT,
        SEND_RESPONSE,
        ERROR_STATE,
        WRITE_RAM,
        ARRAY_LOOP, ARRAY_READ_REQ, ARRAY_READ_WAIT, ARRAY_ALU_WAIT, ARRAY_HOLD, ARRAY_ALU, ARRAY_WRITE,
        INDIRECT_READ1, INDIRECT_WAIT1, INDIRECT_WAIT2,
        INDIRECT_READ2, INDIRECT_WAIT21, INDIRECT_WAIT22
    );
    signal state : state_type := IDLE;

    type packet_array is array (1 to 7) of STD_LOGIC_VECTOR(1 to 8);
    signal packet_data : packet_array;

    signal byte_count : integer range 0 to 7 := 0;
    signal packet_length : integer range 0 to 7 := 0;
    signal checksum_calc : unsigned(1 to 16) := (others => '0');
    signal func_reg : STD_LOGIC_VECTOR(1 to 8) := (others => '0');

    signal addr1 : STD_LOGIC_VECTOR(1 to 8) := (others => '0');
    signal addr2 : STD_LOGIC_VECTOR(1 to 8) := (others => '0');
    signal dest_addr : STD_LOGIC_VECTOR(1 to 8) := (others => '0');
    signal data_reg : STD_LOGIC_VECTOR(1 to 8) := (others => '0');
    signal length_reg : STD_LOGIC_VECTOR(1 to 8) := (others => '0');
    signal indirect_addr : STD_LOGIC_VECTOR(1 to 8) := (others => '0');

    signal alu_op1 : STD_LOGIC_VECTOR(1 to 8) := (others => '0');
    signal alu_op2 : STD_LOGIC_VECTOR(1 to 8) := (others => '0');

    signal current_index : unsigned(1 to 8) := (others => '0');
    signal temp_addr : STD_LOGIC_VECTOR(1 to 8) := (others => '0');

    signal response_sum : unsigned(1 to 16) := (others => '0');
	 signal alu_res : STD_LOGIC_VECTOR(1 to 8) := (others => '0');
	 constant Read_function_r : STD_LOGIC_VECTOR(1 to 8) := "11001111";
	 

begin
    process(clk, reset)
		 variable temp_sum : unsigned(1 to 16);
		 variable sum_slv  : std_logic_vector(1 to 16);  -- NEW
	 begin
        if reset = '1' then
            state <= IDLE;
            byte_count <= 0;
            checksum_calc <= (others => '0');
            read_en <= '0';
            write_en <= '0';
            Error <= '0';
            data_to_alu1 <= (others => '0');
            data_to_alu2 <= (others => '0');
            alu_function <= (others => '0');
            ram_read_add <= (others => '0');
            ram_write_add <= (others => '0');
            ram_write_data <= (others => '0');
            data_to_encode <= (others => '0');
            current_index <= (others => '0');
				read_data <= '0';				
        elsif rising_edge(clk) then
            case state is
                when IDLE =>
                    checksum_calc <= (others => '0');
                    byte_count <= 0;
                    read_en <= '0';
                    write_en <= '0';
                    Error <= '0';
                    if valid = '1' then
                        func_reg <= data_in;
                        packet_data(1) <= data_in;
                        checksum_calc <= resize(unsigned(data_in), 16);
                        byte_count <= 1;
                        state <= RECEIVE_FUNC;
                    end if;

                when RECEIVE_FUNC =>
                    case func_reg is
                        when "00000000" | "00000001" | "00000010" | "00000011" =>
                            packet_length <= 6;  -- Operand ALU
                        when "11110000" =>
                            packet_length <= 5;  -- Write
                        when "00001111" =>
                            packet_length <= 4;  -- Read
                        when "00111100" | "00111101" | "00111110" | "00111111" =>
                            packet_length <= 6;  -- Immediate ALU
                        when "11000000" | "11000001" | "11000010" | "11000011" =>
                            packet_length <= 7;  -- Array ALU
                        when "00110000" | "00110001" | "00110010" | "00110011" =>
                            packet_length <= 6;  -- Indirect
                        when others =>
                            state <= IDLE;  -- Invalid function
                    end case;
                    state <= RECEIVE_PACKET;

                when RECEIVE_PACKET =>
                    if valid = '1' then
                        byte_count <= byte_count + 1;
                        packet_data(byte_count + 1) <= data_in;
                        if (byte_count + 1) <= (packet_length - 2) then
                            checksum_calc <= checksum_calc + resize(unsigned(data_in), 16);
                        end if;
                        if (byte_count + 1) = packet_length then
                            state <= CHECK_CHECKSUM;
                        end if;
                    end if;
					when CHECK_CHECKSUM =>
                        if std_logic_vector(checksum_calc) =
                           (packet_data(packet_length - 1) & packet_data(packet_length)) then
                            state <= EXECUTE_OP;
                        else
                            Error <= '1';
                            state <= ERROR_STATE;
                        end if;

                    when ERROR_STATE =>
                        Error <= '0';
                        state <= IDLE;

                    when EXECUTE_OP =>
                        func_reg <= packet_data(1);
                        if packet_data(1) = "11110000" then  -- Write
                            ram_write_add <= packet_data(2);
                            ram_write_data <= packet_data(3);
                            write_en <= '1';
                            state <= WRITE_RAM;
                        elsif packet_data(1) = "00001111" then  -- Read
                            ram_read_add <= packet_data(2);
                            read_en <= '1';
                            state <= WAIT1_READ1;
                        elsif packet_data(1)(1 to 4) = "0000" and packet_data(1)(5 to 8) <= "0011" then  -- Operand ALU
                            addr1 <= packet_data(2);
                            addr2 <= packet_data(3);
                            dest_addr <= packet_data(4);
                            ram_read_add <= packet_data(2);
                            read_en <= '1';
                            state <= WAIT1_READ1;
                        elsif packet_data(1)(1 to 4) = "0011" and packet_data(1)(5 to 8) >= "1100" then  -- Immediate ALU
                            addr1 <= packet_data(2);
                            data_reg <= packet_data(3);
                            dest_addr <= packet_data(4);
                            ram_read_add <= packet_data(2);
                            read_en <= '1';
                            state <= WAIT1_READ1;
                        elsif packet_data(1)(1 to 4) = "1100" then  -- Array ALU
                            addr1 <= packet_data(2);
                            data_reg <= packet_data(3);
                            length_reg <= packet_data(4);
                            dest_addr <= packet_data(5);
                            current_index <= (others => '0');
                            state <= ARRAY_LOOP;
                        elsif packet_data(1)(1 to 4) = "0011" and packet_data(1)(5 to 8) <= "0011" then  -- Indirect
                            addr1 <= packet_data(2);
                            data_reg <= packet_data(3);
                            dest_addr <= packet_data(4);
                            ram_read_add <= packet_data(2);
                            read_en <= '1';
                            state <= INDIRECT_WAIT1;
                        end if;

                    when WRITE_RAM =>
                        write_en <= '0';
                        state <= IDLE;

                    when WAIT1_READ1 =>
                        read_en <= '0';
                        state <= WAIT2_READ1;

                    when WAIT2_READ1 =>
							 if ram_data_en = '1' then
								alu_op1 <= ram_data;
								 

								 if func_reg = "00001111" then  -- For Read
									  temp_sum := resize(unsigned(Read_function_r), 16) + resize(unsigned(ram_data), 16);
									  response_sum <= temp_sum;

									  data_to_encode(1 to 8)   <= Read_function_r;
									  data_to_encode(9 to 16)  <= ram_data;

									  sum_slv := std_logic_vector(temp_sum);
									  data_to_encode(17 to 24) <= sum_slv(1 to 8);    -- ChkH
									  data_to_encode(25 to 32) <= sum_slv(9 to 16);   -- ChkL

									  state <= SEND_RESPONSE;

								 elsif func_reg(1 to 4) = "0011" and func_reg(5 to 8) >= "1100" then  -- Immediate
									  alu_op2 <= data_reg;
									  alu_function <= func_reg;
									  state <= PERFORM_ALU;

								 else  -- Operand
									  ram_read_add <= addr2;
									  read_en <= '1';
									  state <= WAIT1_READ2;
								 end if;
							  end if;
                    when WAIT1_READ2 =>
                        read_en <= '0';
                        state <= WAIT2_READ2;

                    when WAIT2_READ2 =>
								if ram_data_en = '1' then
									alu_op2 <= ram_data;
									alu_function <= func_reg;
									state <= PERFORM_ALU;
								end if;

                    when PERFORM_ALU =>
                        data_to_alu1 <= alu_op1;
                        data_to_alu2 <= alu_op2;
                        state <= ALU_WAIT;
								
						  when ALU_WAIT =>
								alu_res <= data_alu;
								state <= WRITE_SETUP;
							
						  when WRITE_SETUP =>
								ram_write_add <= dest_addr;
                        ram_write_data <= alu_res;
                        write_en <= '1';

                    when WRITE_RESULT =>
                        write_en <= '0';
                        state <= IDLE;

                    when SEND_RESPONSE =>
                        read_data <= '1';  -- Trigger sending using read_en as per top module
                        state <= IDLE;

                    when ARRAY_LOOP =>
                        if current_index < unsigned(length_reg) then
                            temp_addr <= std_logic_vector(unsigned(addr1) + current_index);
                            ram_read_add <= temp_addr;
                            read_en <= '1';
                            state <= ARRAY_READ_REQ;
                        else
                            state <= IDLE;
                        end if;
								
						  when ARRAY_READ_REQ =>
								read_en <= '0';
								state <= ARRAY_READ_WAIT;
								
						 when ARRAY_READ_WAIT => 
								if ram_data_en = '1' then
									alu_op1 <= ram_data;
									alu_op2 <= data_reg;
									alu_function <= func_reg;
									state <= ARRAY_ALU;
								end if;
						
						  when ARRAY_ALU => 
								data_to_alu1 <= alu_op1;
                        data_to_alu2 <= alu_op2;
								state <= ARRAY_ALU_WAIT;
						
						  when ARRAY_ALU_WAIT =>
								alu_res <= data_alu;
								temp_addr <= std_logic_vector(unsigned(dest_addr)+current_index);
								state <= ARRAY_WRITE;
							

                    when ARRAY_WRITE =>
								ram_write_add <= temp_addr;
                        ram_write_data <= data_alu;
                        write_en <= '1';
								state <= ARRAY_HOLD;
								
						  when ARRAY_HOLD =>
                        write_en <= '0';
                        current_index <= current_index + 1;
                        state <= ARRAY_LOOP;

                    when INDIRECT_WAIT1 =>
                        read_en <= '0';
                        state <= INDIRECT_WAIT2;

                    when INDIRECT_WAIT2 =>
								if ram_data_en = '1' then
									indirect_addr <= ram_data;
									ram_read_add <= ram_data;
									read_en <= '1';
									state <= INDIRECT_WAIT21;
								end if;

                    when INDIRECT_WAIT21 =>
                        read_en <= '0';
                        state <= INDIRECT_WAIT22;

                    when INDIRECT_WAIT22 =>
								if ram_data_en = '1' then
									alu_op1 <= ram_data;
									alu_op2 <= data_reg;
									alu_function <= func_reg;
									state <= PERFORM_ALU;
								end if;

                    when others =>
                        state <= IDLE;
                end case;
            end if;
    end process;

end Behavioral;