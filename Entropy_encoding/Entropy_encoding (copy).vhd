library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;
use ieee.numeric_std.all;    
--USE ieee.std_logic_arith.all;

entity Entropy_encoding is
  generic (
  	       mult_sum      : string := "sum";
           N             : integer := 8; -- input data width
           M             : integer := 8; -- weight width
           W             : integer := 34; -- output data width    

  	       in_row        : integer := 256;
  	       in_col        : integer := 256
  	       );
  port    (
           clk     : in std_logic;
           rst     : in std_logic;
  	       d_in    : in std_logic_vector (N-1 downto 0);
  	       en_in   : in std_logic;
  	       sof_in  : in std_logic; -- start of frame
  	       --sol     : in std_logic; -- start of line
  	       --eof     : in std_logic; -- end of frame

           d_out   : out std_logic_vector (W-1 downto 0);
           en_out  : out std_logic;
           sof_out : out std_logic);
end Entropy_encoding;

architecture a of Entropy_encoding is

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

component PCA_64 is
  generic (
           mult_sum      : string := "sum";
           N             : integer := 8;       -- input data width
           M             : integer := 8;       -- input weight width
           in_row        : integer := 256;
           in_col        : integer := 256
           );
  port    (
           clk     : in std_logic;
           rst     : in std_logic;
           d01_in    : in std_logic_vector (N-1 downto 0);
           d02_in    : in std_logic_vector (N-1 downto 0);
           d03_in    : in std_logic_vector (N-1 downto 0);
           d04_in    : in std_logic_vector (N-1 downto 0);
           d05_in    : in std_logic_vector (N-1 downto 0);
           d06_in    : in std_logic_vector (N-1 downto 0);
           d07_in    : in std_logic_vector (N-1 downto 0);
           d08_in    : in std_logic_vector (N-1 downto 0);
           d09_in    : in std_logic_vector (N-1 downto 0);
           d10_in    : in std_logic_vector (N-1 downto 0);
           d11_in    : in std_logic_vector (N-1 downto 0);
           d12_in    : in std_logic_vector (N-1 downto 0);
           d13_in    : in std_logic_vector (N-1 downto 0);
           d14_in    : in std_logic_vector (N-1 downto 0);
           d15_in    : in std_logic_vector (N-1 downto 0);
           d16_in    : in std_logic_vector (N-1 downto 0);
           d17_in    : in std_logic_vector (N-1 downto 0);
           d18_in    : in std_logic_vector (N-1 downto 0);
           d19_in    : in std_logic_vector (N-1 downto 0);
           d20_in    : in std_logic_vector (N-1 downto 0);
           d21_in    : in std_logic_vector (N-1 downto 0);
           d22_in    : in std_logic_vector (N-1 downto 0);
           d23_in    : in std_logic_vector (N-1 downto 0);
           d24_in    : in std_logic_vector (N-1 downto 0);
           d25_in    : in std_logic_vector (N-1 downto 0);
           d26_in    : in std_logic_vector (N-1 downto 0);
           d27_in    : in std_logic_vector (N-1 downto 0);
           d28_in    : in std_logic_vector (N-1 downto 0);
           d29_in    : in std_logic_vector (N-1 downto 0);
           d30_in    : in std_logic_vector (N-1 downto 0);
           d31_in    : in std_logic_vector (N-1 downto 0);
           d32_in    : in std_logic_vector (N-1 downto 0);
           d33_in    : in std_logic_vector (N-1 downto 0);
           d34_in    : in std_logic_vector (N-1 downto 0);
           d35_in    : in std_logic_vector (N-1 downto 0);
           d36_in    : in std_logic_vector (N-1 downto 0);
           d37_in    : in std_logic_vector (N-1 downto 0);
           d38_in    : in std_logic_vector (N-1 downto 0);
           d39_in    : in std_logic_vector (N-1 downto 0);
           d40_in    : in std_logic_vector (N-1 downto 0);
           d41_in    : in std_logic_vector (N-1 downto 0);
           d42_in    : in std_logic_vector (N-1 downto 0);
           d43_in    : in std_logic_vector (N-1 downto 0);
           d44_in    : in std_logic_vector (N-1 downto 0);
           d45_in    : in std_logic_vector (N-1 downto 0);
           d46_in    : in std_logic_vector (N-1 downto 0);
           d47_in    : in std_logic_vector (N-1 downto 0);
           d48_in    : in std_logic_vector (N-1 downto 0);
           d49_in    : in std_logic_vector (N-1 downto 0);
           d50_in    : in std_logic_vector (N-1 downto 0);
           d51_in    : in std_logic_vector (N-1 downto 0);
           d52_in    : in std_logic_vector (N-1 downto 0);
           d53_in    : in std_logic_vector (N-1 downto 0);
           d54_in    : in std_logic_vector (N-1 downto 0);
           d55_in    : in std_logic_vector (N-1 downto 0);
           d56_in    : in std_logic_vector (N-1 downto 0);
           d57_in    : in std_logic_vector (N-1 downto 0);
           d58_in    : in std_logic_vector (N-1 downto 0);
           d59_in    : in std_logic_vector (N-1 downto 0);
           d60_in    : in std_logic_vector (N-1 downto 0);
           d61_in    : in std_logic_vector (N-1 downto 0);
           d62_in    : in std_logic_vector (N-1 downto 0);
           d63_in    : in std_logic_vector (N-1 downto 0);
           d64_in    : in std_logic_vector (N-1 downto 0);
           en_in     : in std_logic;
           sof_in    : in std_logic; -- start of frame

           w01      : in std_logic_vector(M-1 downto 0); 
           w02      : in std_logic_vector(M-1 downto 0); 
           w03      : in std_logic_vector(M-1 downto 0); 
           w04      : in std_logic_vector(M-1 downto 0); 
           w05      : in std_logic_vector(M-1 downto 0); 
           w06      : in std_logic_vector(M-1 downto 0); 
           w07      : in std_logic_vector(M-1 downto 0); 
           w08      : in std_logic_vector(M-1 downto 0); 
           w09      : in std_logic_vector(M-1 downto 0); 
           w10      : in std_logic_vector(M-1 downto 0); 
           w11      : in std_logic_vector(M-1 downto 0); 
           w12      : in std_logic_vector(M-1 downto 0); 
           w13      : in std_logic_vector(M-1 downto 0); 
           w14      : in std_logic_vector(M-1 downto 0); 
           w15      : in std_logic_vector(M-1 downto 0); 
           w16      : in std_logic_vector(M-1 downto 0); 
           w17      : in std_logic_vector(M-1 downto 0); 
           w18      : in std_logic_vector(M-1 downto 0); 
           w19      : in std_logic_vector(M-1 downto 0); 
           w20      : in std_logic_vector(M-1 downto 0); 
           w21      : in std_logic_vector(M-1 downto 0); 
           w22      : in std_logic_vector(M-1 downto 0); 
           w23      : in std_logic_vector(M-1 downto 0); 
           w24      : in std_logic_vector(M-1 downto 0); 
           w25      : in std_logic_vector(M-1 downto 0); 
           w26      : in std_logic_vector(M-1 downto 0); 
           w27      : in std_logic_vector(M-1 downto 0); 
           w28      : in std_logic_vector(M-1 downto 0); 
           w29      : in std_logic_vector(M-1 downto 0); 
           w30      : in std_logic_vector(M-1 downto 0); 
           w31      : in std_logic_vector(M-1 downto 0); 
           w32      : in std_logic_vector(M-1 downto 0); 
           w33      : in std_logic_vector(M-1 downto 0); 
           w34      : in std_logic_vector(M-1 downto 0); 
           w35      : in std_logic_vector(M-1 downto 0); 
           w36      : in std_logic_vector(M-1 downto 0); 
           w37      : in std_logic_vector(M-1 downto 0); 
           w38      : in std_logic_vector(M-1 downto 0); 
           w39      : in std_logic_vector(M-1 downto 0); 
           w40      : in std_logic_vector(M-1 downto 0); 
           w41      : in std_logic_vector(M-1 downto 0); 
           w42      : in std_logic_vector(M-1 downto 0); 
           w43      : in std_logic_vector(M-1 downto 0); 
           w44      : in std_logic_vector(M-1 downto 0); 
           w45      : in std_logic_vector(M-1 downto 0); 
           w46      : in std_logic_vector(M-1 downto 0); 
           w47      : in std_logic_vector(M-1 downto 0); 
           w48      : in std_logic_vector(M-1 downto 0); 
           w49      : in std_logic_vector(M-1 downto 0); 
           w50      : in std_logic_vector(M-1 downto 0); 
           w51      : in std_logic_vector(M-1 downto 0); 
           w52      : in std_logic_vector(M-1 downto 0); 
           w53      : in std_logic_vector(M-1 downto 0); 
           w54      : in std_logic_vector(M-1 downto 0); 
           w55      : in std_logic_vector(M-1 downto 0); 
           w56      : in std_logic_vector(M-1 downto 0); 
           w57      : in std_logic_vector(M-1 downto 0); 
           w58      : in std_logic_vector(M-1 downto 0); 
           w59      : in std_logic_vector(M-1 downto 0); 
           w60      : in std_logic_vector(M-1 downto 0); 
           w61      : in std_logic_vector(M-1 downto 0); 
           w62      : in std_logic_vector(M-1 downto 0); 
           w63      : in std_logic_vector(M-1 downto 0); 
           w64      : in std_logic_vector(M-1 downto 0); 

           d_out   : out std_logic_vector (N + M + 5 downto 0);
           en_out  : out std_logic;
           sof_out : out std_logic);
end component;

type rom_type is array ( 0 to 15 ) of std_logic_vector( 7 downto 0 ) ;

constant weight01 : rom_type := ( 0 => x"00", 1 => x"17", 2 => x"92", 3 => x"14", 4 => x"61", 5 => x"27", 6 => x"53", 7 => x"60", 8 => x"11", 9 => x"61", others => x"00"); 
constant weight02 : rom_type := ( 0 => x"00", 1 => x"35", 2 => x"40", 3 => x"10", 4 => x"87", 5 => x"96", 6 => x"39", 7 => x"66", 8 => x"98", 9 => x"51", others => x"00"); 
constant weight03 : rom_type := ( 0 => x"00", 1 => x"85", 2 => x"48", 3 => x"56", 4 => x"67", 5 => x"82", 6 => x"28", 7 => x"70", 8 => x"72", 9 => x"58", others => x"00"); 
constant weight04 : rom_type := ( 0 => x"00", 1 => x"93", 2 => x"41", 3 => x"26", 4 => x"13", 5 => x"77", 6 => x"10", 7 => x"83", 8 => x"66", 9 => x"44", others => x"00"); 
constant weight05 : rom_type := ( 0 => x"00", 1 => x"88", 2 => x"82", 3 => x"74", 4 => x"24", 5 => x"10", 6 => x"41", 7 => x"99", 8 => x"61", 9 => x"53", others => x"00"); 
constant weight06 : rom_type := ( 0 => x"00", 1 => x"48", 2 => x"64", 3 => x"38", 4 => x"89", 5 => x"84", 6 => x"83", 7 => x"89", 8 => x"58", 9 => x"47", others => x"00"); 
constant weight07 : rom_type := ( 0 => x"00", 1 => x"35", 2 => x"79", 3 => x"73", 4 => x"99", 5 => x"67", 6 => x"26", 7 => x"82", 8 => x"39", 9 => x"49", others => x"00"); 
constant weight08 : rom_type := ( 0 => x"00", 1 => x"24", 2 => x"61", 3 => x"52", 4 => x"55", 5 => x"18", 6 => x"66", 7 => x"46", 8 => x"91", 9 => x"56", others => x"00"); 
constant weight09 : rom_type := ( 0 => x"00", 1 => x"43", 2 => x"16", 3 => x"32", 4 => x"43", 5 => x"81", 6 => x"49", 7 => x"99", 8 => x"51", 9 => x"42", others => x"00"); 
constant weight10 : rom_type := ( 0 => x"00", 1 => x"21", 2 => x"70", 3 => x"90", 4 => x"23", 5 => x"19", 6 => x"36", 7 => x"92", 8 => x"64", 9 => x"34", others => x"00"); 
constant weight11 : rom_type := ( 0 => x"00", 1 => x"19", 2 => x"70", 3 => x"58", 4 => x"17", 5 => x"49", 6 => x"28", 7 => x"34", 8 => x"28", 9 => x"78", others => x"00"); 
constant weight12 : rom_type := ( 0 => x"00", 1 => x"34", 2 => x"54", 3 => x"61", 4 => x"29", 5 => x"42", 6 => x"61", 7 => x"35", 8 => x"90", 9 => x"59", others => x"00"); 
constant weight13 : rom_type := ( 0 => x"00", 1 => x"23", 2 => x"20", 3 => x"51", 4 => x"10", 5 => x"83", 6 => x"64", 7 => x"24", 8 => x"15", 9 => x"69", others => x"00"); 
constant weight14 : rom_type := ( 0 => x"00", 1 => x"33", 2 => x"35", 3 => x"38", 4 => x"42", 5 => x"13", 6 => x"20", 7 => x"52", 8 => x"54", 9 => x"87", others => x"00"); 
constant weight15 : rom_type := ( 0 => x"00", 1 => x"11", 2 => x"11", 3 => x"77", 4 => x"58", 5 => x"54", 6 => x"55", 7 => x"12", 8 => x"13", 9 => x"53", others => x"00"); 
constant weight16 : rom_type := ( 0 => x"00", 1 => x"47", 2 => x"60", 3 => x"59", 4 => x"65", 5 => x"44", 6 => x"70", 7 => x"82", 8 => x"36", 9 => x"92", others => x"00"); 
constant weight17 : rom_type := ( 0 => x"00", 1 => x"35", 2 => x"94", 3 => x"56", 4 => x"40", 5 => x"16", 6 => x"76", 7 => x"46", 8 => x"72", 9 => x"36", others => x"00"); 
constant weight18 : rom_type := ( 0 => x"00", 1 => x"39", 2 => x"84", 3 => x"41", 4 => x"67", 5 => x"62", 6 => x"87", 7 => x"97", 8 => x"67", 9 => x"65", others => x"00"); 
constant weight19 : rom_type := ( 0 => x"00", 1 => x"96", 2 => x"96", 3 => x"12", 4 => x"91", 5 => x"98", 6 => x"46", 7 => x"50", 8 => x"77", 9 => x"60", others => x"00"); 
constant weight20 : rom_type := ( 0 => x"00", 1 => x"89", 2 => x"89", 3 => x"27", 4 => x"56", 5 => x"79", 6 => x"69", 7 => x"20", 8 => x"34", 9 => x"73", others => x"00"); 
constant weight21 : rom_type := ( 0 => x"00", 1 => x"61", 2 => x"79", 3 => x"15", 4 => x"36", 5 => x"10", 6 => x"71", 7 => x"41", 8 => x"35", 9 => x"34", others => x"00"); 
constant weight22 : rom_type := ( 0 => x"00", 1 => x"59", 2 => x"97", 3 => x"32", 4 => x"56", 5 => x"69", 6 => x"70", 7 => x"41", 8 => x"87", 9 => x"40", others => x"00"); 
constant weight23 : rom_type := ( 0 => x"00", 1 => x"32", 2 => x"19", 3 => x"63", 4 => x"12", 5 => x"51", 6 => x"20", 7 => x"30", 8 => x"49", 9 => x"88", others => x"00"); 
constant weight24 : rom_type := ( 0 => x"00", 1 => x"25", 2 => x"58", 3 => x"56", 4 => x"95", 5 => x"92", 6 => x"69", 7 => x"89", 8 => x"76", 9 => x"21", others => x"00"); 
constant weight25 : rom_type := ( 0 => x"00", 1 => x"44", 2 => x"99", 3 => x"99", 4 => x"71", 5 => x"46", 6 => x"39", 7 => x"88", 8 => x"96", 9 => x"19", others => x"00"); 
constant weight26 : rom_type := ( 0 => x"00", 1 => x"69", 2 => x"15", 3 => x"67", 4 => x"53", 5 => x"52", 6 => x"84", 7 => x"30", 8 => x"41", 9 => x"79", others => x"00"); 
constant weight27 : rom_type := ( 0 => x"00", 1 => x"52", 2 => x"91", 3 => x"30", 4 => x"23", 5 => x"11", 6 => x"36", 7 => x"98", 8 => x"32", 9 => x"46", others => x"00"); 
constant weight28 : rom_type := ( 0 => x"00", 1 => x"11", 2 => x"99", 3 => x"67", 4 => x"28", 5 => x"71", 6 => x"99", 7 => x"17", 8 => x"97", 9 => x"56", others => x"00"); 
constant weight29 : rom_type := ( 0 => x"00", 1 => x"77", 2 => x"25", 3 => x"78", 4 => x"63", 5 => x"50", 6 => x"32", 7 => x"33", 8 => x"59", 9 => x"71", others => x"00"); 
constant weight30 : rom_type := ( 0 => x"00", 1 => x"47", 2 => x"66", 3 => x"48", 4 => x"12", 5 => x"84", 6 => x"36", 7 => x"70", 8 => x"31", 9 => x"61", others => x"00"); 
constant weight31 : rom_type := ( 0 => x"00", 1 => x"75", 2 => x"84", 3 => x"84", 4 => x"14", 5 => x"14", 6 => x"62", 7 => x"20", 8 => x"70", 9 => x"94", others => x"00"); 
constant weight32 : rom_type := ( 0 => x"00", 1 => x"99", 2 => x"14", 3 => x"18", 4 => x"81", 5 => x"56", 6 => x"51", 7 => x"23", 8 => x"58", 9 => x"76", others => x"00"); 
constant weight33 : rom_type := ( 0 => x"00", 1 => x"44", 2 => x"77", 3 => x"26", 4 => x"24", 5 => x"50", 6 => x"66", 7 => x"26", 8 => x"36", 9 => x"88", others => x"00"); 
constant weight34 : rom_type := ( 0 => x"00", 1 => x"76", 2 => x"46", 3 => x"82", 4 => x"49", 5 => x"33", 6 => x"98", 7 => x"90", 8 => x"92", 9 => x"16", others => x"00"); 
constant weight35 : rom_type := ( 0 => x"00", 1 => x"31", 2 => x"30", 3 => x"59", 4 => x"30", 5 => x"68", 6 => x"56", 7 => x"70", 8 => x"42", 9 => x"34", others => x"00"); 
constant weight36 : rom_type := ( 0 => x"00", 1 => x"74", 2 => x"90", 3 => x"26", 4 => x"34", 5 => x"85", 6 => x"41", 7 => x"80", 8 => x"50", 9 => x"70", others => x"00"); 
constant weight37 : rom_type := ( 0 => x"00", 1 => x"69", 2 => x"57", 3 => x"57", 4 => x"60", 5 => x"78", 6 => x"62", 7 => x"11", 8 => x"29", 9 => x"36", others => x"00"); 
constant weight38 : rom_type := ( 0 => x"00", 1 => x"40", 2 => x"76", 3 => x"68", 4 => x"54", 5 => x"46", 6 => x"11", 7 => x"24", 8 => x"21", 9 => x"21", others => x"00"); 
constant weight39 : rom_type := ( 0 => x"00", 1 => x"98", 2 => x"58", 3 => x"54", 4 => x"75", 5 => x"93", 6 => x"45", 7 => x"71", 8 => x"82", 9 => x"24", others => x"00"); 
constant weight40 : rom_type := ( 0 => x"00", 1 => x"20", 2 => x"77", 3 => x"26", 4 => x"37", 5 => x"84", 6 => x"98", 7 => x"20", 8 => x"78", 9 => x"43", others => x"00"); 
constant weight41 : rom_type := ( 0 => x"00", 1 => x"64", 2 => x"45", 3 => x"40", 4 => x"31", 5 => x"26", 6 => x"35", 7 => x"74", 8 => x"98", 9 => x"32", others => x"00"); 
constant weight42 : rom_type := ( 0 => x"00", 1 => x"93", 2 => x"63", 3 => x"29", 4 => x"58", 5 => x"30", 6 => x"32", 7 => x"58", 8 => x"47", 9 => x"43", others => x"00"); 
constant weight43 : rom_type := ( 0 => x"00", 1 => x"47", 2 => x"89", 3 => x"14", 4 => x"50", 5 => x"11", 6 => x"65", 7 => x"87", 8 => x"73", 9 => x"23", others => x"00"); 
constant weight44 : rom_type := ( 0 => x"00", 1 => x"69", 2 => x"86", 3 => x"67", 4 => x"41", 5 => x"68", 6 => x"33", 7 => x"92", 8 => x"24", 9 => x"70", others => x"00"); 
constant weight45 : rom_type := ( 0 => x"00", 1 => x"98", 2 => x"95", 3 => x"94", 4 => x"47", 5 => x"67", 6 => x"35", 7 => x"72", 8 => x"19", 9 => x"62", others => x"00"); 
constant weight46 : rom_type := ( 0 => x"00", 1 => x"80", 2 => x"76", 3 => x"15", 4 => x"96", 5 => x"79", 6 => x"35", 7 => x"89", 8 => x"93", 9 => x"29", others => x"00"); 
constant weight47 : rom_type := ( 0 => x"00", 1 => x"49", 2 => x"54", 3 => x"49", 4 => x"37", 5 => x"57", 6 => x"76", 7 => x"51", 8 => x"75", 9 => x"63", others => x"00"); 
constant weight48 : rom_type := ( 0 => x"00", 1 => x"33", 2 => x"56", 3 => x"13", 4 => x"95", 5 => x"90", 6 => x"99", 7 => x"51", 8 => x"22", 9 => x"30", others => x"00"); 
constant weight49 : rom_type := ( 0 => x"00", 1 => x"29", 2 => x"66", 3 => x"72", 4 => x"60", 5 => x"77", 6 => x"83", 7 => x"36", 8 => x"99", 9 => x"58", others => x"00"); 
constant weight50 : rom_type := ( 0 => x"00", 1 => x"72", 2 => x"62", 3 => x"83", 4 => x"77", 5 => x"84", 6 => x"81", 7 => x"13", 8 => x"90", 9 => x"63", others => x"00"); 
constant weight51 : rom_type := ( 0 => x"00", 1 => x"52", 2 => x"74", 3 => x"40", 4 => x"72", 5 => x"86", 6 => x"64", 7 => x"44", 8 => x"63", 9 => x"93", others => x"00"); 
constant weight52 : rom_type := ( 0 => x"00", 1 => x"97", 2 => x"64", 3 => x"95", 4 => x"40", 5 => x"80", 6 => x"75", 7 => x"44", 8 => x"87", 9 => x"37", others => x"00"); 
constant weight53 : rom_type := ( 0 => x"00", 1 => x"39", 2 => x"85", 3 => x"15", 4 => x"19", 5 => x"99", 6 => x"72", 7 => x"92", 8 => x"89", 9 => x"23", others => x"00"); 
constant weight54 : rom_type := ( 0 => x"00", 1 => x"69", 2 => x"81", 3 => x"22", 4 => x"89", 5 => x"16", 6 => x"80", 7 => x"50", 8 => x"75", 9 => x"35", others => x"00"); 
constant weight55 : rom_type := ( 0 => x"00", 1 => x"96", 2 => x"77", 3 => x"69", 4 => x"57", 5 => x"90", 6 => x"26", 7 => x"54", 8 => x"60", 9 => x"15", others => x"00"); 
constant weight56 : rom_type := ( 0 => x"00", 1 => x"19", 2 => x"87", 3 => x"38", 4 => x"53", 5 => x"82", 6 => x"77", 7 => x"44", 8 => x"86", 9 => x"67", others => x"00"); 
constant weight57 : rom_type := ( 0 => x"00", 1 => x"61", 2 => x"95", 3 => x"32", 4 => x"59", 5 => x"68", 6 => x"71", 7 => x"93", 8 => x"24", 9 => x"35", others => x"00"); 
constant weight58 : rom_type := ( 0 => x"00", 1 => x"88", 2 => x"88", 3 => x"98", 4 => x"96", 5 => x"13", 6 => x"52", 7 => x"23", 8 => x"62", 9 => x"67", others => x"00"); 
constant weight59 : rom_type := ( 0 => x"00", 1 => x"80", 2 => x"20", 3 => x"80", 4 => x"34", 5 => x"83", 6 => x"77", 7 => x"76", 8 => x"17", 9 => x"87", others => x"00"); 
constant weight60 : rom_type := ( 0 => x"00", 1 => x"26", 2 => x"69", 3 => x"38", 4 => x"61", 5 => x"34", 6 => x"18", 7 => x"39", 8 => x"10", 9 => x"64", others => x"00"); 
constant weight61 : rom_type := ( 0 => x"00", 1 => x"25", 2 => x"75", 3 => x"60", 4 => x"85", 5 => x"16", 6 => x"81", 7 => x"92", 8 => x"70", 9 => x"47", others => x"00"); 
constant weight62 : rom_type := ( 0 => x"00", 1 => x"11", 2 => x"35", 3 => x"82", 4 => x"83", 5 => x"99", 6 => x"84", 7 => x"75", 8 => x"77", 9 => x"42", others => x"00"); 
constant weight63 : rom_type := ( 0 => x"00", 1 => x"22", 2 => x"47", 3 => x"53", 4 => x"71", 5 => x"19", 6 => x"83", 7 => x"43", 8 => x"53", 9 => x"81", others => x"00"); 
constant weight64 : rom_type := ( 0 => x"00", 1 => x"59", 2 => x"76", 3 => x"96", 4 => x"66", 5 => x"48", 6 => x"67", 7 => x"68", 8 => x"74", 9 => x"72", others => x"00"); 


-- weight init 

signal  w01_in    : std_logic_vector(M-1 downto 0);
signal  w02_in    : std_logic_vector(M-1 downto 0);
signal  w03_in    : std_logic_vector(M-1 downto 0);
signal  w04_in    : std_logic_vector(M-1 downto 0);
signal  w05_in    : std_logic_vector(M-1 downto 0);
signal  w06_in    : std_logic_vector(M-1 downto 0);
signal  w07_in    : std_logic_vector(M-1 downto 0);
signal  w08_in    : std_logic_vector(M-1 downto 0);
signal  w09_in    : std_logic_vector(M-1 downto 0);
signal  w10_in    : std_logic_vector(M-1 downto 0);
signal  w11_in    : std_logic_vector(M-1 downto 0);
signal  w12_in    : std_logic_vector(M-1 downto 0);
signal  w13_in    : std_logic_vector(M-1 downto 0);
signal  w14_in    : std_logic_vector(M-1 downto 0);
signal  w15_in    : std_logic_vector(M-1 downto 0);
signal  w16_in    : std_logic_vector(M-1 downto 0);
signal  w17_in    : std_logic_vector(M-1 downto 0);
signal  w18_in    : std_logic_vector(M-1 downto 0);
signal  w19_in    : std_logic_vector(M-1 downto 0);
signal  w20_in    : std_logic_vector(M-1 downto 0);
signal  w21_in    : std_logic_vector(M-1 downto 0);
signal  w22_in    : std_logic_vector(M-1 downto 0);
signal  w23_in    : std_logic_vector(M-1 downto 0);
signal  w24_in    : std_logic_vector(M-1 downto 0);
signal  w25_in    : std_logic_vector(M-1 downto 0);
signal  w26_in    : std_logic_vector(M-1 downto 0);
signal  w27_in    : std_logic_vector(M-1 downto 0);
signal  w28_in    : std_logic_vector(M-1 downto 0);
signal  w29_in    : std_logic_vector(M-1 downto 0);
signal  w30_in    : std_logic_vector(M-1 downto 0);
signal  w31_in    : std_logic_vector(M-1 downto 0);
signal  w32_in    : std_logic_vector(M-1 downto 0);
signal  w33_in    : std_logic_vector(M-1 downto 0);
signal  w34_in    : std_logic_vector(M-1 downto 0);
signal  w35_in    : std_logic_vector(M-1 downto 0);
signal  w36_in    : std_logic_vector(M-1 downto 0);
signal  w37_in    : std_logic_vector(M-1 downto 0);
signal  w38_in    : std_logic_vector(M-1 downto 0);
signal  w39_in    : std_logic_vector(M-1 downto 0);
signal  w40_in    : std_logic_vector(M-1 downto 0);
signal  w41_in    : std_logic_vector(M-1 downto 0);
signal  w42_in    : std_logic_vector(M-1 downto 0);
signal  w43_in    : std_logic_vector(M-1 downto 0);
signal  w44_in    : std_logic_vector(M-1 downto 0);
signal  w45_in    : std_logic_vector(M-1 downto 0);
signal  w46_in    : std_logic_vector(M-1 downto 0);
signal  w47_in    : std_logic_vector(M-1 downto 0);
signal  w48_in    : std_logic_vector(M-1 downto 0);
signal  w49_in    : std_logic_vector(M-1 downto 0);
signal  w50_in    : std_logic_vector(M-1 downto 0);
signal  w51_in    : std_logic_vector(M-1 downto 0);
signal  w52_in    : std_logic_vector(M-1 downto 0);
signal  w53_in    : std_logic_vector(M-1 downto 0);
signal  w54_in    : std_logic_vector(M-1 downto 0);
signal  w55_in    : std_logic_vector(M-1 downto 0);
signal  w56_in    : std_logic_vector(M-1 downto 0);
signal  w57_in    : std_logic_vector(M-1 downto 0);
signal  w58_in    : std_logic_vector(M-1 downto 0);
signal  w59_in    : std_logic_vector(M-1 downto 0);
signal  w60_in    : std_logic_vector(M-1 downto 0);
signal  w61_in    : std_logic_vector(M-1 downto 0);
signal  w62_in    : std_logic_vector(M-1 downto 0);
signal  w63_in    : std_logic_vector(M-1 downto 0);
signal  w64_in    : std_logic_vector(M-1 downto 0);


signal  w_num       : std_logic_vector(  3 downto 0);
signal  w_en        : std_logic;
signal  w_count     : std_logic_vector(  3 downto 0);
signal  w_count_en  : std_logic;
signal  w_count_en2 : std_logic;

-- conv layer
constant CL_W       : integer := N+M+4; -- output data width
constant CL_SR      : integer := 0; -- data shift right before output
signal  cl_en_out, cl_sof_out: std_logic;
signal  d01_out       : std_logic_vector (CL_W-1 downto 0);
signal  d02_out       : std_logic_vector (CL_W-1 downto 0);
signal  d03_out       : std_logic_vector (CL_W-1 downto 0);
signal  d04_out       : std_logic_vector (CL_W-1 downto 0);
signal  d05_out       : std_logic_vector (CL_W-1 downto 0);
signal  d06_out       : std_logic_vector (CL_W-1 downto 0);
signal  d07_out       : std_logic_vector (CL_W-1 downto 0);
signal  d08_out       : std_logic_vector (CL_W-1 downto 0);
signal  d09_out       : std_logic_vector (CL_W-1 downto 0);
signal  d10_out       : std_logic_vector (CL_W-1 downto 0);
signal  d11_out       : std_logic_vector (CL_W-1 downto 0);
signal  d12_out       : std_logic_vector (CL_W-1 downto 0);
signal  d13_out       : std_logic_vector (CL_W-1 downto 0);
signal  d14_out       : std_logic_vector (CL_W-1 downto 0);
signal  d15_out       : std_logic_vector (CL_W-1 downto 0);
signal  d16_out       : std_logic_vector (CL_W-1 downto 0);
signal  d17_out       : std_logic_vector (CL_W-1 downto 0);
signal  d18_out       : std_logic_vector (CL_W-1 downto 0);
signal  d19_out       : std_logic_vector (CL_W-1 downto 0);
signal  d20_out       : std_logic_vector (CL_W-1 downto 0);
signal  d21_out       : std_logic_vector (CL_W-1 downto 0);
signal  d22_out       : std_logic_vector (CL_W-1 downto 0);
signal  d23_out       : std_logic_vector (CL_W-1 downto 0);
signal  d24_out       : std_logic_vector (CL_W-1 downto 0);
signal  d25_out       : std_logic_vector (CL_W-1 downto 0);
signal  d26_out       : std_logic_vector (CL_W-1 downto 0);
signal  d27_out       : std_logic_vector (CL_W-1 downto 0);
signal  d28_out       : std_logic_vector (CL_W-1 downto 0);
signal  d29_out       : std_logic_vector (CL_W-1 downto 0);
signal  d30_out       : std_logic_vector (CL_W-1 downto 0);
signal  d31_out       : std_logic_vector (CL_W-1 downto 0);
signal  d32_out       : std_logic_vector (CL_W-1 downto 0);
signal  d33_out       : std_logic_vector (CL_W-1 downto 0);
signal  d34_out       : std_logic_vector (CL_W-1 downto 0);
signal  d35_out       : std_logic_vector (CL_W-1 downto 0);
signal  d36_out       : std_logic_vector (CL_W-1 downto 0);
signal  d37_out       : std_logic_vector (CL_W-1 downto 0);
signal  d38_out       : std_logic_vector (CL_W-1 downto 0);
signal  d39_out       : std_logic_vector (CL_W-1 downto 0);
signal  d40_out       : std_logic_vector (CL_W-1 downto 0);
signal  d41_out       : std_logic_vector (CL_W-1 downto 0);
signal  d42_out       : std_logic_vector (CL_W-1 downto 0);
signal  d43_out       : std_logic_vector (CL_W-1 downto 0);
signal  d44_out       : std_logic_vector (CL_W-1 downto 0);
signal  d45_out       : std_logic_vector (CL_W-1 downto 0);
signal  d46_out       : std_logic_vector (CL_W-1 downto 0);
signal  d47_out       : std_logic_vector (CL_W-1 downto 0);
signal  d48_out       : std_logic_vector (CL_W-1 downto 0);
signal  d49_out       : std_logic_vector (CL_W-1 downto 0);
signal  d50_out       : std_logic_vector (CL_W-1 downto 0);
signal  d51_out       : std_logic_vector (CL_W-1 downto 0);
signal  d52_out       : std_logic_vector (CL_W-1 downto 0);
signal  d53_out       : std_logic_vector (CL_W-1 downto 0);
signal  d54_out       : std_logic_vector (CL_W-1 downto 0);
signal  d55_out       : std_logic_vector (CL_W-1 downto 0);
signal  d56_out       : std_logic_vector (CL_W-1 downto 0);
signal  d57_out       : std_logic_vector (CL_W-1 downto 0);
signal  d58_out       : std_logic_vector (CL_W-1 downto 0);
signal  d59_out       : std_logic_vector (CL_W-1 downto 0);
signal  d60_out       : std_logic_vector (CL_W-1 downto 0);
signal  d61_out       : std_logic_vector (CL_W-1 downto 0);
signal  d62_out       : std_logic_vector (CL_W-1 downto 0);
signal  d63_out       : std_logic_vector (CL_W-1 downto 0);
signal  d64_out       : std_logic_vector (CL_W-1 downto 0);

-- PCA weights
type PCArom_type is array ( 0 to 63 ) of std_logic_vector(64*8-1 downto 0 ) ;
constant PCAweight64 : 
PCArom_type := 
(  0 => x"52208362221476639939641397714843967281603451599978249459475456509872109434164133609996835373475696848033364030117262759726355567", 
   1 => x"39479722152029937557316143576396488783968217391482792389546537461462415185922718683874834958653595811077874139698551128541354250", 
   2 => x"67935477953368388160116386621876266327806177756618666383969613261511937950288876871857783552288537357971466563147769228465153360", 
   3 => x"77915378196732124979802182723284566862659773547594474525494484604723627898991269472017799544643350569437694178102933854138653982", 
   4 => x"46186242559966639446748085743576602596548148857710704874535490716457694335438098592755624420431766255731776088577173489543974217", 
   5 => x"67609060131937844549365868549753656153243138233897386636326925701834842843186849984645228035668828568942574262492875769723952965", 
   6 => x"78858963169520185910372285635140311413624484276018763444384516697159534867234291451866225242142861373957645144704951403382428786", 
   7 => x"45504956256787457976468065367596436686609394827783656672565077559615583371769231308958909254879790612945293171913841355626932596", 
   8 => x"57721828555431494280981312827780776448328362379017254047604012507652163960479620625181316837971655486588128683142040504760636174", 
   9 => x"67711614473273496573439846881294812943868681534724713348205664369071358029218399551375396119808366357232526549797522295376392325",
  10 => x"75881432798932634435881011158862571978866388617414779255845295477973859799926397861223526772672091194266104242146141666833489363", 
  11 => x"61691081563627564386505973457069538956806377702545657325605448297988941028598529119361943029254472698258527218511168516963404678", 
  12 => x"84803732277171417166678320361267449127509153497126471991753027198880784281452393724557127232907389916574974044691574463982594930", 
  13 => x"18848174787829266969558493616788597867895484418246467291472838352078695116469576579323576077602296346912869426175267259272112863", 
  14 => x"93131539381260646954892737538245417713161555381384401541191151759986876567226339137394795222883342589771379351147850599114953460", 
  15 => x"10612762865170275257231528738057785713973432192615503280497132355694666513628392901451816795147330675983365965359340739441921840", 
  16 => x"11624196141168543815588349224497626385881188533785448669852942943527611582126628516895512961938294485335903833774562886828496434", 
  17 => x"78197247664631153587535643935973616932274239982392373683745762183987686449186719483641972039841912863633309631229446461765929741", 
  18 => x"78106795523824509344286288949526374486968688913974371916961720956946113352357090374916654662456824348281741416251193212616917360", 
  19 => x"96964148127667571461826965571148687724742859431960205815224486835151716652269515114448786651421546226627845759182259893948776327",
  20 => x"25786476958895291251498597411158691054154319249312268314529328444871734940191838788116669582192356688835951344843056819631987984", 
  21 => x"33196718522277306941657876406988567736696466287334444398759926599893433344187988421381834945782522199129242175891318487417882730", 
  22 => x"31573729614910963053224991813050957593158329879481467739248035968846758696488756691296832038532633165633945041272659855280758621", 
  23 => x"50691541312031886568389618357668387726446195917856855790542516961247669244914830168091616958212327837484213069506148586689123562", 
  24 => x"58433068575130925817758871198493423250635672818057951192952987379947572054246044438576359419127946421584637918872192464812475771", 
  25 => x"27905574516216288180604477817550121077243733829814409343864283343536298789405386713512964572466423181156497828488819325574131287", 
  26 => x"56831629848814926662382317814741892856496099906588706841271389314262913639845852557125843467578515657347901826778455734937939568", 
  27 => x"50215235343744495436896919964735685187426539892468605165275437439612577169696875184260159717377763807464235024943471473516709323", 
  28 => x"35489692478987821582318518448613465396497416393595827613479959966950267028764555658186892718355896384466272892638014163239586338", 
  29 => x"88119954622065633320327930623712123398605420594719758412971291496147664526179533249469193659707398322739916914686744514632499886", 
  30 => x"51821917265259676811372421701222245028133570377891697529161176915422641129765671782583124186167953949754538919652052927322935776", 
  31 => x"72292781644227556270352232287315876123587432611118767545792316395023449833694870932211105634979357504490272290663340324336366279", 
  32 => x"66147072224088304484245044216750921341954123506168783896584442137192659436739436951733556866222453794284754345329572478012603940", 
  33 => x"66434589872488504167568826449447713247274526166386844682892878952729265190805587887546279053744327936694658641486095462740423995", 
  34 => x"35124777919427894476415012116312514678806482993042799369808758128890263232969336447613818136735788166566689178418980872537924565", 
  35 => x"78449363922254985598301283725346967886688835977895768241975140425596961138515088276248171980479896536346425598654262551682735769", 
  36 => x"68229798856376468268516239506848561119985285395964492189496835456119809578505383933575219614566969486384942178359277839328792091", 
  37 => x"37634816721775879887266574184861468513795645187854165285922926374330645028547514511952766759365898833430336873551321745065101483", 
  38 => x"59258199535166884682319983223840637215345944483954263883255414755687394635247561465055932610542624898054143814436719947170149319", 
  39 => x"89719060675910823346409766535511153591897665589058198112936540858370941441872820731845881338634755278965861975905812512313576619", 
  40 => x"73592295194920636074736420573616454429224537753358147941575232319838529563912852173781597825301367609363144467704168871627717092", 
  41 => x"98628180323447575022527931741298133597917940839791727190508976368299473251602485298696441351784127173611582954982224493484362137", 
  42 => x"34964038833842546254409755972694242426171121494465813192252685785988907288699037269397741931556673666259265489242726581455115821", 
  43 => x"47742152427950343868475863718532225486527564848245248888455136684580809789804942197090188623207212698781751518573769448447793183", 
  44 => x"30775823453149674512977888924125407880771042135473911887757988372758488380862857549356112033578729202467394558844380679334795892", 
  45 => x"11325338204998553637385342694589981430484951183986675096115581691842686542983870476751452482586568256974909974488542899366958034", 
  46 => x"82976634589466878843597610679462889086458115101391376084733750406452141845451443413733827873733023996931672995539893373884635613", 
  47 => x"70109076501979208499377138645423159398716463854769297848243616715464521234428170938181152396976959665563119574445961281377294636", 
  48 => x"66312376778334552960355039223737678730202881501270664968462983594152872225847362494517863914892198999592919197332121668499216246", 
  49 => x"26161150897457389035908832758558464860101173992128827186323611337351181431767848467495994432539216611097389215629656946979845985", 
  50 => x"69187959265321748482338293713334415627809993204984625611289064203448641957186071941327437074177082548649201739675059205037783238", 
  51 => x"18983772989923117942601280878818656350653990555134243620662924319024387065833571195053799675813790662956364185616172142580845825", 
  52 => x"58297866538030864434519289673966265525584638763236177670737764497015232035371617194536674075944267878016713115887852396113517717", 
  53 => x"40465628734083573768742085794612117057781730499687551889133438769035207125146466469052179163398685656654659699963553897014857911", 
  54 => x"76967660907988792148265113461989942075329467484431333234695537721880818270105085142164686084889252913672656942891825582986524096", 
  55 => x"36454194411383698054338081345753262845102211539142626452868033989785449064617859971788859169118746421549477044188919245370112340", 
  56 => x"23437675634465874989179411676195244180651062391823522697984390634280713336197078515118399317473529395892219637123266526210424182", 
  57 => x"61612741147294823132205695337695159760667979953871324149969443359073799978362682248796591381842954877345927934369330358619661442", 
  58 => x"11285943998636665739809831876847412081142065748750438766329560797090932829752648548693117273632848156924349387716275251181724083", 
  59 => x"69107994195346777647662373692098983481372284103031357546946550692830582630292898576978402557577711379194774042943466898848107138", 
  60 => x"42497832893382217681224285674917172538874530709631304035838422337335744912921131436232316976839279679358824148563076614078709587", 
  61 => x"73548468825335269454565986628470369066166899391668623023456580626111127857167275228146161380918212291337772596315433802617763892", 
  62 => x"44491720314133507981112391977770675352109478771095164259694644416047216449226889383121803895769084622480842581473178217980686951", 
  63 => x"78729680555083337952274282155195176159583364644713967333271179121386606663778962929752881442635240278589911677871574137783247488"
  ); 
signal pca_w01  : std_logic_vector(7 downto 0); 
signal pca_w02  : std_logic_vector(7 downto 0); 
signal pca_w03  : std_logic_vector(7 downto 0); 
signal pca_w04  : std_logic_vector(7 downto 0); 
signal pca_w05  : std_logic_vector(7 downto 0); 
signal pca_w06  : std_logic_vector(7 downto 0); 
signal pca_w07  : std_logic_vector(7 downto 0); 
signal pca_w08  : std_logic_vector(7 downto 0); 
signal pca_w09  : std_logic_vector(7 downto 0); 
signal pca_w10  : std_logic_vector(7 downto 0); 
signal pca_w11  : std_logic_vector(7 downto 0); 
signal pca_w12  : std_logic_vector(7 downto 0); 
signal pca_w13  : std_logic_vector(7 downto 0); 
signal pca_w14  : std_logic_vector(7 downto 0); 
signal pca_w15  : std_logic_vector(7 downto 0); 
signal pca_w16  : std_logic_vector(7 downto 0); 
signal pca_w17  : std_logic_vector(7 downto 0); 
signal pca_w18  : std_logic_vector(7 downto 0); 
signal pca_w19  : std_logic_vector(7 downto 0); 
signal pca_w20  : std_logic_vector(7 downto 0); 
signal pca_w21  : std_logic_vector(7 downto 0); 
signal pca_w22  : std_logic_vector(7 downto 0); 
signal pca_w23  : std_logic_vector(7 downto 0); 
signal pca_w24  : std_logic_vector(7 downto 0); 
signal pca_w25  : std_logic_vector(7 downto 0); 
signal pca_w26  : std_logic_vector(7 downto 0); 
signal pca_w27  : std_logic_vector(7 downto 0); 
signal pca_w28  : std_logic_vector(7 downto 0); 
signal pca_w29  : std_logic_vector(7 downto 0); 
signal pca_w30  : std_logic_vector(7 downto 0); 
signal pca_w31  : std_logic_vector(7 downto 0); 
signal pca_w32  : std_logic_vector(7 downto 0); 
signal pca_w33  : std_logic_vector(7 downto 0); 
signal pca_w34  : std_logic_vector(7 downto 0); 
signal pca_w35  : std_logic_vector(7 downto 0); 
signal pca_w36  : std_logic_vector(7 downto 0); 
signal pca_w37  : std_logic_vector(7 downto 0); 
signal pca_w38  : std_logic_vector(7 downto 0); 
signal pca_w39  : std_logic_vector(7 downto 0); 
signal pca_w40  : std_logic_vector(7 downto 0); 
signal pca_w41  : std_logic_vector(7 downto 0); 
signal pca_w42  : std_logic_vector(7 downto 0); 
signal pca_w43  : std_logic_vector(7 downto 0); 
signal pca_w44  : std_logic_vector(7 downto 0); 
signal pca_w45  : std_logic_vector(7 downto 0); 
signal pca_w46  : std_logic_vector(7 downto 0); 
signal pca_w47  : std_logic_vector(7 downto 0); 
signal pca_w48  : std_logic_vector(7 downto 0); 
signal pca_w49  : std_logic_vector(7 downto 0); 
signal pca_w50  : std_logic_vector(7 downto 0); 
signal pca_w51  : std_logic_vector(7 downto 0); 
signal pca_w52  : std_logic_vector(7 downto 0); 
signal pca_w53  : std_logic_vector(7 downto 0); 
signal pca_w54  : std_logic_vector(7 downto 0); 
signal pca_w55  : std_logic_vector(7 downto 0); 
signal pca_w56  : std_logic_vector(7 downto 0); 
signal pca_w57  : std_logic_vector(7 downto 0); 
signal pca_w58  : std_logic_vector(7 downto 0); 
signal pca_w59  : std_logic_vector(7 downto 0); 
signal pca_w60  : std_logic_vector(7 downto 0); 
signal pca_w61  : std_logic_vector(7 downto 0); 
signal pca_w62  : std_logic_vector(7 downto 0); 
signal pca_w63  : std_logic_vector(7 downto 0); 
signal pca_w64  : std_logic_vector(7 downto 0); 

signal pca_w_data     : std_logic_vector(64*8-1 downto 0);
signal pca_w_addr     : std_logic_vector(5 downto 0);
signal pca_col_count  : std_logic_vector(7 downto 0); --max 265 columns

signal pca_d_out   : std_logic_vector(CL_W + M + 5 downto 0);
signal pca_en_out  : std_logic;
signal pca_sof_out : std_logic;

begin

-- weight init

  p_weight1 : process (clk,rst)
  begin
    if rst = '1' then
       w_en        <= '0';
       w_count_en  <= '1';
       w_count_en2 <= '0';
       w_count     <= (others => '0');
    elsif rising_edge(clk) then
       if w_count_en = '1' then
          w_num   <= w_count;
          w_count <= w_count + 1;
       end if;
       if w_count = (2**(w_count'left+1) - 1) then
          w_count_en <= '0';
       end if;
       w_count_en2 <= w_count_en;
       w_en        <= w_count_en2;
    end if;
  end process p_weight1;

  p_weight2 : process (clk)
  begin
    if rising_edge(clk) then
       w01_in <=  weight01(conv_integer("0" & w_count));
       w02_in <=  weight02(conv_integer("0" & w_count));
       w03_in <=  weight03(conv_integer("0" & w_count));
       w04_in <=  weight04(conv_integer("0" & w_count));
       w05_in <=  weight05(conv_integer("0" & w_count));
       w06_in <=  weight06(conv_integer("0" & w_count));
       w07_in <=  weight07(conv_integer("0" & w_count));
       w08_in <=  weight08(conv_integer("0" & w_count));
       w09_in <=  weight09(conv_integer("0" & w_count));
       w10_in <=  weight10(conv_integer("0" & w_count));
       w11_in <=  weight11(conv_integer("0" & w_count));
       w12_in <=  weight12(conv_integer("0" & w_count));
       w13_in <=  weight13(conv_integer("0" & w_count));
       w14_in <=  weight14(conv_integer("0" & w_count));
       w15_in <=  weight15(conv_integer("0" & w_count));
       w16_in <=  weight16(conv_integer("0" & w_count));
       w17_in <=  weight17(conv_integer("0" & w_count));
       w18_in <=  weight18(conv_integer("0" & w_count));
       w19_in <=  weight19(conv_integer("0" & w_count));
       w20_in <=  weight20(conv_integer("0" & w_count));
       w21_in <=  weight21(conv_integer("0" & w_count));
       w22_in <=  weight22(conv_integer("0" & w_count));
       w23_in <=  weight23(conv_integer("0" & w_count));
       w24_in <=  weight24(conv_integer("0" & w_count));
       w25_in <=  weight25(conv_integer("0" & w_count));
       w26_in <=  weight26(conv_integer("0" & w_count));
       w27_in <=  weight27(conv_integer("0" & w_count));
       w28_in <=  weight28(conv_integer("0" & w_count));
       w29_in <=  weight29(conv_integer("0" & w_count));
       w30_in <=  weight30(conv_integer("0" & w_count));
       w31_in <=  weight31(conv_integer("0" & w_count));
       w32_in <=  weight32(conv_integer("0" & w_count));
       w33_in <=  weight33(conv_integer("0" & w_count));
       w34_in <=  weight34(conv_integer("0" & w_count));
       w35_in <=  weight35(conv_integer("0" & w_count));
       w36_in <=  weight36(conv_integer("0" & w_count));
       w37_in <=  weight37(conv_integer("0" & w_count));
       w38_in <=  weight38(conv_integer("0" & w_count));
       w39_in <=  weight39(conv_integer("0" & w_count));
       w40_in <=  weight40(conv_integer("0" & w_count));
       w41_in <=  weight41(conv_integer("0" & w_count));
       w42_in <=  weight42(conv_integer("0" & w_count));
       w43_in <=  weight43(conv_integer("0" & w_count));
       w44_in <=  weight44(conv_integer("0" & w_count));
       w45_in <=  weight45(conv_integer("0" & w_count));
       w46_in <=  weight46(conv_integer("0" & w_count));
       w47_in <=  weight47(conv_integer("0" & w_count));
       w48_in <=  weight48(conv_integer("0" & w_count));
       w49_in <=  weight49(conv_integer("0" & w_count));
       w50_in <=  weight50(conv_integer("0" & w_count));
       w51_in <=  weight51(conv_integer("0" & w_count));
       w52_in <=  weight52(conv_integer("0" & w_count));
       w53_in <=  weight53(conv_integer("0" & w_count));
       w54_in <=  weight54(conv_integer("0" & w_count));
       w55_in <=  weight55(conv_integer("0" & w_count));
       w56_in <=  weight56(conv_integer("0" & w_count));
       w57_in <=  weight57(conv_integer("0" & w_count));
       w58_in <=  weight58(conv_integer("0" & w_count));
       w59_in <=  weight59(conv_integer("0" & w_count));
       w60_in <=  weight60(conv_integer("0" & w_count));
       w61_in <=  weight61(conv_integer("0" & w_count));
       w62_in <=  weight62(conv_integer("0" & w_count));
       w63_in <=  weight63(conv_integer("0" & w_count));
       w64_in <=  weight64(conv_integer("0" & w_count));
    end if;
  end process p_weight2;

CL01: ConvLayer generic map (mult_sum => mult_sum,N => N,M => M,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w01_in, w_num => w_num, w_en => w_en, d_out => d01_out, en_out => cl_en_out, sof_out => cl_sof_out);
CL02: ConvLayer generic map (mult_sum => mult_sum,N => N,M => M,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w02_in, w_num => w_num, w_en => w_en, d_out => d02_out, en_out => open, sof_out => open);
CL03: ConvLayer generic map (mult_sum => mult_sum,N => N,M => M,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w03_in, w_num => w_num, w_en => w_en, d_out => d03_out, en_out => open, sof_out => open);
CL04: ConvLayer generic map (mult_sum => mult_sum,N => N,M => M,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w04_in, w_num => w_num, w_en => w_en, d_out => d04_out, en_out => open, sof_out => open);
CL05: ConvLayer generic map (mult_sum => mult_sum,N => N,M => M,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w05_in, w_num => w_num, w_en => w_en, d_out => d05_out, en_out => open, sof_out => open);
CL06: ConvLayer generic map (mult_sum => mult_sum,N => N,M => M,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w06_in, w_num => w_num, w_en => w_en, d_out => d06_out, en_out => open, sof_out => open);
CL07: ConvLayer generic map (mult_sum => mult_sum,N => N,M => M,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w07_in, w_num => w_num, w_en => w_en, d_out => d07_out, en_out => open, sof_out => open);
CL08: ConvLayer generic map (mult_sum => mult_sum,N => N,M => M,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w08_in, w_num => w_num, w_en => w_en, d_out => d08_out, en_out => open, sof_out => open);
CL09: ConvLayer generic map (mult_sum => mult_sum,N => N,M => M,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w09_in, w_num => w_num, w_en => w_en, d_out => d09_out, en_out => open, sof_out => open);
CL10: ConvLayer generic map (mult_sum => mult_sum,N => N,M => M,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w10_in, w_num => w_num, w_en => w_en, d_out => d10_out, en_out => open, sof_out => open);
CL11: ConvLayer generic map (mult_sum => mult_sum,N => N,M => M,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w11_in, w_num => w_num, w_en => w_en, d_out => d11_out, en_out => open, sof_out => open);
CL12: ConvLayer generic map (mult_sum => mult_sum,N => N,M => M,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w12_in, w_num => w_num, w_en => w_en, d_out => d12_out, en_out => open, sof_out => open);
CL13: ConvLayer generic map (mult_sum => mult_sum,N => N,M => M,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w13_in, w_num => w_num, w_en => w_en, d_out => d13_out, en_out => open, sof_out => open);
CL14: ConvLayer generic map (mult_sum => mult_sum,N => N,M => M,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w14_in, w_num => w_num, w_en => w_en, d_out => d14_out, en_out => open, sof_out => open);
CL15: ConvLayer generic map (mult_sum => mult_sum,N => N,M => M,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w15_in, w_num => w_num, w_en => w_en, d_out => d15_out, en_out => open, sof_out => open);
CL16: ConvLayer generic map (mult_sum => mult_sum,N => N,M => M,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w16_in, w_num => w_num, w_en => w_en, d_out => d16_out, en_out => open, sof_out => open);
CL17: ConvLayer generic map (mult_sum => mult_sum,N => N,M => M,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w17_in, w_num => w_num, w_en => w_en, d_out => d17_out, en_out => open, sof_out => open);
CL18: ConvLayer generic map (mult_sum => mult_sum,N => N,M => M,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w18_in, w_num => w_num, w_en => w_en, d_out => d18_out, en_out => open, sof_out => open);
CL19: ConvLayer generic map (mult_sum => mult_sum,N => N,M => M,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w19_in, w_num => w_num, w_en => w_en, d_out => d19_out, en_out => open, sof_out => open);
CL20: ConvLayer generic map (mult_sum => mult_sum,N => N,M => M,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w20_in, w_num => w_num, w_en => w_en, d_out => d20_out, en_out => open, sof_out => open);
CL21: ConvLayer generic map (mult_sum => mult_sum,N => N,M => M,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w21_in, w_num => w_num, w_en => w_en, d_out => d21_out, en_out => open, sof_out => open);
CL22: ConvLayer generic map (mult_sum => mult_sum,N => N,M => M,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w22_in, w_num => w_num, w_en => w_en, d_out => d22_out, en_out => open, sof_out => open);
CL23: ConvLayer generic map (mult_sum => mult_sum,N => N,M => M,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w23_in, w_num => w_num, w_en => w_en, d_out => d23_out, en_out => open, sof_out => open);
CL24: ConvLayer generic map (mult_sum => mult_sum,N => N,M => M,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w24_in, w_num => w_num, w_en => w_en, d_out => d24_out, en_out => open, sof_out => open);
CL25: ConvLayer generic map (mult_sum => mult_sum,N => N,M => M,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w25_in, w_num => w_num, w_en => w_en, d_out => d25_out, en_out => open, sof_out => open);
CL26: ConvLayer generic map (mult_sum => mult_sum,N => N,M => M,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w26_in, w_num => w_num, w_en => w_en, d_out => d26_out, en_out => open, sof_out => open);
CL27: ConvLayer generic map (mult_sum => mult_sum,N => N,M => M,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w27_in, w_num => w_num, w_en => w_en, d_out => d27_out, en_out => open, sof_out => open);
CL28: ConvLayer generic map (mult_sum => mult_sum,N => N,M => M,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w28_in, w_num => w_num, w_en => w_en, d_out => d28_out, en_out => open, sof_out => open);
CL29: ConvLayer generic map (mult_sum => mult_sum,N => N,M => M,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w29_in, w_num => w_num, w_en => w_en, d_out => d29_out, en_out => open, sof_out => open);
CL30: ConvLayer generic map (mult_sum => mult_sum,N => N,M => M,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w30_in, w_num => w_num, w_en => w_en, d_out => d30_out, en_out => open, sof_out => open);
CL31: ConvLayer generic map (mult_sum => mult_sum,N => N,M => M,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w31_in, w_num => w_num, w_en => w_en, d_out => d31_out, en_out => open, sof_out => open);
CL32: ConvLayer generic map (mult_sum => mult_sum,N => N,M => M,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w32_in, w_num => w_num, w_en => w_en, d_out => d32_out, en_out => open, sof_out => open);
CL33: ConvLayer generic map (mult_sum => mult_sum,N => N,M => M,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w33_in, w_num => w_num, w_en => w_en, d_out => d33_out, en_out => open, sof_out => open);
CL34: ConvLayer generic map (mult_sum => mult_sum,N => N,M => M,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w34_in, w_num => w_num, w_en => w_en, d_out => d34_out, en_out => open, sof_out => open);
CL35: ConvLayer generic map (mult_sum => mult_sum,N => N,M => M,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w35_in, w_num => w_num, w_en => w_en, d_out => d35_out, en_out => open, sof_out => open);
CL36: ConvLayer generic map (mult_sum => mult_sum,N => N,M => M,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w36_in, w_num => w_num, w_en => w_en, d_out => d36_out, en_out => open, sof_out => open);
CL37: ConvLayer generic map (mult_sum => mult_sum,N => N,M => M,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w37_in, w_num => w_num, w_en => w_en, d_out => d37_out, en_out => open, sof_out => open);
CL38: ConvLayer generic map (mult_sum => mult_sum,N => N,M => M,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w38_in, w_num => w_num, w_en => w_en, d_out => d38_out, en_out => open, sof_out => open);
CL39: ConvLayer generic map (mult_sum => mult_sum,N => N,M => M,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w39_in, w_num => w_num, w_en => w_en, d_out => d39_out, en_out => open, sof_out => open);
CL40: ConvLayer generic map (mult_sum => mult_sum,N => N,M => M,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w40_in, w_num => w_num, w_en => w_en, d_out => d40_out, en_out => open, sof_out => open);
CL41: ConvLayer generic map (mult_sum => mult_sum,N => N,M => M,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w41_in, w_num => w_num, w_en => w_en, d_out => d41_out, en_out => open, sof_out => open);
CL42: ConvLayer generic map (mult_sum => mult_sum,N => N,M => M,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w42_in, w_num => w_num, w_en => w_en, d_out => d42_out, en_out => open, sof_out => open);
CL43: ConvLayer generic map (mult_sum => mult_sum,N => N,M => M,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w43_in, w_num => w_num, w_en => w_en, d_out => d43_out, en_out => open, sof_out => open);
CL44: ConvLayer generic map (mult_sum => mult_sum,N => N,M => M,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w44_in, w_num => w_num, w_en => w_en, d_out => d44_out, en_out => open, sof_out => open);
CL45: ConvLayer generic map (mult_sum => mult_sum,N => N,M => M,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w45_in, w_num => w_num, w_en => w_en, d_out => d45_out, en_out => open, sof_out => open);
CL46: ConvLayer generic map (mult_sum => mult_sum,N => N,M => M,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w46_in, w_num => w_num, w_en => w_en, d_out => d46_out, en_out => open, sof_out => open);
CL47: ConvLayer generic map (mult_sum => mult_sum,N => N,M => M,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w47_in, w_num => w_num, w_en => w_en, d_out => d47_out, en_out => open, sof_out => open);
CL48: ConvLayer generic map (mult_sum => mult_sum,N => N,M => M,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w48_in, w_num => w_num, w_en => w_en, d_out => d48_out, en_out => open, sof_out => open);
CL49: ConvLayer generic map (mult_sum => mult_sum,N => N,M => M,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w49_in, w_num => w_num, w_en => w_en, d_out => d49_out, en_out => open, sof_out => open);
CL50: ConvLayer generic map (mult_sum => mult_sum,N => N,M => M,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w50_in, w_num => w_num, w_en => w_en, d_out => d50_out, en_out => open, sof_out => open);
CL51: ConvLayer generic map (mult_sum => mult_sum,N => N,M => M,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w51_in, w_num => w_num, w_en => w_en, d_out => d51_out, en_out => open, sof_out => open);
CL52: ConvLayer generic map (mult_sum => mult_sum,N => N,M => M,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w52_in, w_num => w_num, w_en => w_en, d_out => d52_out, en_out => open, sof_out => open);
CL53: ConvLayer generic map (mult_sum => mult_sum,N => N,M => M,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w53_in, w_num => w_num, w_en => w_en, d_out => d53_out, en_out => open, sof_out => open);
CL54: ConvLayer generic map (mult_sum => mult_sum,N => N,M => M,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w54_in, w_num => w_num, w_en => w_en, d_out => d54_out, en_out => open, sof_out => open);
CL55: ConvLayer generic map (mult_sum => mult_sum,N => N,M => M,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w55_in, w_num => w_num, w_en => w_en, d_out => d55_out, en_out => open, sof_out => open);
CL56: ConvLayer generic map (mult_sum => mult_sum,N => N,M => M,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w56_in, w_num => w_num, w_en => w_en, d_out => d56_out, en_out => open, sof_out => open);
CL57: ConvLayer generic map (mult_sum => mult_sum,N => N,M => M,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w57_in, w_num => w_num, w_en => w_en, d_out => d57_out, en_out => open, sof_out => open);
CL58: ConvLayer generic map (mult_sum => mult_sum,N => N,M => M,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w58_in, w_num => w_num, w_en => w_en, d_out => d58_out, en_out => open, sof_out => open);
CL59: ConvLayer generic map (mult_sum => mult_sum,N => N,M => M,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w59_in, w_num => w_num, w_en => w_en, d_out => d59_out, en_out => open, sof_out => open);
CL60: ConvLayer generic map (mult_sum => mult_sum,N => N,M => M,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w60_in, w_num => w_num, w_en => w_en, d_out => d60_out, en_out => open, sof_out => open);
CL61: ConvLayer generic map (mult_sum => mult_sum,N => N,M => M,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w61_in, w_num => w_num, w_en => w_en, d_out => d61_out, en_out => open, sof_out => open);
CL62: ConvLayer generic map (mult_sum => mult_sum,N => N,M => M,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w62_in, w_num => w_num, w_en => w_en, d_out => d62_out, en_out => open, sof_out => open);
CL63: ConvLayer generic map (mult_sum => mult_sum,N => N,M => M,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w63_in, w_num => w_num, w_en => w_en, d_out => d63_out, en_out => open, sof_out => open);
CL64: ConvLayer generic map (mult_sum => mult_sum,N => N,M => M,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w64_in, w_num => w_num, w_en => w_en, d_out => d64_out, en_out => open, sof_out => open);



PCA64_inst: PCA_64 
  generic map(
           mult_sum => mult_sum,
           N        => CL_W,
           M        => M,
           in_row   => in_row,
           in_col   => in_col
           )
  port map (
           clk       => clk    ,
           rst       => rst    ,
           d01_in    => d01_out, 
           d02_in    => d02_out, 
           d03_in    => d03_out, 
           d04_in    => d04_out, 
           d05_in    => d05_out, 
           d06_in    => d06_out, 
           d07_in    => d07_out, 
           d08_in    => d08_out, 
           d09_in    => d09_out, 
           d10_in    => d10_out, 
           d11_in    => d11_out, 
           d12_in    => d12_out, 
           d13_in    => d13_out, 
           d14_in    => d14_out, 
           d15_in    => d15_out, 
           d16_in    => d16_out, 
           d17_in    => d17_out, 
           d18_in    => d18_out, 
           d19_in    => d19_out, 
           d20_in    => d20_out, 
           d21_in    => d21_out, 
           d22_in    => d22_out, 
           d23_in    => d23_out, 
           d24_in    => d24_out, 
           d25_in    => d25_out, 
           d26_in    => d26_out, 
           d27_in    => d27_out, 
           d28_in    => d28_out, 
           d29_in    => d29_out, 
           d30_in    => d30_out, 
           d31_in    => d31_out, 
           d32_in    => d32_out, 
           d33_in    => d33_out, 
           d34_in    => d34_out, 
           d35_in    => d35_out, 
           d36_in    => d36_out, 
           d37_in    => d37_out, 
           d38_in    => d38_out, 
           d39_in    => d39_out, 
           d40_in    => d40_out, 
           d41_in    => d41_out, 
           d42_in    => d42_out, 
           d43_in    => d43_out, 
           d44_in    => d44_out, 
           d45_in    => d45_out, 
           d46_in    => d46_out, 
           d47_in    => d47_out, 
           d48_in    => d48_out, 
           d49_in    => d49_out, 
           d50_in    => d50_out, 
           d51_in    => d51_out, 
           d52_in    => d52_out, 
           d53_in    => d53_out, 
           d54_in    => d54_out, 
           d55_in    => d55_out, 
           d56_in    => d56_out, 
           d57_in    => d57_out, 
           d58_in    => d58_out, 
           d59_in    => d59_out, 
           d60_in    => d60_out, 
           d61_in    => d61_out, 
           d62_in    => d62_out, 
           d63_in    => d63_out, 
           d64_in    => d64_out, 
           en_in     => cl_en_out,
           sof_in    => cl_sof_out,

           w01      => pca_w01, 
           w02      => pca_w02, 
           w03      => pca_w03, 
           w04      => pca_w04, 
           w05      => pca_w05, 
           w06      => pca_w06, 
           w07      => pca_w07, 
           w08      => pca_w08, 
           w09      => pca_w09, 
           w10      => pca_w10, 
           w11      => pca_w11, 
           w12      => pca_w12, 
           w13      => pca_w13, 
           w14      => pca_w14, 
           w15      => pca_w15, 
           w16      => pca_w16, 
           w17      => pca_w17, 
           w18      => pca_w18, 
           w19      => pca_w19, 
           w20      => pca_w20, 
           w21      => pca_w21, 
           w22      => pca_w22, 
           w23      => pca_w23, 
           w24      => pca_w24, 
           w25      => pca_w25, 
           w26      => pca_w26, 
           w27      => pca_w27, 
           w28      => pca_w28, 
           w29      => pca_w29, 
           w30      => pca_w30, 
           w31      => pca_w31, 
           w32      => pca_w32, 
           w33      => pca_w33, 
           w34      => pca_w34, 
           w35      => pca_w35, 
           w36      => pca_w36, 
           w37      => pca_w37, 
           w38      => pca_w38, 
           w39      => pca_w39, 
           w40      => pca_w40, 
           w41      => pca_w41, 
           w42      => pca_w42, 
           w43      => pca_w43, 
           w44      => pca_w44, 
           w45      => pca_w45, 
           w46      => pca_w46, 
           w47      => pca_w47, 
           w48      => pca_w48, 
           w49      => pca_w49, 
           w50      => pca_w50, 
           w51      => pca_w51, 
           w52      => pca_w52, 
           w53      => pca_w53, 
           w54      => pca_w54, 
           w55      => pca_w55, 
           w56      => pca_w56, 
           w57      => pca_w57, 
           w58      => pca_w58, 
           w59      => pca_w59, 
           w60      => pca_w60, 
           w61      => pca_w61, 
           w62      => pca_w62, 
           w63      => pca_w63, 
           w64      => pca_w64, 

           d_out   => pca_d_out   ,
           en_out  => pca_en_out  ,
           sof_out => pca_sof_out );

--temp connection
d_out   <= pca_d_out   ;
en_out  <= pca_en_out  ;
sof_out <= pca_sof_out ;

-- PCA weights

    
--  p_pca_w : process (clk,rst)
--  begin
--    if rst = '1' then
--       pca_w_addr      <= (others => '0');
--       pca_col_count   <= (others => '0');
--       --pca_w_init      <= '1';
--    elsif rising_edge(clk) then
--       --pca_w_init      <= '0';
--       --if pca_w_init = '1' or ( cl_en_out = '1' and pca_w_addr = std_logic_vector(to_unsigned(in_col, pca_w_addr'length))) then
--       if cl_en_out = '1' and pca_col_count = std_logic_vector(to_unsigned(in_col-1, pca_w_addr'length)) then
--          pca_w_addr <= pca_w_addr + 1;
--       end if;
--
--       if cl_en_out = '1'  then
--          if pca_col_count = std_logic_vector(to_unsigned(in_col-1, pca_w_addr'length)) then
--             pca_col_count   <= (others => '0');
--          else
--             pca_col_count <= pca_col_count + 1;
--          end if;
--       end if;
--    end if;
--  end process p_pca_w;

--  p_pca_w2 : process (clk)
--  begin
--    if rising_edge(clk) then
--      pca_w_data <= PCAweight64(conv_integer("0" & pca_w_addr));
--    end if;
--  end process p_pca_w2;
--pca_w01 <= pca_w_data(   8-1 downto    0); 
--pca_w02 <= pca_w_data( 2*8-1 downto    8); 
--pca_w03 <= pca_w_data( 3*8-1 downto  2*8); 
--pca_w04 <= pca_w_data( 4*8-1 downto  3*8); 
--pca_w05 <= pca_w_data( 5*8-1 downto  4*8); 
--pca_w06 <= pca_w_data( 6*8-1 downto  5*8); 
--pca_w07 <= pca_w_data( 7*8-1 downto  6*8); 
--pca_w08 <= pca_w_data( 8*8-1 downto  7*8); 
--pca_w09 <= pca_w_data( 9*8-1 downto  8*8); 
--pca_w10 <= pca_w_data(10*8-1 downto  9*8); 
--pca_w11 <= pca_w_data(11*8-1 downto 10*8); 
--pca_w12 <= pca_w_data(12*8-1 downto 11*8); 
--pca_w13 <= pca_w_data(13*8-1 downto 12*8); 
--pca_w14 <= pca_w_data(14*8-1 downto 13*8); 
--pca_w15 <= pca_w_data(15*8-1 downto 14*8); 
--pca_w16 <= pca_w_data(16*8-1 downto 15*8); 
--pca_w17 <= pca_w_data(17*8-1 downto 16*8); 
--pca_w18 <= pca_w_data(18*8-1 downto 17*8); 
--pca_w19 <= pca_w_data(19*8-1 downto 18*8); 
--pca_w20 <= pca_w_data(20*8-1 downto 19*8); 
--pca_w21 <= pca_w_data(21*8-1 downto 20*8); 
--pca_w22 <= pca_w_data(22*8-1 downto 21*8); 
--pca_w23 <= pca_w_data(23*8-1 downto 22*8); 
--pca_w24 <= pca_w_data(24*8-1 downto 23*8); 
--pca_w25 <= pca_w_data(25*8-1 downto 24*8); 
--pca_w26 <= pca_w_data(26*8-1 downto 25*8); 
--pca_w27 <= pca_w_data(27*8-1 downto 26*8); 
--pca_w28 <= pca_w_data(28*8-1 downto 27*8); 
--pca_w29 <= pca_w_data(29*8-1 downto 28*8); 
--pca_w30 <= pca_w_data(30*8-1 downto 29*8); 
--pca_w31 <= pca_w_data(31*8-1 downto 30*8); 
--pca_w32 <= pca_w_data(32*8-1 downto 31*8); 
--pca_w33 <= pca_w_data(33*8-1 downto 32*8); 
--pca_w34 <= pca_w_data(34*8-1 downto 33*8); 
--pca_w35 <= pca_w_data(35*8-1 downto 34*8); 
--pca_w36 <= pca_w_data(36*8-1 downto 35*8); 
--pca_w37 <= pca_w_data(37*8-1 downto 36*8); 
--pca_w38 <= pca_w_data(38*8-1 downto 37*8); 
--pca_w39 <= pca_w_data(39*8-1 downto 38*8); 
--pca_w40 <= pca_w_data(40*8-1 downto 39*8); 
--pca_w41 <= pca_w_data(41*8-1 downto 40*8); 
--pca_w42 <= pca_w_data(42*8-1 downto 41*8); 
--pca_w43 <= pca_w_data(43*8-1 downto 42*8); 
--pca_w44 <= pca_w_data(44*8-1 downto 43*8); 
--pca_w45 <= pca_w_data(45*8-1 downto 44*8); 
--pca_w46 <= pca_w_data(46*8-1 downto 45*8); 
--pca_w47 <= pca_w_data(47*8-1 downto 46*8); 
--pca_w48 <= pca_w_data(48*8-1 downto 47*8); 
--pca_w49 <= pca_w_data(49*8-1 downto 48*8); 
--pca_w50 <= pca_w_data(50*8-1 downto 49*8); 
--pca_w51 <= pca_w_data(51*8-1 downto 50*8); 
--pca_w52 <= pca_w_data(52*8-1 downto 51*8); 
--pca_w53 <= pca_w_data(53*8-1 downto 52*8); 
--pca_w54 <= pca_w_data(54*8-1 downto 53*8); 
--pca_w55 <= pca_w_data(55*8-1 downto 54*8); 
--pca_w56 <= pca_w_data(56*8-1 downto 55*8); 
--pca_w57 <= pca_w_data(57*8-1 downto 56*8); 
--pca_w58 <= pca_w_data(58*8-1 downto 57*8); 
--pca_w59 <= pca_w_data(59*8-1 downto 58*8); 
--pca_w60 <= pca_w_data(60*8-1 downto 59*8); 
--pca_w61 <= pca_w_data(61*8-1 downto 60*8); 
--pca_w62 <= pca_w_data(62*8-1 downto 61*8); 
--pca_w63 <= pca_w_data(63*8-1 downto 62*8); 
--pca_w64 <= pca_w_data(64*8-1 downto 63*8); 

end a;