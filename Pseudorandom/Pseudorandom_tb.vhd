library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;
library work;
use work.ConvLayer_types_package.all;

entity Pseudorandom_tb is
  generic (
           N          : integer := 3;  -- number of inputs bits
           W          : integer := 8   -- data width of each output
           );
end entity Pseudorandom_tb;

architecture a of Pseudorandom_tb is

component Pseudorandom is
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
end component;

signal clk        : std_logic;
signal rst        : std_logic;

signal load       :std_logic;
signal d_in       :std_logic_vector(N-1 downto 0);
signal d_out      :vec(0 to N -1)(W-1 downto 0);

begin




DUT: Pseudorandom generic map (
           N           => N,
           W           => W 
      )
port map (
           clk         => clk   ,
           rst         => rst   ,
           load        => load  ,
           d_in        => d_in  ,
           d_out       => d_out                  
    );

process        
   begin
     clk <= '0';    
     wait for 5 ns;
     clk <= '1';
     wait for 5 ns;
   end process;

rst <= '1', '0' after 10 ns;


process        
   begin   
     wait for  3 ns; 
     wait for 10 ns;  
     wait for 10 ns;  
        gen_inputs: for k in 1 to 10 loop
           load    <= '1';
           --d_in <= (others => '1');
           d_in <= conv_std_logic_vector(k+7, N);
           wait for 10 ns; 
        end loop gen_inputs;
        ws: for k in 0 to N-1 loop
           load    <= '0';
           wait for 10 ns; 
        end loop ws;

        wait for 10 ns; 
     wait for 300 ns; 


   end process;



end a;