LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
 
ENTITY packet_tb3 IS
END packet_tb3;
 
ARCHITECTURE behavior OF packet_tb3 IS 
 
 
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
		--func : SUB : 00111101, add1 : 00000001 => data : 00000010, 
		--data : 00000001, des : 000000010 => 00000001 , H : 00000000, L :01000001
		
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
		--immediate sub: 00111101 => 0101011111010
		input <= '0';
		wait for clk_period;
		input <= '1';
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
		input <= '1';
		wait for clk_period;
		input <= '1';
		wait for clk_period;
		input <= '0';
		wait for clk_period;
		input <= '1';
		wait for clk_period;
		input <= '0';
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
		--des: 00000010 =>  1100000100100
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
		--checkSumL: 01000001 =>  1000100100010
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
		
      wait;
   end process;

END;
