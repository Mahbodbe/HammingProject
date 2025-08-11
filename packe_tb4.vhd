LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY packe_tb4 IS
END packe_tb4;
 
ARCHITECTURE behavior OF packe_tb4 IS 
 
    COMPONENT packet
    PORT(
         inputRdy : IN  std_logic;
         RST : IN  std_logic;
         input : IN  std_logic;
         output : OUT  std_logic;
         outputRdy : OUT  std_logic;
         clk : IN  std_logic;
         error : OUT  std_logic
        );
    END COMPONENT;
    

   signal inputRdy : std_logic := '0';
   signal RST : std_logic := '0';
   signal input : std_logic := '0';
   signal clk : std_logic := '0';

   signal output : std_logic;
   signal outputRdy : std_logic;
   signal error : std_logic;

   constant clk_period : time := 10 ns;
 
BEGIN
   uut: packet PORT MAP (
          inputRdy => inputRdy,
          RST => RST,
          input => input,
          output => output,
          outputRdy => outputRdy,
          clk => clk,
          error => error
        );

   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   stim_proc: process
   begin		
	
		--func : or : 00110010, address : 0000000 => data(indirect) : 00000001 => main(data) : 00000010, 
		--data : 00000010, Des : 00000010, H:00000000, L: 00110110
		
		RST <= '1';
		wait for 2 * clk_period;
		RST <= '0';
		inputRdy <= '1';
		--write:11110000 => 1111111000001
		input <= '1';
		wait for clk_period;
		input <= '1';
		wait for clk_period;
		input <= '1';
		wait for clk_period;
		input <= '1';
		wait for clk_period;
		input <= '1';
		wait for clk_period;
		input <= '1';
		wait for clk_period;
		input <= '1';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '1';
		wait for clk_period;
		-- address: 00000001 => 0001000100011
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '1';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '1';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '1';
		wait for clk_period;
		input <= '1';
		wait for clk_period;
		--data: 00000010 =>  1100000100100
		input <= '1';
		wait for clk_period;
		input <= '1';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '1';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '1';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		--checkSumH: 00000000 =>  0000000000000
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		--checkSumL: 11110011 =>  0010111000110
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '1';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '1';
		wait for clk_period;
		input <= '1';
		wait for clk_period;
		input <= '1';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '1';
		wait for clk_period;
		input <= '1';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		inputRdy <='0';
		wait for 10*clk_period;
		
		inputRdy <= '1';
		--write:11110000 => 1111111000001
		input <= '1';
		wait for clk_period;
		input <= '1';
		wait for clk_period;
		input <= '1';
		wait for clk_period;
		input <= '1';
		wait for clk_period;
		input <= '1';
		wait for clk_period;
		input <= '1';
		wait for clk_period;
		input <= '1';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '1';
		wait for clk_period;
		-- address: 00000000 => 0000000000000
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		--data: 00000001 =>  0001000100011
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '1';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '1';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '1';
		wait for clk_period;
		input <= '1';
		wait for clk_period;
		--checkSumH: 00000000 =>  0000000000000
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		--checkSumL: 11110001 =>  1110111100010
		input <= '1';
		wait for clk_period;
		input <= '1';
		wait for clk_period;
		input <= '1';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '1';
		wait for clk_period;
		input <= '1';
		wait for clk_period;
		input <= '1';
		wait for clk_period;
		input <= '1';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '1';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		inputRdy <='0';
		wait for 10*clk_period;
		
		inputRdy <= '1';
		--immediate or:00110010 => 0100011100101
		input <= '0';
		wait for clk_period;
		input <= '1';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '1';
		wait for clk_period;
		input <= '1';
		wait for clk_period;
		input <= '1';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '1';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '1';
		wait for clk_period;
		-- address: 00000000 => 0000000000000
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		--data: 00000010 =>  1100000100100
		input <= '1';
		wait for clk_period;
		input <= '1';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '1';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '1';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		--DES: 00000010 =>  1100000100100
		input <= '1';
		wait for clk_period;
		input <= '1';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '1';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '1';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		--checkSumH: 00000000 =>  0000000000000
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		--checkSumL: 00110110 =>  0000011001100
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '1';
		wait for clk_period;
		input <= '1';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '1';
		wait for clk_period;
		input <= '1';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		inputRdy <='0';
		wait for 10*clk_period;
		
		
		wait;
   end process;

END;
