library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Binary_adder_tb is
    generic (
           N             : integer := 8;                  -- input #1 data width. Note N > M !!
           M             : integer := 8                   -- input #2 data width
           );
end entity Binary_adder_tb;

architecture Binary_adder_tb of Binary_adder_tb is

--component Binary_adder is
--  generic (
--           N             : integer := 8;                  -- input #1 data width. Note N > M !!
--           M             : integer := 4;                  -- input #2 data width
--           samples       : std_logic_vector(15 downto 0):= (others => '1') -- vector of sample lines 
--           );
--  port    (
--           clk           : in  std_logic;
--           rst           : in  std_logic; 
--
--           en_in         : in  std_logic;                         
--           Multiplier    : in  std_logic_vector(N-1 downto 0);    
--           Multiplicand  : in  std_logic_vector(M-1 downto 0);    
--
--           d_out         : out std_logic_vector (N + M - 1 downto 0);
--           en_out        : out std_logic);                        
--end component;

component Binary_adder8 is
  generic (
           N             : integer := 8;                  -- input #1 data width, positive
           M             : integer := 8
           );
  port    (
           clk           : in  std_logic;
           rst           : in  std_logic; 

           en_in         : in  std_logic;                         
           Multiplier    : in  std_logic_vector(N-1 downto 0);    -- positive
           Multiplicand  : in  std_logic_vector(8-1 downto 0);    -- signed

           d_out         : out std_logic_vector (N + M - 1 downto 0);
           en_out        : out std_logic);                        
end component;

signal clk           : std_logic;
signal rst           : std_logic;
signal en_in         : std_logic;                         
signal Multiplier    : std_logic_vector(N-1 downto 0);    
signal Multiplicand  : std_logic_vector(M-1 downto 0);    
signal d_out         : std_logic_vector (N + M - 1 downto 0);
signal en_out        : std_logic;   

begin

--DUT: Binary_adder generic map (
DUT: Binary_adder8 generic map (
      N             => N           ,
      M             => M               
      )
port map (     
      clk           => clk          ,
      rst           => rst          ,
      en_in         => en_in        ,                         
      Multiplier    => Multiplier   ,
      Multiplicand  => Multiplicand ,
      d_out         => d_out        ,
      en_out        => en_out

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
     wait for 10 ns;en_in <= '0'; 
     wait for 10 ns; 

wait for 10 ns; Multiplier <= conv_std_logic_vector( 3, Multiplier'length); Multiplicand<= conv_std_logic_vector(-7, Multiplicand'length); en_in <= '1'; 
wait for 10 ns; Multiplier <= conv_std_logic_vector( 3, Multiplier'length); Multiplicand<= conv_std_logic_vector( 7, Multiplicand'length); en_in <= '0';
wait for 80 ns; 
wait for 10 ns; Multiplier <= conv_std_logic_vector( 5, Multiplier'length); Multiplicand<= conv_std_logic_vector( 7, Multiplicand'length); en_in <= '1'; 
wait for 10 ns; Multiplier <= conv_std_logic_vector( 5, Multiplier'length); Multiplicand<= conv_std_logic_vector(-7, Multiplicand'length); en_in <= '0';
wait for 80 ns;
wait for 10 ns; Multiplier <= conv_std_logic_vector( 5, Multiplier'length); Multiplicand<= conv_std_logic_vector(-5, Multiplicand'length); en_in <= '1'; 
wait for 10 ns; Multiplier <= conv_std_logic_vector( 5, Multiplier'length); Multiplicand<= conv_std_logic_vector( 5, Multiplicand'length); en_in <= '0';
wait for 80 ns;
wait for 10 ns; Multiplier <= conv_std_logic_vector(50, Multiplier'length); Multiplicand<= conv_std_logic_vector(  50, Multiplicand'length); en_in <= '1'; 
wait for 10 ns; Multiplier <= conv_std_logic_vector(50, Multiplier'length); Multiplicand<= conv_std_logic_vector( -50, Multiplicand'length); en_in <= '0';
wait for 80 ns;
wait for 10 ns; Multiplier <= conv_std_logic_vector(202, Multiplier'length); Multiplicand<= conv_std_logic_vector( 202, Multiplicand'length); en_in <= '1'; 
wait for 10 ns; Multiplier <= conv_std_logic_vector(202, Multiplier'length); Multiplicand<= conv_std_logic_vector(-202, Multiplicand'length); en_in <= '0';
wait for 80 ns;
wait for 10 ns; Multiplier <= conv_std_logic_vector(11, Multiplier'length); Multiplicand<= conv_std_logic_vector(-11, Multiplicand'length); en_in <= '1'; 
wait for 10 ns; Multiplier <= conv_std_logic_vector(11, Multiplier'length); Multiplicand<= conv_std_logic_vector( 11, Multiplicand'length); en_in <= '0';
wait for 80 ns;
wait for 10 ns; Multiplier <= conv_std_logic_vector(100, Multiplier'length); Multiplicand<= conv_std_logic_vector(100, Multiplicand'length); en_in <= '1'; 
wait for 10 ns; Multiplier <= conv_std_logic_vector( 0, Multiplier'length); Multiplicand<= conv_std_logic_vector( 0, Multiplicand'length); en_in <= '0';
wait for 80 ns;
wait for 10 ns; Multiplier <= conv_std_logic_vector(-100, Multiplier'length); Multiplicand<= conv_std_logic_vector(100, Multiplicand'length); en_in <= '1'; 




   end process;



end Binary_adder_tb;