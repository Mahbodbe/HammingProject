library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity decoder is
    Port ( data : in  STD_LOGIC_VECTOR (1 to 13);
           data_out : out  STD_LOGIC_VECTOR (1 to 8);
           valid : out  STD_LOGIC);
end decoder;

architecture Behavioral of decoder is

signal c1 : STD_LOGIC;
signal c2 : STD_LOGIC;
signal c4 : STD_LOGIC;
signal c8 : STD_LOGIC;
signal correction : STD_LOGIC_VECTOR (1 to 8);
signal p : STD_LOGIC;

begin

c1 <= (data(1) xor data(3) xor data(5) xor data(7) xor data(9) xor data(11) xor '0');
c2 <= (data(2) xor data(3) xor data(6) xor data(7) xor data(10) xor data(11) xor '0');
c4 <= (data(4) xor data(5) xor data(6) xor data(7) xor data(12) xor '0');
c8 <= (data(8) xor data(9) xor data(10) xor data(11) xor data(12) xor '0');

p <= (data(1) xor data(2) xor data(3) xor data(4) xor data(5) xor data(6) xor data(7) xor
		data(8) xor data(9) xor data(10) xor data(11) xor data(12) xor data(13) xor '0');

correction(1) <= (data(3) xor ((not c8) and (not c4) and (c2) and (c1))); -- 0011
correction(2) <= (data(5) xor ((not c8) and (c4) and (not c2) and (c1))); -- 0101 
correction(3) <= (data(6) xor ((not c8) and (c4) and (c2) and (not c1))); -- 0110 
correction(4) <= (data(7) xor ((not c8) and (c4) and (c2) and (c1))); 
correction(5) <= (data(9) xor ((c8) and (not c4) and (not c2) and (c1))); 
correction(6) <= (data(10) xor ((c8) and (not c4) and (c2) and (not c1))); 
correction(7) <= (data(11) xor ((c8) and (not c4) and (c2) and (c1))); 
correction(8) <= (data(12) xor ((c8) and (c4) and (not c2) and (not c1))); 

data_out <= correction;

valid <= not((c1 or c2 or c4 or c8) and (not p)); -- check if p=0 and c!=0 then we have two errors and data out is not valid


end Behavioral;

