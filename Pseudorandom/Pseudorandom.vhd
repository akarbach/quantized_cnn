library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;
use ieee.math_real.all;
library work;
use work.ConvLayer_types_package.all;

entity Pseudorandom is
  generic (
           N          : integer := 3;  -- number of inputs bits
           W          : integer := 8   -- data width of each output
  	       );
  port    (
           clk     : in  std_logic;
           rst     : in  std_logic;
           load    : in  std_logic;
           d_in    : in  std_logic_vector(N-1 downto 0);
           d_out   : out vec(0 to N -1)(W-1 downto 0)
           );
end Pseudorandom;

architecture a of Pseudorandom is

signal regs : vec(0 to N -1)(W-1 downto 0);

begin


  p_mem_ctr : process (clk,rst)
  begin
    if rst = '1' then
        regs  <= (others => (others => '0'));
    elsif rising_edge(clk) then
       if load = '1' then
          load1: for i in 0 to N-1 loop
             regs(i)(           0)   <= d_in(i);
             regs(i)(W-1 downto 1)   <= regs(i)(W-2 downto 0);
          end loop load1;
       else
          rand1: for i in 0 to N-1 loop
             regs(i)   <= regs(i)(W-2 downto 0) & (regs(i)(W-1) xor regs(i)(W-2));
          end loop rand1;
       end if;
    end if;
  end process p_mem_ctr;

  d_out <= regs;

end a;