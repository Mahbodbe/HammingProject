LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
 
ENTITY packet_tb6 IS
END packet_tb6;
 
ARCHITECTURE behavior OF packet_tb6 IS 
 
 
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
		-- check ram init data
		input <= '1';
		wait for 10 * clk_period;
      wait;
   end process;

END;
