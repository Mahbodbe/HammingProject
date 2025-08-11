LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
 
ENTITY encoder_tb IS
END encoder_tb;
 
ARCHITECTURE behavior OF encoder_tb IS 
 
 
    COMPONENT encoder
    PORT(
         data : IN  std_logic_vector(1 to 8);
         odd_mode : IN  std_logic;
         data_out : OUT  std_logic_vector(1 to 13)
        );
    END COMPONENT;
    

   signal data : std_logic_vector(1 to 8) := (others => '0');
   signal odd_mode : std_logic := '0';

   signal data_out : std_logic_vector(1 to 13);
 
 
BEGIN
 
   uut: encoder PORT MAP (
          data => data,
          odd_mode => odd_mode,
          data_out => data_out
        );
 
   stim_proc: process
   begin
		odd_mode <= '0';
		data <= "11110000";
		wait for 10 ns;
		data <= "00000001";
		wait for 10 ns;
		data <= "00000010";
		wait for 10 ns;
		data <= "00000000";
		wait for 10 ns;
		data <= "11110011";
		wait for 10 ns;
		
		data <= "00001111";
		wait for 10 ns;
		data <= "00000001";
		wait for 10 ns;
		data <= "00000000";
		wait for 10 ns;
		data <= "00010000";
		wait for 10 ns;
		
		data <= "11001111";
		wait for 10 ns;
		data <= "00000010";
		wait for 10 ns;
		data <= "00000000";
		wait for 10 ns;
		data <= "11010001";
		wait for 10 ns;
		
		data <= "00000011";
		wait for 10 ns;
		data <= "00000110";
		wait for 10 ns;
		
		data <= "01000001";
		wait for 10 ns;
		data <= "00111101";
		wait for 10 ns;
		data <= "11110001";
		wait for 10 ns;

		data <= "00110010";
		wait for 10 ns;
		data <= "00110110";
		wait for 10 ns;	

		data <= "11000000";
		wait for 10 ns;

		data <= "11110010";
		wait for 10 ns;


		
      wait;
   end process;

END;
