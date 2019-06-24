library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;
library work;
use work.ConvLayer_types_package.all;

entity multi_adder is
  generic (
           Relu          : string := "yes"; --"no"/"yes"  -- nonlinear Relu function
           BP            : string := "no";  --"no"/"yes"  -- Bypass
           TP            : string := "no";  --"no"/"yes"  -- Test pattern output
           CL_inputs     : integer := 3;    -- number of inputs features
           CL_outs       : integer := 6;    -- number of output features
           N             : integer := 8     -- input data width
  	       );
  port    (
           clk         : in std_logic;
           rst         : in std_logic;
           d_in        : in mat(0 to CL_inputs-1)(0 to CL_outs -1)(N-1 downto 0);

  	       en_in       : in std_logic;
  	       sof_in      : in std_logic; -- start of frame

           d_out       : out vec(0 to CL_outs -1)(N-1 downto 0);
           en_out      : out std_logic;
           sof_out     : out std_logic);
end multi_adder;

architecture a of multi_adder is

constant EN_BIT  : integer range 0 to 1 := 0;
constant SOF_BIT : integer range 0 to 1 := 1;

--signal d01_in_s        : in vec(0 to CL_inputs -1)(N-1 downto 0);
--signal d02_in_s        : in vec(0 to CL_inputs -1)(N-1 downto 0);
--signal d03_in_s        : in vec(0 to CL_inputs -1)(N-1 downto 0);
--signal d04_in_s        : in vec(0 to CL_inputs -1)(N-1 downto 0);
--signal d05_in_s        : in vec(0 to CL_inputs -1)(N-1 downto 0);
--signal d06_in_s        : in vec(0 to CL_inputs -1)(N-1 downto 0);
--signal d07_in_s        : in vec(0 to CL_inputs -1)(N-1 downto 0);
--signal d08_in_s        : in vec(0 to CL_inputs -1)(N-1 downto 0);
--signal d09_in_s        : in vec(0 to CL_inputs -1)(N-1 downto 0);
--signal d10_in_s        : in vec(0 to CL_inputs -1)(N-1 downto 0);
--signal d11_in_s        : in vec(0 to CL_inputs -1)(N-1 downto 0);
--signal d12_in_s        : in vec(0 to CL_inputs -1)(N-1 downto 0);
--signal d13_in_s        : in vec(0 to CL_inputs -1)(N-1 downto 0);
--signal d14_in_s        : in vec(0 to CL_inputs -1)(N-1 downto 0);
--signal d15_in_s        : in vec(0 to CL_inputs -1)(N-1 downto 0);

       
begin
--  d20 <= (d01(d01'left) & d01(d01'left) & d01) + (d02(d02'left) & d02(d02'left) & d02) + (d03(d03'left) & d03(d03'left) & d03) + (d04(d04'left) & d04(d04'left) & d04);
process (clk)

variable tmp : vec(0 to CL_outs -1)(N-1 downto 0);

begin
   if rising_edge(clk) then
      gen_inCL: for J in 0 to CL_inputs-1 loop
      gen_CL: for I in 0 to CL_outs-1 loop
         tmp(I) := tmp(I) + d_in(J)(I);
      end loop gen_CL;
      end loop gen_inCL;
      
      d_out <= tmp;
   end if;
end process;


end a;