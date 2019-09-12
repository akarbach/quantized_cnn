library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;

entity Max3 is
  generic (
           N             : integer := 8 -- input data width
           );
  port    (
           d_in1  : in std_logic_vector (N-1 downto 0);
           d_in2  : in std_logic_vector (N-1 downto 0);
           d_in3  : in std_logic_vector (N-1 downto 0);

           d_out       : out std_logic_vector (N-1 downto 0));
end Max3;

architecture a of Max3 is

begin

  p_max : process (d_in1, d_in2, d_in3)
  begin
    if    d_in1 > d_in2 and d_in1 > d_in3 then
       d_out <= d_in1;
    elsif d_in2 > d_in3 then
       d_out <= d_in2;
    else
       d_out <= d_in3;
    end if;
  end process p_max;

end a;