library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;

entity Pooling_tb is
  generic (
           N             : integer := 8; -- data width
           P             : integer := 2; -- power of pooling cluster (1 - 2x2, 2 - 4x4, 3 - 8x8, etc)
           in_row        : integer := 8;
           in_col        : integer := 8
           );
end entity Pooling_tb;

architecture a of Pooling_tb is

component Pooling is
  generic (
           N             : integer := 8; -- data width
           P             : integer := 2; -- power of pooling cluster (1 - 2x2, 2 - 4x4, 3 - 8x8, etc)
           in_row        : integer := 256;
           in_col        : integer := 256
           );
  port    (
           clk     : in std_logic;
           rst     : in std_logic;
           d_in    : in std_logic_vector (N-1 downto 0);
           en_in   : in std_logic;
           sof_in  : in std_logic; -- start of frame
           d_out   : out std_logic_vector (N-1 downto 0);
           en_out  : out std_logic;
           sof_out : out std_logic);
end component;

signal clk     : std_logic;
signal rst     : std_logic;
signal d_in    : std_logic_vector (N-1 downto 0);
signal en_in   : std_logic := '0';
signal sof_in  : std_logic := '0'; -- start of frame
signal d_out   : std_logic_vector (N-1 downto 0);
signal en_out  : std_logic;
signal sof_out : std_logic; -- start of frame

begin




DUT: Pooling generic map (
           N           => N     , -- data width
           P           => P     , -- power of pooling cluster (1 - 2x2, 2 - 4x4, 3 - 8x8, etc)
           in_row      => in_row,
           in_col      => in_col
      )
port map (
           clk     => clk      ,
           rst     => rst      ,
           d_in    => d_in     ,
           en_in   => en_in    ,
           sof_in  => sof_in   ,

           d_out   => d_out    ,
           en_out  => en_out   ,
           sof_out => sof_out             
    );

process        
   begin
     clk <= '0';    
     wait for 5 ns;
     clk <= '1';
     wait for 5 ns;
   end process;

rst <= '1', '0' after 10 ns;

--process
--begin
--  en_in <= '0';
--  sof_in <= '0';
--  d_in <= (others => '0');
--  wait until rst = '0';
--  while true loop
--    wait until rising_edge(clk);
--    sof_in <= '1';
--    for i in 0 to 255 loop
--      en_in <= '1';
--      d_in <= conv_std_logic_vector(i - 127, d_in'length);    
--      wait until rising_edge(clk);
--      sof_in <= '0';
--    end loop;
--  end loop;
--end process;



process        
   begin   
     wait for  3 ns; 
     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);   --sof_in <= '0';
-- Line 1
     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 11, d_in'length); --sof_in <= '1';
     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 2, d_in'length); --sof_in <= '0';
     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 3, d_in'length);
     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 4, d_in'length);
     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 3, d_in'length);
     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 2, d_in'length);
     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 1, d_in'length);
     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 3, d_in'length);

     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
-- Line 2
     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 1, d_in'length);
     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 12, d_in'length);
     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 3, d_in'length);
     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 4, d_in'length);
     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 5, d_in'length);
     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 6, d_in'length);
     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 17, d_in'length);
     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 18, d_in'length);
-- Line 3
     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 9, d_in'length);
     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 10, d_in'length);
     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 1, d_in'length);
     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 2, d_in'length);
     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 3, d_in'length);
     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 14, d_in'length);
     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 5, d_in'length);
     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 6, d_in'length);
-- Line 4
     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 1, d_in'length);
     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 22, d_in'length);
     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 3, d_in'length);
     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 4, d_in'length);
     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 5, d_in'length);
     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 6, d_in'length);
     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 20, d_in'length);
     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 21, d_in'length);

-- Cluster 2    
-- Line 5
     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 1, d_in'length); --sof_in <= '1';
     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 2, d_in'length); --sof_in <= '0';
     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 3, d_in'length);
     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 4, d_in'length);
     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 13, d_in'length);
     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 2, d_in'length);
     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 1, d_in'length);
     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 3, d_in'length);

     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
-- Line 6
     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 1, d_in'length);
     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 2, d_in'length);
     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 3, d_in'length);
     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 4, d_in'length);
     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 5, d_in'length);
     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 6, d_in'length);
     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 7, d_in'length);
     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 8, d_in'length);
-- Line 7
     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 9, d_in'length);
     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 10, d_in'length);
     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 1, d_in'length);
     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 2, d_in'length);
     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 3, d_in'length);
     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 4, d_in'length);
     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 5, d_in'length);
     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 6, d_in'length);
-- Line 8
     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 1, d_in'length);
     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 2, d_in'length);
     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 3, d_in'length);
     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 4, d_in'length);
     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 5, d_in'length);
     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 6, d_in'length);
     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 7, d_in'length);
     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 20, d_in'length);
-- Line 1
--     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 1, d_in'length); sof_in <= '1';
--     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 2, d_in'length); sof_in <= '0';
--     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 3, d_in'length);
--     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 4, d_in'length);
--
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
---- Line 2
--     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 5, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 6, d_in'length);
--
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--
--     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 7, d_in'length);
--     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 8, d_in'length);
--
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--
---- Line 3     
--     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 9, d_in'length);
--     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector(10, d_in'length);
--     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector(11, d_in'length);
--     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector(12, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);

---- Line 1234
--     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 1, d_in'length); sof_in <= '1';
--     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 2, d_in'length); sof_in <= '0';
--     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 3, d_in'length);
--     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 4, d_in'length);
--     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 5, d_in'length);
--     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 6, d_in'length);
--     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 7, d_in'length);
--     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 8, d_in'length);
--     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 9, d_in'length);
--     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector(10, d_in'length);
--     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector(11, d_in'length);
--     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector(12, d_in'length);

--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);


---- Line 1234
--     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 1, d_in'length); sof_in <= '1';
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length); sof_in <= '0';
--     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 2, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 3, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 4, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 5, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 6, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 7, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 8, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 9, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector(10, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector(11, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector(12, d_in'length);

--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);

---- Frame 2
---- Line 1
--     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector(101, d_in'length); sof_in <= '1';
--     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector(102, d_in'length); sof_in <= '0';
--     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector(103, d_in'length);
--     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector(104, d_in'length);
--     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector(105, d_in'length);
--     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector(106, d_in'length);
--     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector(107, d_in'length);
--     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector(108, d_in'length);

--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);

---- Line 2
--     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector(109, d_in'length); 
--     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector(110, d_in'length); 
--     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector(111, d_in'length);
--     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector(112, d_in'length);
--     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector(113, d_in'length);
--     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector(114, d_in'length);
--     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector(115, d_in'length);
--     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector(116, d_in'length);

--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);

---- Line 3
--     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector(117, d_in'length); sof_in <= '1';
--     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector(118, d_in'length); sof_in <= '0';
--     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector(119, d_in'length);
--     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector(120, d_in'length);
--     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector(121, d_in'length);
--     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector(122, d_in'length);
--     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector(123, d_in'length);
--     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector(124, d_in'length);

--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);

---- Line 4
--     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector(125, d_in'length); sof_in <= '1';
--     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector(126, d_in'length); sof_in <= '0';
--     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector(127, d_in'length);
--     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector(128, d_in'length);
--     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector(129, d_in'length);
--     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector(130, d_in'length);
--     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector(131, d_in'length);
--     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector(132, d_in'length);
     
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);

   end process;



end a;