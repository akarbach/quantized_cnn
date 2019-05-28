library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;

entity ConvLayer_tb is
    generic (
           mult_sum      : string := "sum";
           N             : integer := 8; -- input data width
           M             : integer := 8; -- input weight width
           W             : integer := 6; -- output data width (Note, W+SR <= N+M+4)
           SR            : integer := 4; -- data shift right before output
           --bpp           : integer := 8; -- bit per pixel
           in_row        : integer := 10;
           in_col        : integer := 7
           );
end entity ConvLayer_tb;

architecture ConvLayer_tb of ConvLayer_tb is

component ConvLayer is
  generic (
  	       mult_sum      : string := "sum";
           N             : integer := 8; -- input data width
           M             : integer := 8; -- input weight width
           W             : integer := 8; -- output data width
           SR            : integer := 8; -- data shift right before output
           --bpp           : integer := 8; -- bit per pixel
  	       in_row        : integer := 8;
  	       in_col        : integer := 8
  	       );
  port    (
           clk     : in std_logic;
           rst     : in std_logic;
  	       d_in    : in std_logic_vector (N-1 downto 0);
  	       en_in   : in std_logic;
  	       sof_in  : in std_logic; -- start of frame
  	       --sol     : in std_logic; -- start of line
  	       --eof     : in std_logic; -- end of frame
           w_in    : in std_logic_vector(M-1 downto 0);
           w_num   : in std_logic_vector(  3 downto 0);
           w_en    : in std_logic;

           d_out   : out std_logic_vector (W-1 downto 0);
           en_out  : out std_logic;
           sof_out : out std_logic);
end component;

signal clk     : std_logic;
signal rst     : std_logic;
signal d_in    : std_logic_vector (N-1 downto 0);
signal en_in   : std_logic;
signal sof_in  : std_logic; -- start of frame
--signal sol     : std_logic; -- start of line
--signal eof     : std_logic; -- end of frame
signal w_in    : std_logic_vector(M-1 downto 0);
signal w_num   : std_logic_vector(  3 downto 0);
signal w_en    : std_logic;

signal w1      : std_logic_vector(M-1 downto 0); -- weight matrix
signal w2      : std_logic_vector(M-1 downto 0); -- weight matrix
signal w3      : std_logic_vector(M-1 downto 0); -- weight matrix
signal w4      : std_logic_vector(M-1 downto 0); -- weight matrix
signal w5      : std_logic_vector(M-1 downto 0); -- weight matrix
signal w6      : std_logic_vector(M-1 downto 0); -- weight matrix
signal w7      : std_logic_vector(M-1 downto 0); -- weight matrix
signal w8      : std_logic_vector(M-1 downto 0); -- weight matrix
signal w9      : std_logic_vector(M-1 downto 0); -- weight matrix
signal d_out   : std_logic_vector (W-1 downto 0);
signal en_out  : std_logic;
signal sof_out : std_logic; -- start of frame

begin




DUT: ConvLayer generic map (
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
      --sol     => sol      ,
      --eof     => eof      ,

      w_in    => w_in     ,   
      w_num   => w_num    ,   
      w_en    => w_en     ,   

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

w1  <= conv_std_logic_vector(17, w1'length);
w2  <= conv_std_logic_vector(18, w2'length);
w3  <= conv_std_logic_vector(19, w3'length);
w4  <= conv_std_logic_vector(20, w4'length);
w5  <= conv_std_logic_vector(21, w5'length);
w6  <= conv_std_logic_vector(22, w6'length);
w7  <= conv_std_logic_vector(23, w7'length);
w8  <= conv_std_logic_vector(24, w8'length);
w9  <= conv_std_logic_vector(25, w9'length);


process
begin
  en_in <= '0';
  sof_in <= '0';
  d_in <= (others => '0');
  wait until rst = '0';
    w_en <= '1';
    wait until rising_edge(clk); w_num <= x"1"; w_in<= w1;
    wait until rising_edge(clk); w_num <= x"2"; w_in<= w2;
    wait until rising_edge(clk); w_num <= x"3"; w_in<= w3;
    wait until rising_edge(clk); w_num <= x"4"; w_in<= w4;
    wait until rising_edge(clk); w_num <= x"5"; w_in<= w5;
    wait until rising_edge(clk); w_num <= x"6"; w_in<= w6;
    wait until rising_edge(clk); w_num <= x"7"; w_in<= w7;
    wait until rising_edge(clk); w_num <= x"8"; w_in<= w8;
    wait until rising_edge(clk); w_num <= x"9"; w_in<= w9;
    wait until rising_edge(clk); w_en <= '1';
  while true loop
    wait until rising_edge(clk);
    sof_in <= '1';
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



end ConvLayer_tb;