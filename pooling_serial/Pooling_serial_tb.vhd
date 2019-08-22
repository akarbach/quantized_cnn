library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;
library work;
use work.ConvLayer_types_package.all;

entity Pooling_serial_tb is
  generic (
           CL_inputs     : integer := 64; -- number of inputs features
           N             : integer := 8;  -- data width (maxinum 8 bit)
           in_row        : integer := 7;
           in_col        : integer := 7
           );
end entity Pooling_serial_tb;

architecture a of Pooling_serial_tb is

component Pooling_serial is
  generic (
           CL_inputs     : integer := 32; -- number of inputs features
           N             : integer := 8;  -- data width (maxinum 8 bit)
           in_row        : integer := 7;
           in_col        : integer := 7
           );
  port    (
           clk     : in  std_logic;
           rst     : in  std_logic;
           d_in    : in  vec(0 to CL_inputs -1)(N-1 downto 0);
           en_in   : in  std_logic;
           sof_in  : in  std_logic; -- start of frame
           d_out   : out vec(0 to CL_inputs -1)(N-1 downto 0);
           en_out  : out std_logic);
end component;

signal clk         : std_logic;
signal rst         : std_logic;

signal d_in    : vec(0 to CL_inputs -1)(N-1 downto 0);
signal en_in   : std_logic;
signal sof_in  : std_logic; -- start of frame
signal d_out   : vec(0 to CL_inputs -1)(N-1 downto 0);
signal en_out  : std_logic;
signal frameN  : integer := 0;

begin




DUT: Pooling_serial generic map (
           CL_inputs   => CL_inputs,
           N           => N        ,
           in_row      => in_row   ,
           in_col      => in_col   
      )
port map (
           clk         => clk        ,
           rst         => rst        ,
           d_in        => d_in       ,
           en_in       => en_in      ,
           sof_in      => sof_in     ,
           d_out       => d_out      ,
           en_out      => en_out               
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
     wait for 10 ns; en_in <= '0'; 
     wait for 10 ns;  en_in <= '1'; 
     time_loop: for i in 0 to in_row*in_col-1 loop
        gen_inputs: for k in 0 to CL_inputs-1 loop
           d_in(K) <= conv_std_logic_vector(k+i+frameN, N);   
           --d_in(K)(N-1         ) <= '0';    
           --d_in(K)(N-2 downto 0) <= (others => '1');    
        end loop gen_inputs;
        wait for 10 ns; 
     end loop time_loop;
     en_in <= '0';
     frameN <= frameN + 10;
     wait for 300 ns; en_in <= '0'; sof_in <= '0';

--     wait for 10 ns; en_in <= '1';

     --wait for 1000 ns;

   end process;



end a;