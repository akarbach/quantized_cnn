library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;

entity ConvLayersNxM_tb is
    generic (
           mult_sum      : string := "sum";
           N             : integer := 8; -- input data width
           M             : integer := 8; -- input weight width
           W             : integer := 8; -- output data width (Note, W+SR <= N+M+4)
           SR            : integer := 2; -- data shift right before output
           --bpp           : integer := 8; -- bit per pixel
           in_row        : integer := 3;
           in_col        : integer := 4
           );
end entity ConvLayersNxM_tb;

architecture ConvLayersNxM_tb of ConvLayersNxM_tb is

component ConvLayersNxM is
  generic (
           mult_sum      : string := "sum";
           N             : integer := 8; -- input data width
           M             : integer := 8; -- input weight width
           W             : integer := 8; -- output data width      (Note, W+SR <= N+M+4)
           SR            : integer := 2; -- data shift right before output
           in_row        : integer := 256;
           in_col        : integer := 256
           );
  port    (
           clk     : in std_logic;
           rst     : in std_logic;
           d_in    : in std_logic_vector (N-1 downto 0);
           en_in   : in std_logic;
           sof_in  : in std_logic; -- start of frame

           w_d     : in std_logic_vector(M-1 downto 0); -- weight data
           w_a     : in std_logic_vector(9 downto 0);   -- weight address
           w_en    : in std_logic;                      -- weight en

           max0_out   : out std_logic_vector (W-1 downto 0);
           max1_out   : out std_logic_vector (W-1 downto 0);
           max2_out   : out std_logic_vector (W-1 downto 0);
           max3_out   : out std_logic_vector (W-1 downto 0);
           max4_out   : out std_logic_vector (W-1 downto 0);
           max5_out   : out std_logic_vector (W-1 downto 0);
           max6_out   : out std_logic_vector (W-1 downto 0);
           max7_out   : out std_logic_vector (W-1 downto 0);
           max8_out   : out std_logic_vector (W-1 downto 0);
           max9_out   : out std_logic_vector (W-1 downto 0);
           en_out  : out std_logic
           );
end component;

signal clk     : std_logic;
signal rst     : std_logic;
signal d_in    : std_logic_vector (N-1 downto 0);
signal en_in   : std_logic;
signal sof_in  : std_logic; -- start of frame

signal w_d     : std_logic_vector(M-1 downto 0); -- weight data
signal w_a     : std_logic_vector(9 downto 0);   -- weight address
signal w_en    : std_logic;                      -- weight en

signal max0_out   : std_logic_vector (W-1 downto 0);
signal max1_out   : std_logic_vector (W-1 downto 0);
signal max2_out   : std_logic_vector (W-1 downto 0);
signal max3_out   : std_logic_vector (W-1 downto 0);
signal max4_out   : std_logic_vector (W-1 downto 0);
signal max5_out   : std_logic_vector (W-1 downto 0);
signal max6_out   : std_logic_vector (W-1 downto 0);
signal max7_out   : std_logic_vector (W-1 downto 0);
signal max8_out   : std_logic_vector (W-1 downto 0);
signal max9_out   : std_logic_vector (W-1 downto 0);
signal en_out     : std_logic;

begin




DUT: ConvLayersNxM generic map (
      mult_sum => mult_sum,
      N        => N       , -- input data width
      M        => M       , -- input data width
      W        => W       ,-- output data width
      SR       => SR      ,-- output data shift right
      --bpp      => bpp     , -- bit per pixel
      in_row   => in_row  ,
      in_col   => in_col
      )
port map (
      clk     => clk      ,
      rst     => rst      ,
      d_in    => d_in     ,
      en_in   => en_in    ,
      sof_in  => sof_in   ,

      w_d      => w_d     , -- weight data
      w_a      => w_a     , -- weight address
      w_en     => w_en    , -- weight en

      max0_out => max0_out,   
      max1_out => max1_out,   
      max2_out => max2_out,   
      max3_out => max3_out,  
      max4_out => max4_out,  
      max5_out => max5_out,  
      max6_out => max6_out,  
      max7_out => max7_out,  
      max8_out => max8_out,  
      max9_out => max9_out,  
      en_out   => en_out    
    );

process        
   begin
     clk <= '0';    
     wait for 5 ns;
     clk <= '1';
     wait for 5 ns;
   end process;

rst <= '1', '0' after 10 ns;

--w1  <= conv_std_logic_vector(1, w1'length);
--w2  <= conv_std_logic_vector(2, w2'length);
--w3  <= conv_std_logic_vector(3, w3'length);
--w4  <= conv_std_logic_vector(4, w4'length);
--w5  <= conv_std_logic_vector(5, w5'length);
--w6  <= conv_std_logic_vector(6, w6'length);
--w7  <= conv_std_logic_vector(7, w7'length);
--w8  <= conv_std_logic_vector(8, w8'length);
--w9  <= conv_std_logic_vector(9, w9'length);

--w1  <= conv_std_logic_vector(205, w1'length);
--w2  <= conv_std_logic_vector(215, w2'length);
--w3  <= conv_std_logic_vector(225, w3'length);
--w4  <= conv_std_logic_vector(235, w4'length);
--w5  <= conv_std_logic_vector(245, w5'length);
--w6  <= conv_std_logic_vector(255, w6'length);
--w7  <= conv_std_logic_vector(225, w7'length);
--w8  <= conv_std_logic_vector(235, w8'length);
--w9  <= conv_std_logic_vector(265, w9'length);





process
begin
  en_in <= '0';
  sof_in <= '0';
  d_in <= (others => '0');
  wait until rst = '0';
  while true loop
    wait until rising_edge(clk);
    sof_in <= '1';
    for i in 0 to 1023 loop
    w_en   <= '1';
      w_a <= conv_std_logic_vector(i, w_a'length); 
      w_d <= conv_std_logic_vector(i - 127, w_d'length);    
      wait until rising_edge(clk);
    end loop;
    w_en   <= '0';

    for i in 0 to 255 loop
      en_in <= '1';
      d_in <= conv_std_logic_vector(i - 127, d_in'length);    
      wait until rising_edge(clk);
      sof_in <= '0';
    end loop;
  end loop;
end process;



--process        
--   begin   
--     wait for 5 ns;
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length); sof_in <= '0';

--     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 201, d_in'length); sof_in <= '1';
--     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 202, d_in'length); sof_in <= '0';
--     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 203, d_in'length);
--     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 204, d_in'length);

--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
---- Line 2
--     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 205, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 206, d_in'length);

--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);

--     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 207, d_in'length);
--     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 208, d_in'length);

--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
--     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);

---- Line 3     
--     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector(209, d_in'length);
--     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector(210, d_in'length);
--     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector(211, d_in'length);
--     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector(212, d_in'length);

---- Frame 1
---- Line 1
----     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 1, d_in'length); sof_in <= '1';
----     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 2, d_in'length); sof_in <= '0';
----     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 3, d_in'length);
----     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 4, d_in'length);
----
----     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
----     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
----     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
----     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
----     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
------ Line 2
----     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 5, d_in'length);
----     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
----     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 6, d_in'length);
----
----     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
----     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
----     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
----
----     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 7, d_in'length);
----     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 8, d_in'length);
----
----     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
----     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
----     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
----     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
----     wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);
----
------ Line 3     
----     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 9, d_in'length);
----     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector(10, d_in'length);
----     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector(11, d_in'length);
----     wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector(12, d_in'length);

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

--   end process;



end ConvLayersNxM_tb;