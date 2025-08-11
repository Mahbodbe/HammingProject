library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity encoder is
    Port (
			  data 	  : in  STD_LOGIC_VECTOR (1 to 8);
           odd_mode : in  STD_LOGIC;
           data_out : out  STD_LOGIC_VECTOR (1 to 13)
			 );
end encoder;

architecture Behavioral of encoder is

signal a : STD_LOGIC_VECTOR (1 to 12);
signal p13 : STD_LOGIC;

begin

a(3) <= data(1);
a(5) <= data(2);
a(6) <= data(3);
a(7) <= data(4);
a(9) <= data(5);
a(10) <= data(6);
a(11) <= data(7);
a(12) <= data(8);


a(1) <= (a(3) xor a(5) xor a(7) xor a(9) xor a(11) xor odd_mode); --p1  bits that first bit of them  are 1 
a(2) <= (a(3) xor a(6) xor a(7) xor a(10) xor a(11) xor odd_mode); --p2 bits that second bit of them  are 1
a(4) <= (a(5) xor a(6) xor a(7) xor a(12) xor odd_mode); --p3 bits that third bit of them  are 1
a(8) <= (a(9) xor a(10) xor a(11) xor a(12) xor odd_mode); --p4 bits that 4th bit of them  are 1

p13 <= (a(1) xor a(2) xor a(3) xor a(4) xor a(5) xor a(6) xor a(7) xor a(8) xor a(9) xor a(10) xor a(11) xor a(12) xor odd_mode);
		
data_out <= a & p13;

end Behavioral;

