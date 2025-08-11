library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity packet is
    Port (
        inputRdy   : in  STD_LOGIC;
        RST        : in  STD_LOGIC;
        input      : in  STD_LOGIC;
        output     : out STD_LOGIC;
        outputRdy  : out STD_LOGIC;
        clk        : in  STD_LOGIC;
        error      : out STD_LOGIC
    );
end packet;

architecture Behavioral of packet is

    component encoder
        Port (
            data      : in  STD_LOGIC_VECTOR (1 to 8);
            odd_mode  : in  STD_LOGIC;
            data_out  : out STD_LOGIC_VECTOR (1 to 13)
        );
    end component;

    component decoder
        Port (
            data     : in  STD_LOGIC_VECTOR (1 to 13);
            data_out : out STD_LOGIC_VECTOR (1 to 8);
            valid    : out STD_LOGIC
        );
    end component;

    component ram8x32
        Port (
            clk        : in  STD_LOGIC;
            rst        : in  STD_LOGIC;
            writeEn    : in  STD_LOGIC;
            readEn     : in  STD_LOGIC;
            writeAdr   : in  STD_LOGIC_VECTOR (1 to 5);
            readAdr    : in  STD_LOGIC_VECTOR (1 to 5);
            wr_data    : in  STD_LOGIC_VECTOR (1 to 8);
            output     : out STD_LOGIC_VECTOR (1 to 8);
            outputRdy  : out STD_LOGIC
        );
    end component;

    component ALU
        Port (
            operand_a  : in  STD_LOGIC_VECTOR (1 to 8);
            operand_b  : in  STD_LOGIC_VECTOR (1 to 8);
            func_code  : in  STD_LOGIC_VECTOR (1 to 8);
            result     : out STD_LOGIC_VECTOR (1 to 8)
        );
    end component;

    component controlunit is
        Port (
            clk             : in STD_LOGIC;
            reset           : in STD_LOGIC;
            data_in         : in  STD_LOGIC_VECTOR (1 to 8);
            ram_read_add    : out  STD_LOGIC_VECTOR (1 to 8);
            ram_write_data  : out  STD_LOGIC_VECTOR (1 to 8);
            ram_write_add   : out  STD_LOGIC_VECTOR (1 to 8);
            ram_data        : in  STD_LOGIC_VECTOR (1 to 8);
            Error           : out STD_LOGIC;
				ram_data_en 	 : in STD_LOGIC;
				read_en 			 : out STD_LOGIC;
            write_en        : out STD_LOGIC;
            valid           : in STD_LOGIC;
            data_to_alu1    : out STD_LOGIC_VECTOR(1 to 8);
            data_to_alu2    : out STD_LOGIC_VECTOR(1 to 8);
            data_alu        : in STD_LOGIC_VECTOR(1 to 8);
            data_to_encode  : out STD_LOGIC_VECTOR(1 to 32);
            alu_function    : out STD_LOGIC_VECTOR(1 to 8);
				read_data		 : out STD_LOGIC

        );
    end component;

    component sipo is
        Port (
            clk          : in  STD_LOGIC;
            rst          : in  STD_LOGIC;
            serial_in    : in  STD_LOGIC;
            InputRdy     : in  STD_LOGIC;
            parallel_out : out STD_LOGIC_VECTOR(1 to 13);
            word_ready   : out STD_LOGIC
        );
    end component;
	 
	 component devider is
    Port ( 
			  DIN 	: in  STD_LOGIC_VECTOR (1 to 32);
           DOUT 	: out  STD_LOGIC_VECTOR (1 to 8);
           clk 	: in  STD_LOGIC;
			  enable : in STD_LOGIC;
			  out_en : out STD_LOGIC
		  );
	 end component;
	 
	 component piso is
    Port ( 
			  DIN 	: in  STD_LOGIC_VECTOR (1 to 13);
			  IN_EN 	: in STD_LOGIC;
           DOUT 	: out  STD_LOGIC;
           clk 	: in  STD_LOGIC;
           OUT_EN : out  STD_LOGIC
		  );
	 end component;


    signal data_in_c        : std_logic_vector(1 to 8);
    signal data_out_c       : std_logic_vector(1 to 8);
    signal data_out_s       : std_logic_vector(1 to 13) := (others => '0');
    signal valid_c          : std_logic;

    signal ram_write_en     : std_logic;
    signal ram_write_add    : std_logic_vector(1 to 8);
    signal ram_write_data   : std_logic_vector(1 to 8);
    signal ram_readRDY      : std_logic;
    signal to_encode_en      : std_logic:='0';
    signal to_ram_en        : std_logic:='0';
    signal ram_read_add     : std_logic_vector(1 to 8);
    signal ram_read_data    : std_logic_vector(1 to 8);
    signal alu_data1        : std_logic_vector(1 to 8);
    signal alu_data2        : std_logic_vector(1 to 8);
    signal alu_function     : std_logic_vector(1 to 8);
    signal alu_res          : std_logic_vector(1 to 8);
    signal error_signal     : std_logic;
    signal data_to_encode2  : std_logic_vector(1 to 32);

    signal word13          : STD_LOGIC_VECTOR(1 to 13);
    signal word_ready      : STD_LOGIC;
    signal decoded_comb    : STD_LOGIC_VECTOR(1 to 8);
    signal valid_comb      : STD_LOGIC;

    signal data_in_c_reg   : STD_LOGIC_VECTOR(1 to 8) := (others => '0');
    signal valid_c_reg     : STD_LOGIC := '0';
	 signal send_pulse	   : std_logic := '0';
	 

begin
    bb0: sipo
        port map(
            clk          => clk,
            rst          => RST,
            serial_in    => input,
            InputRdy     => inputRdy,
            parallel_out => word13,
            word_ready   => word_ready
        );

    bb1: encoder
        port map(
            data     => data_out_c,
            odd_mode => '0',
            data_out => data_out_s
			);

    bb2: decoder
        port map(
            data     => word13,
            data_out => decoded_comb,
            valid    => valid_comb
        );

    bb3: ram8x32
        port map(
            clk       => clk,
            rst       => RST,
            writeEn   => ram_write_en,
            readEn    => to_ram_en,
            writeAdr  => ram_write_add(4 to 8),
            readAdr   => ram_read_add(4 to 8),
            wr_data   => ram_write_data,
            output    => ram_read_data,
            outputRdy => ram_readRDY
        );

    bb4: ALU
        port map(
            operand_a => alu_data1,
            operand_b => alu_data2,
            func_code => alu_function,
            result    => alu_res
        );

    bb5: controlunit
        port map(
            clk            => clk,
            reset          => RST,
            valid          => valid_c_reg,
            data_in        => data_in_c_reg,
            write_en       => ram_write_en,
            ram_write_add  => ram_write_add,
            ram_write_data => ram_write_data,
				read_en 			=> to_ram_en,
            read_data      => to_encode_en,
				ram_data_en		=> ram_readRDY,
            ram_read_add   => ram_read_add,
            ram_data       => ram_read_data,
            data_to_alu1   => alu_data1,
            data_to_alu2   => alu_data2,
            alu_function   => alu_function,
            data_alu       => alu_res,
            Error          => error_signal,
            data_to_encode => data_to_encode2
        );
		
	 bb6: devider
		  port map (
				 clk    => clk,
				 DIN    => data_to_encode2,
				 DOUT   => data_out_c,
				 enable => to_encode_en,
				 out_en => send_pulse
		  );
	 bb7: piso
		port map (
			clk  	 => clk,
			DIN  	 => data_out_s,
			IN_EN  => send_pulse,
			DOUT 	 => output,
			OUT_EN => outputRdy
		);

	 process(clk, RST)
	 begin
		 if RST = '1' then
			  data_in_c_reg <= (others => '0');
			  valid_c_reg   <= '0';
		 elsif rising_edge(clk) then
			  valid_c_reg <= '0'; 
			  if word_ready = '1' then
					data_in_c_reg <= decoded_comb;     
					if valid_comb = '1' then
						 valid_c_reg <= '1';           
					end if;
			  end if;
		 end if;
	 end process;
	 
    error <= error_signal;

end Behavioral;