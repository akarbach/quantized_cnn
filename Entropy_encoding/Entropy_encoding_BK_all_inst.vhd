library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;
use ieee.numeric_std.all;    
--USE ieee.std_logic_arith.all;

entity Entropy_encoding is
  generic (
  	       mult_sum      : string := "sum";
           N             : integer :=   8; -- input data width
           Huff_wid      : integer :=  12; -- Huffman weight maximum width                   (after change need nedd to update "Huff_code" matrix)
           Wh            : integer :=  16; -- Huffman unit output data width (Note W>=M)
           Wb            : integer := 128; -- output buffer data width
           depth         : integer :=  64; -- buffer depth
           burst         : integer :=  10; -- buffer read burst
 
           PCA_en        : boolean := FALSE; --TRUE; -- PCA Enable/Bypass
           Huff_enc_en   : boolean := TRUE; -- Huffman encoder Enable/Bypass

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

           buf_rd        : in  std_logic;
           buf_num       : in  std_logic_vector (5      downto 0);
           d_out         : out std_logic_vector (Wb  -1 downto 0);
           en_out        : out std_logic_vector (64  -1 downto 0);
           sof_out : out std_logic);
end Entropy_encoding;

architecture a of Entropy_encoding is

constant PCAweightW   : integer := 8;

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

component Huffman64 is
  generic (
           N             : integer :=  4;  -- input data width
           M             : integer :=  8;  -- max code width
           Wh            : integer := 16;  -- Huffman unit output data width (Note W>=M)
           Wb            : integer := 512; -- output buffer data width
           Huff_enc_en   : boolean := TRUE; -- Huffman encoder Enable/Bypass
           depth         : integer := 500; -- buffer depth
           burst         : integer := 10   -- buffer read burst
           );
  port    (
           clk           : in  std_logic;
           rst           : in  std_logic; 

           init_en       : in  std_logic;                         -- initialising convert table
           alpha_data    : in  std_logic_vector(N-1 downto 0);    
           alpha_code    : in  std_logic_vector(M-1 downto 0);    
           alpha_width   : in  std_logic_vector(  3 downto 0);

           d01_in          : in  std_logic_vector (N-1 downto 0);   -- data to convert
           d02_in          : in  std_logic_vector (N-1 downto 0);   -- data to convert
           d03_in          : in  std_logic_vector (N-1 downto 0);   -- data to convert
           d04_in          : in  std_logic_vector (N-1 downto 0);   -- data to convert
           d05_in          : in  std_logic_vector (N-1 downto 0);   -- data to convert
           d06_in          : in  std_logic_vector (N-1 downto 0);   -- data to convert
           d07_in          : in  std_logic_vector (N-1 downto 0);   -- data to convert
           d08_in          : in  std_logic_vector (N-1 downto 0);   -- data to convert
           d09_in          : in  std_logic_vector (N-1 downto 0);   -- data to convert
           d10_in          : in  std_logic_vector (N-1 downto 0);   -- data to convert
           d11_in          : in  std_logic_vector (N-1 downto 0);   -- data to convert
           d12_in          : in  std_logic_vector (N-1 downto 0);   -- data to convert
           d13_in          : in  std_logic_vector (N-1 downto 0);   -- data to convert
           d14_in          : in  std_logic_vector (N-1 downto 0);   -- data to convert
           d15_in          : in  std_logic_vector (N-1 downto 0);   -- data to convert
           d16_in          : in  std_logic_vector (N-1 downto 0);   -- data to convert
           d17_in          : in  std_logic_vector (N-1 downto 0);   -- data to convert
           d18_in          : in  std_logic_vector (N-1 downto 0);   -- data to convert
           d19_in          : in  std_logic_vector (N-1 downto 0);   -- data to convert
           d20_in          : in  std_logic_vector (N-1 downto 0);   -- data to convert
           d21_in          : in  std_logic_vector (N-1 downto 0);   -- data to convert
           d22_in          : in  std_logic_vector (N-1 downto 0);   -- data to convert
           d23_in          : in  std_logic_vector (N-1 downto 0);   -- data to convert
           d24_in          : in  std_logic_vector (N-1 downto 0);   -- data to convert
           d25_in          : in  std_logic_vector (N-1 downto 0);   -- data to convert
           d26_in          : in  std_logic_vector (N-1 downto 0);   -- data to convert
           d27_in          : in  std_logic_vector (N-1 downto 0);   -- data to convert
           d28_in          : in  std_logic_vector (N-1 downto 0);   -- data to convert
           d29_in          : in  std_logic_vector (N-1 downto 0);   -- data to convert
           d30_in          : in  std_logic_vector (N-1 downto 0);   -- data to convert
           d31_in          : in  std_logic_vector (N-1 downto 0);   -- data to convert
           d32_in          : in  std_logic_vector (N-1 downto 0);   -- data to convert
           d33_in          : in  std_logic_vector (N-1 downto 0);   -- data to convert
           d34_in          : in  std_logic_vector (N-1 downto 0);   -- data to convert
           d35_in          : in  std_logic_vector (N-1 downto 0);   -- data to convert
           d36_in          : in  std_logic_vector (N-1 downto 0);   -- data to convert
           d37_in          : in  std_logic_vector (N-1 downto 0);   -- data to convert
           d38_in          : in  std_logic_vector (N-1 downto 0);   -- data to convert
           d39_in          : in  std_logic_vector (N-1 downto 0);   -- data to convert
           d40_in          : in  std_logic_vector (N-1 downto 0);   -- data to convert
           d41_in          : in  std_logic_vector (N-1 downto 0);   -- data to convert
           d42_in          : in  std_logic_vector (N-1 downto 0);   -- data to convert
           d43_in          : in  std_logic_vector (N-1 downto 0);   -- data to convert
           d44_in          : in  std_logic_vector (N-1 downto 0);   -- data to convert
           d45_in          : in  std_logic_vector (N-1 downto 0);   -- data to convert
           d46_in          : in  std_logic_vector (N-1 downto 0);   -- data to convert
           d47_in          : in  std_logic_vector (N-1 downto 0);   -- data to convert
           d48_in          : in  std_logic_vector (N-1 downto 0);   -- data to convert
           d49_in          : in  std_logic_vector (N-1 downto 0);   -- data to convert
           d50_in          : in  std_logic_vector (N-1 downto 0);   -- data to convert
           d51_in          : in  std_logic_vector (N-1 downto 0);   -- data to convert
           d52_in          : in  std_logic_vector (N-1 downto 0);   -- data to convert
           d53_in          : in  std_logic_vector (N-1 downto 0);   -- data to convert
           d54_in          : in  std_logic_vector (N-1 downto 0);   -- data to convert
           d55_in          : in  std_logic_vector (N-1 downto 0);   -- data to convert
           d56_in          : in  std_logic_vector (N-1 downto 0);   -- data to convert
           d57_in          : in  std_logic_vector (N-1 downto 0);   -- data to convert
           d58_in          : in  std_logic_vector (N-1 downto 0);   -- data to convert
           d59_in          : in  std_logic_vector (N-1 downto 0);   -- data to convert
           d60_in          : in  std_logic_vector (N-1 downto 0);   -- data to convert
           d61_in          : in  std_logic_vector (N-1 downto 0);   -- data to convert
           d62_in          : in  std_logic_vector (N-1 downto 0);   -- data to convert
           d63_in          : in  std_logic_vector (N-1 downto 0);   -- data to convert
           d64_in          : in  std_logic_vector (N-1 downto 0);   -- data to convert
           en_in         : in  std_logic;
           sof_in        : in  std_logic;                         -- start of frame
           eof_in        : in  std_logic;                         -- end of frame

           buf_rd        : in  std_logic;
           buf_num       : in  std_logic_vector (5      downto 0);
           d_out         : out std_logic_vector (Wb  -1 downto 0);
           en_out        : out std_logic_vector (64  -1 downto 0);
           eof_out       : out std_logic);                        -- huffman codde output
end component;

constant CL_w_width : integer := 8;
type rom_type is array ( 0 to 15 ) of std_logic_vector(CL_w_width-1 downto 0 ) ;

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

signal  w01_in    : std_logic_vector(CL_w_width-1 downto 0);
signal  w02_in    : std_logic_vector(CL_w_width-1 downto 0);
signal  w03_in    : std_logic_vector(CL_w_width-1 downto 0);
signal  w04_in    : std_logic_vector(CL_w_width-1 downto 0);
signal  w05_in    : std_logic_vector(CL_w_width-1 downto 0);
signal  w06_in    : std_logic_vector(CL_w_width-1 downto 0);
signal  w07_in    : std_logic_vector(CL_w_width-1 downto 0);
signal  w08_in    : std_logic_vector(CL_w_width-1 downto 0);
signal  w09_in    : std_logic_vector(CL_w_width-1 downto 0);
signal  w10_in    : std_logic_vector(CL_w_width-1 downto 0);
signal  w11_in    : std_logic_vector(CL_w_width-1 downto 0);
signal  w12_in    : std_logic_vector(CL_w_width-1 downto 0);
signal  w13_in    : std_logic_vector(CL_w_width-1 downto 0);
signal  w14_in    : std_logic_vector(CL_w_width-1 downto 0);
signal  w15_in    : std_logic_vector(CL_w_width-1 downto 0);
signal  w16_in    : std_logic_vector(CL_w_width-1 downto 0);
signal  w17_in    : std_logic_vector(CL_w_width-1 downto 0);
signal  w18_in    : std_logic_vector(CL_w_width-1 downto 0);
signal  w19_in    : std_logic_vector(CL_w_width-1 downto 0);
signal  w20_in    : std_logic_vector(CL_w_width-1 downto 0);
signal  w21_in    : std_logic_vector(CL_w_width-1 downto 0);
signal  w22_in    : std_logic_vector(CL_w_width-1 downto 0);
signal  w23_in    : std_logic_vector(CL_w_width-1 downto 0);
signal  w24_in    : std_logic_vector(CL_w_width-1 downto 0);
signal  w25_in    : std_logic_vector(CL_w_width-1 downto 0);
signal  w26_in    : std_logic_vector(CL_w_width-1 downto 0);
signal  w27_in    : std_logic_vector(CL_w_width-1 downto 0);
signal  w28_in    : std_logic_vector(CL_w_width-1 downto 0);
signal  w29_in    : std_logic_vector(CL_w_width-1 downto 0);
signal  w30_in    : std_logic_vector(CL_w_width-1 downto 0);
signal  w31_in    : std_logic_vector(CL_w_width-1 downto 0);
signal  w32_in    : std_logic_vector(CL_w_width-1 downto 0);
signal  w33_in    : std_logic_vector(CL_w_width-1 downto 0);
signal  w34_in    : std_logic_vector(CL_w_width-1 downto 0);
signal  w35_in    : std_logic_vector(CL_w_width-1 downto 0);
signal  w36_in    : std_logic_vector(CL_w_width-1 downto 0);
signal  w37_in    : std_logic_vector(CL_w_width-1 downto 0);
signal  w38_in    : std_logic_vector(CL_w_width-1 downto 0);
signal  w39_in    : std_logic_vector(CL_w_width-1 downto 0);
signal  w40_in    : std_logic_vector(CL_w_width-1 downto 0);
signal  w41_in    : std_logic_vector(CL_w_width-1 downto 0);
signal  w42_in    : std_logic_vector(CL_w_width-1 downto 0);
signal  w43_in    : std_logic_vector(CL_w_width-1 downto 0);
signal  w44_in    : std_logic_vector(CL_w_width-1 downto 0);
signal  w45_in    : std_logic_vector(CL_w_width-1 downto 0);
signal  w46_in    : std_logic_vector(CL_w_width-1 downto 0);
signal  w47_in    : std_logic_vector(CL_w_width-1 downto 0);
signal  w48_in    : std_logic_vector(CL_w_width-1 downto 0);
signal  w49_in    : std_logic_vector(CL_w_width-1 downto 0);
signal  w50_in    : std_logic_vector(CL_w_width-1 downto 0);
signal  w51_in    : std_logic_vector(CL_w_width-1 downto 0);
signal  w52_in    : std_logic_vector(CL_w_width-1 downto 0);
signal  w53_in    : std_logic_vector(CL_w_width-1 downto 0);
signal  w54_in    : std_logic_vector(CL_w_width-1 downto 0);
signal  w55_in    : std_logic_vector(CL_w_width-1 downto 0);
signal  w56_in    : std_logic_vector(CL_w_width-1 downto 0);
signal  w57_in    : std_logic_vector(CL_w_width-1 downto 0);
signal  w58_in    : std_logic_vector(CL_w_width-1 downto 0);
signal  w59_in    : std_logic_vector(CL_w_width-1 downto 0);
signal  w60_in    : std_logic_vector(CL_w_width-1 downto 0);
signal  w61_in    : std_logic_vector(CL_w_width-1 downto 0);
signal  w62_in    : std_logic_vector(CL_w_width-1 downto 0);
signal  w63_in    : std_logic_vector(CL_w_width-1 downto 0);
signal  w64_in    : std_logic_vector(CL_w_width-1 downto 0);


signal  w_num       : std_logic_vector(  3 downto 0);
signal  w_en        : std_logic;
signal  w_count     : std_logic_vector(  3 downto 0);
signal  w_count_en  : std_logic;
signal  w_count_en2 : std_logic;

-- conv layer
constant CL_W       : integer := N+CL_w_width+4; -- output data width
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
--signal pca_w01  : std_logic_vector(7 downto 0); 
--signal pca_w02  : std_logic_vector(7 downto 0); 
--signal pca_w03  : std_logic_vector(7 downto 0); 
--signal pca_w04  : std_logic_vector(7 downto 0); 
--signal pca_w05  : std_logic_vector(7 downto 0); 
--signal pca_w06  : std_logic_vector(7 downto 0); 
--signal pca_w07  : std_logic_vector(7 downto 0); 
--signal pca_w08  : std_logic_vector(7 downto 0); 
--signal pca_w09  : std_logic_vector(7 downto 0); 
--signal pca_w10  : std_logic_vector(7 downto 0); 
--signal pca_w11  : std_logic_vector(7 downto 0); 
--signal pca_w12  : std_logic_vector(7 downto 0); 
--signal pca_w13  : std_logic_vector(7 downto 0); 
--signal pca_w14  : std_logic_vector(7 downto 0); 
--signal pca_w15  : std_logic_vector(7 downto 0); 
--signal pca_w16  : std_logic_vector(7 downto 0); 
--signal pca_w17  : std_logic_vector(7 downto 0); 
--signal pca_w18  : std_logic_vector(7 downto 0); 
--signal pca_w19  : std_logic_vector(7 downto 0); 
--signal pca_w20  : std_logic_vector(7 downto 0); 
--signal pca_w21  : std_logic_vector(7 downto 0); 
--signal pca_w22  : std_logic_vector(7 downto 0); 
--signal pca_w23  : std_logic_vector(7 downto 0); 
--signal pca_w24  : std_logic_vector(7 downto 0); 
--signal pca_w25  : std_logic_vector(7 downto 0); 
--signal pca_w26  : std_logic_vector(7 downto 0); 
--signal pca_w27  : std_logic_vector(7 downto 0); 
--signal pca_w28  : std_logic_vector(7 downto 0); 
--signal pca_w29  : std_logic_vector(7 downto 0); 
--signal pca_w30  : std_logic_vector(7 downto 0); 
--signal pca_w31  : std_logic_vector(7 downto 0); 
--signal pca_w32  : std_logic_vector(7 downto 0); 
--signal pca_w33  : std_logic_vector(7 downto 0); 
--signal pca_w34  : std_logic_vector(7 downto 0); 
--signal pca_w35  : std_logic_vector(7 downto 0); 
--signal pca_w36  : std_logic_vector(7 downto 0); 
--signal pca_w37  : std_logic_vector(7 downto 0); 
--signal pca_w38  : std_logic_vector(7 downto 0); 
--signal pca_w39  : std_logic_vector(7 downto 0); 
--signal pca_w40  : std_logic_vector(7 downto 0); 
--signal pca_w41  : std_logic_vector(7 downto 0); 
--signal pca_w42  : std_logic_vector(7 downto 0); 
--signal pca_w43  : std_logic_vector(7 downto 0); 
--signal pca_w44  : std_logic_vector(7 downto 0); 
--signal pca_w45  : std_logic_vector(7 downto 0); 
--signal pca_w46  : std_logic_vector(7 downto 0); 
--signal pca_w47  : std_logic_vector(7 downto 0); 
--signal pca_w48  : std_logic_vector(7 downto 0); 
--signal pca_w49  : std_logic_vector(7 downto 0); 
--signal pca_w50  : std_logic_vector(7 downto 0); 
--signal pca_w51  : std_logic_vector(7 downto 0); 
--signal pca_w52  : std_logic_vector(7 downto 0); 
--signal pca_w53  : std_logic_vector(7 downto 0); 
--signal pca_w54  : std_logic_vector(7 downto 0); 
--signal pca_w55  : std_logic_vector(7 downto 0); 
--signal pca_w56  : std_logic_vector(7 downto 0); 
--signal pca_w57  : std_logic_vector(7 downto 0); 
--signal pca_w58  : std_logic_vector(7 downto 0); 
--signal pca_w59  : std_logic_vector(7 downto 0); 
--signal pca_w60  : std_logic_vector(7 downto 0); 
--signal pca_w61  : std_logic_vector(7 downto 0); 
--signal pca_w62  : std_logic_vector(7 downto 0); 
--signal pca_w63  : std_logic_vector(7 downto 0); 
--signal pca_w64  : std_logic_vector(7 downto 0); 

signal pca_w_data     : std_logic_vector(64*8-1 downto 0);
signal pca_w_addr     : std_logic_vector(5 downto 0);
signal pca_col_count  : std_logic_vector(7 downto 0); --max 265 columns

signal pca_d01_out   : std_logic_vector(CL_W + PCAweightW + 5 downto 0);
signal pca_d02_out   : std_logic_vector(CL_W + PCAweightW + 5 downto 0);
signal pca_d03_out   : std_logic_vector(CL_W + PCAweightW + 5 downto 0);
signal pca_d04_out   : std_logic_vector(CL_W + PCAweightW + 5 downto 0);
signal pca_d05_out   : std_logic_vector(CL_W + PCAweightW + 5 downto 0);
signal pca_d06_out   : std_logic_vector(CL_W + PCAweightW + 5 downto 0);
signal pca_d07_out   : std_logic_vector(CL_W + PCAweightW + 5 downto 0);
signal pca_d08_out   : std_logic_vector(CL_W + PCAweightW + 5 downto 0);
signal pca_d09_out   : std_logic_vector(CL_W + PCAweightW + 5 downto 0);
signal pca_d10_out   : std_logic_vector(CL_W + PCAweightW + 5 downto 0);
signal pca_d11_out   : std_logic_vector(CL_W + PCAweightW + 5 downto 0);
signal pca_d12_out   : std_logic_vector(CL_W + PCAweightW + 5 downto 0);
signal pca_d13_out   : std_logic_vector(CL_W + PCAweightW + 5 downto 0);
signal pca_d14_out   : std_logic_vector(CL_W + PCAweightW + 5 downto 0);
signal pca_d15_out   : std_logic_vector(CL_W + PCAweightW + 5 downto 0);
signal pca_d16_out   : std_logic_vector(CL_W + PCAweightW + 5 downto 0);
signal pca_d17_out   : std_logic_vector(CL_W + PCAweightW + 5 downto 0);
signal pca_d18_out   : std_logic_vector(CL_W + PCAweightW + 5 downto 0);
signal pca_d19_out   : std_logic_vector(CL_W + PCAweightW + 5 downto 0);
signal pca_d20_out   : std_logic_vector(CL_W + PCAweightW + 5 downto 0);
signal pca_d21_out   : std_logic_vector(CL_W + PCAweightW + 5 downto 0);
signal pca_d22_out   : std_logic_vector(CL_W + PCAweightW + 5 downto 0);
signal pca_d23_out   : std_logic_vector(CL_W + PCAweightW + 5 downto 0);
signal pca_d24_out   : std_logic_vector(CL_W + PCAweightW + 5 downto 0);
signal pca_d25_out   : std_logic_vector(CL_W + PCAweightW + 5 downto 0);
signal pca_d26_out   : std_logic_vector(CL_W + PCAweightW + 5 downto 0);
signal pca_d27_out   : std_logic_vector(CL_W + PCAweightW + 5 downto 0);
signal pca_d28_out   : std_logic_vector(CL_W + PCAweightW + 5 downto 0);
signal pca_d29_out   : std_logic_vector(CL_W + PCAweightW + 5 downto 0);
signal pca_d30_out   : std_logic_vector(CL_W + PCAweightW + 5 downto 0);
signal pca_d31_out   : std_logic_vector(CL_W + PCAweightW + 5 downto 0);
signal pca_d32_out   : std_logic_vector(CL_W + PCAweightW + 5 downto 0);
signal pca_d33_out   : std_logic_vector(CL_W + PCAweightW + 5 downto 0);
signal pca_d34_out   : std_logic_vector(CL_W + PCAweightW + 5 downto 0);
signal pca_d35_out   : std_logic_vector(CL_W + PCAweightW + 5 downto 0);
signal pca_d36_out   : std_logic_vector(CL_W + PCAweightW + 5 downto 0);
signal pca_d37_out   : std_logic_vector(CL_W + PCAweightW + 5 downto 0);
signal pca_d38_out   : std_logic_vector(CL_W + PCAweightW + 5 downto 0);
signal pca_d39_out   : std_logic_vector(CL_W + PCAweightW + 5 downto 0);
signal pca_d40_out   : std_logic_vector(CL_W + PCAweightW + 5 downto 0);
signal pca_d41_out   : std_logic_vector(CL_W + PCAweightW + 5 downto 0);
signal pca_d42_out   : std_logic_vector(CL_W + PCAweightW + 5 downto 0);
signal pca_d43_out   : std_logic_vector(CL_W + PCAweightW + 5 downto 0);
signal pca_d44_out   : std_logic_vector(CL_W + PCAweightW + 5 downto 0);
signal pca_d45_out   : std_logic_vector(CL_W + PCAweightW + 5 downto 0);
signal pca_d46_out   : std_logic_vector(CL_W + PCAweightW + 5 downto 0);
signal pca_d47_out   : std_logic_vector(CL_W + PCAweightW + 5 downto 0);
signal pca_d48_out   : std_logic_vector(CL_W + PCAweightW + 5 downto 0);
signal pca_d49_out   : std_logic_vector(CL_W + PCAweightW + 5 downto 0);
signal pca_d50_out   : std_logic_vector(CL_W + PCAweightW + 5 downto 0);
signal pca_d51_out   : std_logic_vector(CL_W + PCAweightW + 5 downto 0);
signal pca_d52_out   : std_logic_vector(CL_W + PCAweightW + 5 downto 0);
signal pca_d53_out   : std_logic_vector(CL_W + PCAweightW + 5 downto 0);
signal pca_d54_out   : std_logic_vector(CL_W + PCAweightW + 5 downto 0);
signal pca_d55_out   : std_logic_vector(CL_W + PCAweightW + 5 downto 0);
signal pca_d56_out   : std_logic_vector(CL_W + PCAweightW + 5 downto 0);
signal pca_d57_out   : std_logic_vector(CL_W + PCAweightW + 5 downto 0);
signal pca_d58_out   : std_logic_vector(CL_W + PCAweightW + 5 downto 0);
signal pca_d59_out   : std_logic_vector(CL_W + PCAweightW + 5 downto 0);
signal pca_d60_out   : std_logic_vector(CL_W + PCAweightW + 5 downto 0);
signal pca_d61_out   : std_logic_vector(CL_W + PCAweightW + 5 downto 0);
signal pca_d62_out   : std_logic_vector(CL_W + PCAweightW + 5 downto 0);
signal pca_d63_out   : std_logic_vector(CL_W + PCAweightW + 5 downto 0);
signal pca_d64_out   : std_logic_vector(CL_W + PCAweightW + 5 downto 0);
signal pca_en_out  : std_logic;
signal pca_sof_out : std_logic;

signal d_tmp_1_out   : std_logic_vector (Wb-1 downto 0);
signal d_tmp_2_out   : std_logic_vector (Wb-1 downto 0);
signal d_tmp_3_out   : std_logic_vector (Wb-1 downto 0);
signal d_tmp_4_out   : std_logic_vector (Wb-1 downto 0);
signal d_tmp_5_out   : std_logic_vector (Wb-1 downto 0);
signal d_tmp_6_out   : std_logic_vector (Wb-1 downto 0);
signal d_tmp_7_out   : std_logic_vector (Wb-1 downto 0);
signal d_tmp_8_out   : std_logic_vector (Wb-1 downto 0);
signal d_tmp_9_out   : std_logic_vector (Wb-1 downto 0);
signal d_tmp_10_out  : std_logic_vector (Wb-1 downto 0);
signal d_tmp_11_out  : std_logic_vector (Wb-1 downto 0);
signal d_tmp_12_out  : std_logic_vector (Wb-1 downto 0);
signal d_tmp_13_out  : std_logic_vector (Wb-1 downto 0);
signal d_tmp_14_out  : std_logic_vector (Wb-1 downto 0);
signal d_tmp_15_out  : std_logic_vector (Wb-1 downto 0);
signal d_tmp_16_out  : std_logic_vector (Wb-1 downto 0);


type Huff_code_type  is array ( 0 to 255 ) of std_logic_vector(Huff_wid-1 downto 0);
type Huff_width_type is array ( 0 to 255 ) of std_logic_vector(         3 downto 0);

constant Huff_code  : Huff_code_type  := ( 0 => x"003", 1 => x"037", 2 => x"932", 3 => x"124", 4 => x"611", 5 => x"027", 6 => x"523", 7 => x"630", 8 => x"121", 9 => x"361", others => x"BAD"); 
constant Huff_width : Huff_width_type := ( 0 => x"4", 1 => x"8",  2 => x"C",   3 => x"C",   4 => x"C",   5 => x"8",  6 => x"C",   7 => x"C",   8 => x"C",   9 => x"C",   others => x"C"); 

signal h_en          : std_logic;
signal h_count_en    : std_logic;
signal h_count_en2   : std_logic;
signal h_count       : std_logic_vector(         7 downto 0);
signal alpha_data    : std_logic_vector(         7 downto 0);
signal alpha_code    : std_logic_vector(Huff_wid-1 downto 0);
signal alpha_width   : std_logic_vector(         3 downto 0);



signal huff_out      : std_logic_vector (Wb-1 downto 0);

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
       w01_in <=  weight01(conv_integer('0' & w_count));
       w02_in <=  weight02(conv_integer('0' & w_count));
       w03_in <=  weight03(conv_integer('0' & w_count));
       w04_in <=  weight04(conv_integer('0' & w_count));
       w05_in <=  weight05(conv_integer('0' & w_count));
       w06_in <=  weight06(conv_integer('0' & w_count));
       w07_in <=  weight07(conv_integer('0' & w_count));
       w08_in <=  weight08(conv_integer('0' & w_count));
       w09_in <=  weight09(conv_integer('0' & w_count));
       w10_in <=  weight10(conv_integer('0' & w_count));
       w11_in <=  weight11(conv_integer('0' & w_count));
       w12_in <=  weight12(conv_integer('0' & w_count));
       w13_in <=  weight13(conv_integer('0' & w_count));
       w14_in <=  weight14(conv_integer('0' & w_count));
       w15_in <=  weight15(conv_integer('0' & w_count));
       w16_in <=  weight16(conv_integer('0' & w_count));
       w17_in <=  weight17(conv_integer('0' & w_count));
       w18_in <=  weight18(conv_integer('0' & w_count));
       w19_in <=  weight19(conv_integer('0' & w_count));
       w20_in <=  weight20(conv_integer('0' & w_count));
       w21_in <=  weight21(conv_integer('0' & w_count));
       w22_in <=  weight22(conv_integer('0' & w_count));
       w23_in <=  weight23(conv_integer('0' & w_count));
       w24_in <=  weight24(conv_integer('0' & w_count));
       w25_in <=  weight25(conv_integer('0' & w_count));
       w26_in <=  weight26(conv_integer('0' & w_count));
       w27_in <=  weight27(conv_integer('0' & w_count));
       w28_in <=  weight28(conv_integer('0' & w_count));
       w29_in <=  weight29(conv_integer('0' & w_count));
       w30_in <=  weight30(conv_integer('0' & w_count));
       w31_in <=  weight31(conv_integer('0' & w_count));
       w32_in <=  weight32(conv_integer('0' & w_count));
       w33_in <=  weight33(conv_integer('0' & w_count));
       w34_in <=  weight34(conv_integer('0' & w_count));
       w35_in <=  weight35(conv_integer('0' & w_count));
       w36_in <=  weight36(conv_integer('0' & w_count));
       w37_in <=  weight37(conv_integer('0' & w_count));
       w38_in <=  weight38(conv_integer('0' & w_count));
       w39_in <=  weight39(conv_integer('0' & w_count));
       w40_in <=  weight40(conv_integer('0' & w_count));
       w41_in <=  weight41(conv_integer('0' & w_count));
       w42_in <=  weight42(conv_integer('0' & w_count));
       w43_in <=  weight43(conv_integer('0' & w_count));
       w44_in <=  weight44(conv_integer('0' & w_count));
       w45_in <=  weight45(conv_integer('0' & w_count));
       w46_in <=  weight46(conv_integer('0' & w_count));
       w47_in <=  weight47(conv_integer('0' & w_count));
       w48_in <=  weight48(conv_integer('0' & w_count));
       w49_in <=  weight49(conv_integer('0' & w_count));
       w50_in <=  weight50(conv_integer('0' & w_count));
       w51_in <=  weight51(conv_integer('0' & w_count));
       w52_in <=  weight52(conv_integer('0' & w_count));
       w53_in <=  weight53(conv_integer('0' & w_count));
       w54_in <=  weight54(conv_integer('0' & w_count));
       w55_in <=  weight55(conv_integer('0' & w_count));
       w56_in <=  weight56(conv_integer('0' & w_count));
       w57_in <=  weight57(conv_integer('0' & w_count));
       w58_in <=  weight58(conv_integer('0' & w_count));
       w59_in <=  weight59(conv_integer('0' & w_count));
       w60_in <=  weight60(conv_integer('0' & w_count));
       w61_in <=  weight61(conv_integer('0' & w_count));
       w62_in <=  weight62(conv_integer('0' & w_count));
       w63_in <=  weight63(conv_integer('0' & w_count));
       w64_in <=  weight64(conv_integer('0' & w_count));
    end if;
  end process p_weight2;

CL01: ConvLayer generic map (mult_sum => mult_sum,N => N,M => CL_w_width,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w01_in, w_num => w_num, w_en => w_en, d_out => d01_out, en_out => cl_en_out, sof_out => cl_sof_out);
CL02: ConvLayer generic map (mult_sum => mult_sum,N => N,M => CL_w_width,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w02_in, w_num => w_num, w_en => w_en, d_out => d02_out, en_out => open, sof_out => open);
CL03: ConvLayer generic map (mult_sum => mult_sum,N => N,M => CL_w_width,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w03_in, w_num => w_num, w_en => w_en, d_out => d03_out, en_out => open, sof_out => open);
CL04: ConvLayer generic map (mult_sum => mult_sum,N => N,M => CL_w_width,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w04_in, w_num => w_num, w_en => w_en, d_out => d04_out, en_out => open, sof_out => open);
CL05: ConvLayer generic map (mult_sum => mult_sum,N => N,M => CL_w_width,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w05_in, w_num => w_num, w_en => w_en, d_out => d05_out, en_out => open, sof_out => open);
CL06: ConvLayer generic map (mult_sum => mult_sum,N => N,M => CL_w_width,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w06_in, w_num => w_num, w_en => w_en, d_out => d06_out, en_out => open, sof_out => open);
CL07: ConvLayer generic map (mult_sum => mult_sum,N => N,M => CL_w_width,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w07_in, w_num => w_num, w_en => w_en, d_out => d07_out, en_out => open, sof_out => open);
CL08: ConvLayer generic map (mult_sum => mult_sum,N => N,M => CL_w_width,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w08_in, w_num => w_num, w_en => w_en, d_out => d08_out, en_out => open, sof_out => open);
CL09: ConvLayer generic map (mult_sum => mult_sum,N => N,M => CL_w_width,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w09_in, w_num => w_num, w_en => w_en, d_out => d09_out, en_out => open, sof_out => open);
CL10: ConvLayer generic map (mult_sum => mult_sum,N => N,M => CL_w_width,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w10_in, w_num => w_num, w_en => w_en, d_out => d10_out, en_out => open, sof_out => open);
CL11: ConvLayer generic map (mult_sum => mult_sum,N => N,M => CL_w_width,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w11_in, w_num => w_num, w_en => w_en, d_out => d11_out, en_out => open, sof_out => open);
CL12: ConvLayer generic map (mult_sum => mult_sum,N => N,M => CL_w_width,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w12_in, w_num => w_num, w_en => w_en, d_out => d12_out, en_out => open, sof_out => open);
CL13: ConvLayer generic map (mult_sum => mult_sum,N => N,M => CL_w_width,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w13_in, w_num => w_num, w_en => w_en, d_out => d13_out, en_out => open, sof_out => open);
CL14: ConvLayer generic map (mult_sum => mult_sum,N => N,M => CL_w_width,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w14_in, w_num => w_num, w_en => w_en, d_out => d14_out, en_out => open, sof_out => open);
CL15: ConvLayer generic map (mult_sum => mult_sum,N => N,M => CL_w_width,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w15_in, w_num => w_num, w_en => w_en, d_out => d15_out, en_out => open, sof_out => open);
CL16: ConvLayer generic map (mult_sum => mult_sum,N => N,M => CL_w_width,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w16_in, w_num => w_num, w_en => w_en, d_out => d16_out, en_out => open, sof_out => open);
CL17: ConvLayer generic map (mult_sum => mult_sum,N => N,M => CL_w_width,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w17_in, w_num => w_num, w_en => w_en, d_out => d17_out, en_out => open, sof_out => open);
CL18: ConvLayer generic map (mult_sum => mult_sum,N => N,M => CL_w_width,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w18_in, w_num => w_num, w_en => w_en, d_out => d18_out, en_out => open, sof_out => open);
CL19: ConvLayer generic map (mult_sum => mult_sum,N => N,M => CL_w_width,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w19_in, w_num => w_num, w_en => w_en, d_out => d19_out, en_out => open, sof_out => open);
CL20: ConvLayer generic map (mult_sum => mult_sum,N => N,M => CL_w_width,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w20_in, w_num => w_num, w_en => w_en, d_out => d20_out, en_out => open, sof_out => open);
CL21: ConvLayer generic map (mult_sum => mult_sum,N => N,M => CL_w_width,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w21_in, w_num => w_num, w_en => w_en, d_out => d21_out, en_out => open, sof_out => open);
CL22: ConvLayer generic map (mult_sum => mult_sum,N => N,M => CL_w_width,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w22_in, w_num => w_num, w_en => w_en, d_out => d22_out, en_out => open, sof_out => open);
CL23: ConvLayer generic map (mult_sum => mult_sum,N => N,M => CL_w_width,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w23_in, w_num => w_num, w_en => w_en, d_out => d23_out, en_out => open, sof_out => open);
CL24: ConvLayer generic map (mult_sum => mult_sum,N => N,M => CL_w_width,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w24_in, w_num => w_num, w_en => w_en, d_out => d24_out, en_out => open, sof_out => open);
CL25: ConvLayer generic map (mult_sum => mult_sum,N => N,M => CL_w_width,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w25_in, w_num => w_num, w_en => w_en, d_out => d25_out, en_out => open, sof_out => open);
CL26: ConvLayer generic map (mult_sum => mult_sum,N => N,M => CL_w_width,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w26_in, w_num => w_num, w_en => w_en, d_out => d26_out, en_out => open, sof_out => open);
CL27: ConvLayer generic map (mult_sum => mult_sum,N => N,M => CL_w_width,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w27_in, w_num => w_num, w_en => w_en, d_out => d27_out, en_out => open, sof_out => open);
CL28: ConvLayer generic map (mult_sum => mult_sum,N => N,M => CL_w_width,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w28_in, w_num => w_num, w_en => w_en, d_out => d28_out, en_out => open, sof_out => open);
CL29: ConvLayer generic map (mult_sum => mult_sum,N => N,M => CL_w_width,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w29_in, w_num => w_num, w_en => w_en, d_out => d29_out, en_out => open, sof_out => open);
CL30: ConvLayer generic map (mult_sum => mult_sum,N => N,M => CL_w_width,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w30_in, w_num => w_num, w_en => w_en, d_out => d30_out, en_out => open, sof_out => open);
CL31: ConvLayer generic map (mult_sum => mult_sum,N => N,M => CL_w_width,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w31_in, w_num => w_num, w_en => w_en, d_out => d31_out, en_out => open, sof_out => open);
CL32: ConvLayer generic map (mult_sum => mult_sum,N => N,M => CL_w_width,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w32_in, w_num => w_num, w_en => w_en, d_out => d32_out, en_out => open, sof_out => open);
CL33: ConvLayer generic map (mult_sum => mult_sum,N => N,M => CL_w_width,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w33_in, w_num => w_num, w_en => w_en, d_out => d33_out, en_out => open, sof_out => open);
CL34: ConvLayer generic map (mult_sum => mult_sum,N => N,M => CL_w_width,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w34_in, w_num => w_num, w_en => w_en, d_out => d34_out, en_out => open, sof_out => open);
CL35: ConvLayer generic map (mult_sum => mult_sum,N => N,M => CL_w_width,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w35_in, w_num => w_num, w_en => w_en, d_out => d35_out, en_out => open, sof_out => open);
CL36: ConvLayer generic map (mult_sum => mult_sum,N => N,M => CL_w_width,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w36_in, w_num => w_num, w_en => w_en, d_out => d36_out, en_out => open, sof_out => open);
CL37: ConvLayer generic map (mult_sum => mult_sum,N => N,M => CL_w_width,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w37_in, w_num => w_num, w_en => w_en, d_out => d37_out, en_out => open, sof_out => open);
CL38: ConvLayer generic map (mult_sum => mult_sum,N => N,M => CL_w_width,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w38_in, w_num => w_num, w_en => w_en, d_out => d38_out, en_out => open, sof_out => open);
CL39: ConvLayer generic map (mult_sum => mult_sum,N => N,M => CL_w_width,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w39_in, w_num => w_num, w_en => w_en, d_out => d39_out, en_out => open, sof_out => open);
CL40: ConvLayer generic map (mult_sum => mult_sum,N => N,M => CL_w_width,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w40_in, w_num => w_num, w_en => w_en, d_out => d40_out, en_out => open, sof_out => open);
CL41: ConvLayer generic map (mult_sum => mult_sum,N => N,M => CL_w_width,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w41_in, w_num => w_num, w_en => w_en, d_out => d41_out, en_out => open, sof_out => open);
CL42: ConvLayer generic map (mult_sum => mult_sum,N => N,M => CL_w_width,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w42_in, w_num => w_num, w_en => w_en, d_out => d42_out, en_out => open, sof_out => open);
CL43: ConvLayer generic map (mult_sum => mult_sum,N => N,M => CL_w_width,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w43_in, w_num => w_num, w_en => w_en, d_out => d43_out, en_out => open, sof_out => open);
CL44: ConvLayer generic map (mult_sum => mult_sum,N => N,M => CL_w_width,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w44_in, w_num => w_num, w_en => w_en, d_out => d44_out, en_out => open, sof_out => open);
CL45: ConvLayer generic map (mult_sum => mult_sum,N => N,M => CL_w_width,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w45_in, w_num => w_num, w_en => w_en, d_out => d45_out, en_out => open, sof_out => open);
CL46: ConvLayer generic map (mult_sum => mult_sum,N => N,M => CL_w_width,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w46_in, w_num => w_num, w_en => w_en, d_out => d46_out, en_out => open, sof_out => open);
CL47: ConvLayer generic map (mult_sum => mult_sum,N => N,M => CL_w_width,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w47_in, w_num => w_num, w_en => w_en, d_out => d47_out, en_out => open, sof_out => open);
CL48: ConvLayer generic map (mult_sum => mult_sum,N => N,M => CL_w_width,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w48_in, w_num => w_num, w_en => w_en, d_out => d48_out, en_out => open, sof_out => open);
CL49: ConvLayer generic map (mult_sum => mult_sum,N => N,M => CL_w_width,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w49_in, w_num => w_num, w_en => w_en, d_out => d49_out, en_out => open, sof_out => open);
CL50: ConvLayer generic map (mult_sum => mult_sum,N => N,M => CL_w_width,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w50_in, w_num => w_num, w_en => w_en, d_out => d50_out, en_out => open, sof_out => open);
CL51: ConvLayer generic map (mult_sum => mult_sum,N => N,M => CL_w_width,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w51_in, w_num => w_num, w_en => w_en, d_out => d51_out, en_out => open, sof_out => open);
CL52: ConvLayer generic map (mult_sum => mult_sum,N => N,M => CL_w_width,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w52_in, w_num => w_num, w_en => w_en, d_out => d52_out, en_out => open, sof_out => open);
CL53: ConvLayer generic map (mult_sum => mult_sum,N => N,M => CL_w_width,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w53_in, w_num => w_num, w_en => w_en, d_out => d53_out, en_out => open, sof_out => open);
CL54: ConvLayer generic map (mult_sum => mult_sum,N => N,M => CL_w_width,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w54_in, w_num => w_num, w_en => w_en, d_out => d54_out, en_out => open, sof_out => open);
CL55: ConvLayer generic map (mult_sum => mult_sum,N => N,M => CL_w_width,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w55_in, w_num => w_num, w_en => w_en, d_out => d55_out, en_out => open, sof_out => open);
CL56: ConvLayer generic map (mult_sum => mult_sum,N => N,M => CL_w_width,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w56_in, w_num => w_num, w_en => w_en, d_out => d56_out, en_out => open, sof_out => open);
CL57: ConvLayer generic map (mult_sum => mult_sum,N => N,M => CL_w_width,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w57_in, w_num => w_num, w_en => w_en, d_out => d57_out, en_out => open, sof_out => open);
CL58: ConvLayer generic map (mult_sum => mult_sum,N => N,M => CL_w_width,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w58_in, w_num => w_num, w_en => w_en, d_out => d58_out, en_out => open, sof_out => open);
CL59: ConvLayer generic map (mult_sum => mult_sum,N => N,M => CL_w_width,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w59_in, w_num => w_num, w_en => w_en, d_out => d59_out, en_out => open, sof_out => open);
CL60: ConvLayer generic map (mult_sum => mult_sum,N => N,M => CL_w_width,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w60_in, w_num => w_num, w_en => w_en, d_out => d60_out, en_out => open, sof_out => open);
CL61: ConvLayer generic map (mult_sum => mult_sum,N => N,M => CL_w_width,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w61_in, w_num => w_num, w_en => w_en, d_out => d61_out, en_out => open, sof_out => open);
CL62: ConvLayer generic map (mult_sum => mult_sum,N => N,M => CL_w_width,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w62_in, w_num => w_num, w_en => w_en, d_out => d62_out, en_out => open, sof_out => open);
CL63: ConvLayer generic map (mult_sum => mult_sum,N => N,M => CL_w_width,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w63_in, w_num => w_num, w_en => w_en, d_out => d63_out, en_out => open, sof_out => open);
CL64: ConvLayer generic map (mult_sum => mult_sum,N => N,M => CL_w_width,W => CL_W,SR => CL_SR,in_row => in_row, in_col => in_col)port map ( clk => clk, rst => rst, d_in => d_in, en_in => en_in, sof_in => sof_in, w_in => w64_in, w_num => w_num, w_en => w_en, d_out => d64_out, en_out => open, sof_out => open);



g_PCA_en: if PCA_en = TRUE generate

PCA64_1_inst: PCA_64 
  generic map(
           mult_sum => mult_sum,
           N        => CL_W,
           M        => PCAweightW,
           in_row   => in_row,
           in_col   => in_col
           )
  port map (
           clk       => clk    ,
           rst       => rst    ,
d01_in    => d01_out, d02_in    => d02_out, d03_in    => d03_out, d04_in    => d04_out, d05_in    => d05_out, d06_in    => d06_out, d07_in    => d07_out, d08_in    => d08_out, 
d09_in    => d09_out, d10_in    => d10_out, d11_in    => d11_out, d12_in    => d12_out, d13_in    => d13_out, d14_in    => d14_out, d15_in    => d15_out, d16_in    => d16_out, 
d17_in    => d17_out, d18_in    => d18_out, d19_in    => d19_out, d20_in    => d20_out, d21_in    => d21_out, d22_in    => d22_out, d23_in    => d23_out, d24_in    => d24_out, 
d25_in    => d25_out, d26_in    => d26_out, d27_in    => d27_out, d28_in    => d28_out, d29_in    => d29_out, d30_in    => d30_out, d31_in    => d31_out, d32_in    => d32_out, 
d33_in    => d33_out, d34_in    => d34_out, d35_in    => d35_out, d36_in    => d36_out, d37_in    => d37_out, d38_in    => d38_out, d39_in    => d39_out, d40_in    => d40_out, 
d41_in    => d41_out, d42_in    => d42_out, d43_in    => d43_out, d44_in    => d44_out, d45_in    => d45_out, d46_in    => d46_out, d47_in    => d47_out, d48_in    => d48_out, 
d49_in    => d49_out, d50_in    => d50_out, d51_in    => d51_out, d52_in    => d52_out, d53_in    => d53_out, d54_in    => d54_out, d55_in    => d55_out, d56_in    => d56_out,
d57_in    => d57_out, d58_in    => d58_out, d59_in    => d59_out, d60_in    => d60_out, d61_in    => d61_out, d62_in    => d62_out, d63_in    => d63_out, d64_in    => d64_out, 
           en_in     => cl_en_out,
           sof_in    => cl_sof_out,

           w01      => x"d9", 
           w02      => x"66", 
           w03      => x"71", 
           w04      => x"f3", 
           w05      => x"12", 
           w06      => x"8e", 
           w07      => x"9c", 
           w08      => x"ab", 
           w09      => x"dc", 
           w10      => x"ec", 
           w11      => x"af", 
           w12      => x"b7", 
           w13      => x"67", 
           w14      => x"c9", 
           w15      => x"77", 
           w16      => x"5a", 
           w17      => x"45", 
           w18      => x"89", 
           w19      => x"a3", 
           w20      => x"0a", 
           w21      => x"9c", 
           w22      => x"c9", 
           w23      => x"65", 
           w24      => x"3d", 
           w25      => x"4c", 
           w26      => x"62", 
           w27      => x"2f", 
           w28      => x"66", 
           w29      => x"4b", 
           w30      => x"f3", 
           w31      => x"a1", 
           w32      => x"ba", 
           w33      => x"38", 
           w34      => x"89", 
           w35      => x"30", 
           w36      => x"e0", 
           w37      => x"91", 
           w38      => x"e0", 
           w39      => x"69", 
           w40      => x"f8", 
           w41      => x"2f", 
           w42      => x"10", 
           w43      => x"a2", 
           w44      => x"ab", 
           w45      => x"de", 
           w46      => x"6f", 
           w47      => x"25", 
           w48      => x"a8", 
           w49      => x"b4", 
           w50      => x"89", 
           w51      => x"de", 
           w52      => x"5f", 
           w53      => x"c2", 
           w54      => x"ad", 
           w55      => x"d7", 
           w56      => x"fc", 
           w57      => x"ce", 
           w58      => x"4a", 
           w59      => x"0b", 
           w60      => x"dd", 
           w61      => x"d3", 
           w62      => x"0f", 
           w63      => x"80", 
           w64      => x"90", 

           d_out   => pca_d01_out   ,
           en_out  => pca_en_out  ,
           sof_out => pca_sof_out );

PCA64_2_inst: PCA_64 
  generic map(
           mult_sum => mult_sum,
           N        => CL_W,
           M        => PCAweightW,
           in_row   => in_row,
           in_col   => in_col
           )
  port map (
           clk       => clk    ,
           rst       => rst    ,
d01_in    => d01_out, d02_in    => d02_out, d03_in    => d03_out, d04_in    => d04_out, d05_in    => d05_out, d06_in    => d06_out, d07_in    => d07_out, d08_in    => d08_out, 
d09_in    => d09_out, d10_in    => d10_out, d11_in    => d11_out, d12_in    => d12_out, d13_in    => d13_out, d14_in    => d14_out, d15_in    => d15_out, d16_in    => d16_out, 
d17_in    => d17_out, d18_in    => d18_out, d19_in    => d19_out, d20_in    => d20_out, d21_in    => d21_out, d22_in    => d22_out, d23_in    => d23_out, d24_in    => d24_out, 
d25_in    => d25_out, d26_in    => d26_out, d27_in    => d27_out, d28_in    => d28_out, d29_in    => d29_out, d30_in    => d30_out, d31_in    => d31_out, d32_in    => d32_out, 
d33_in    => d33_out, d34_in    => d34_out, d35_in    => d35_out, d36_in    => d36_out, d37_in    => d37_out, d38_in    => d38_out, d39_in    => d39_out, d40_in    => d40_out, 
d41_in    => d41_out, d42_in    => d42_out, d43_in    => d43_out, d44_in    => d44_out, d45_in    => d45_out, d46_in    => d46_out, d47_in    => d47_out, d48_in    => d48_out, 
d49_in    => d49_out, d50_in    => d50_out, d51_in    => d51_out, d52_in    => d52_out, d53_in    => d53_out, d54_in    => d54_out, d55_in    => d55_out, d56_in    => d56_out,
d57_in    => d57_out, d58_in    => d58_out, d59_in    => d59_out, d60_in    => d60_out, d61_in    => d61_out, d62_in    => d62_out, d63_in    => d63_out, d64_in    => d64_out, 
           en_in     => '0',
           sof_in    => '0',

           w01      => x"61", 
           w02      => x"be", 
           w03      => x"14", 
           w04      => x"3c", 
           w05      => x"dd", 
           w06      => x"36", 
           w07      => x"93", 
           w08      => x"25", 
           w09      => x"6a", 
           w10      => x"5c", 
           w11      => x"16", 
           w12      => x"b6", 
           w13      => x"f5", 
           w14      => x"e8", 
           w15      => x"4e", 
           w16      => x"26", 
           w17      => x"08", 
           w18      => x"3d", 
           w19      => x"50", 
           w20      => x"b5", 
           w21      => x"29", 
           w22      => x"83", 
           w23      => x"23", 
           w24      => x"e9", 
           w25      => x"1f", 
           w26      => x"93", 
           w27      => x"14", 
           w28      => x"09", 
           w29      => x"ea", 
           w30      => x"07", 
           w31      => x"f2", 
           w32      => x"5d", 
           w33      => x"bd", 
           w34      => x"ed", 
           w35      => x"fc", 
           w36      => x"8a", 
           w37      => x"74", 
           w38      => x"bc", 
           w39      => x"57", 
           w40      => x"91", 
           w41      => x"e9", 
           w42      => x"8a", 
           w43      => x"98", 
           w44      => x"a7", 
           w45      => x"38", 
           w46      => x"16", 
           w47      => x"ef", 
           w48      => x"89", 
           w49      => x"ab", 
           w50      => x"3b", 
           w51      => x"dd", 
           w52      => x"67", 
           w53      => x"40", 
           w54      => x"d8", 
           w55      => x"a3", 
           w56      => x"5d", 
           w57      => x"33", 
           w58      => x"64", 
           w59      => x"16", 
           w60      => x"d3", 
           w61      => x"61", 
           w62      => x"24", 
           w63      => x"3e", 
           w64      => x"8a", 
           d_out    => pca_d02_out, en_out  => open, sof_out => open );

PCA64_3_inst: PCA_64 
  generic map(
           mult_sum => mult_sum,
           N        => CL_W,
           M        => PCAweightW,
           in_row   => in_row,
           in_col   => in_col
           )
  port map (
           clk       => clk    ,
           rst       => rst    ,
d01_in    => d01_out, d02_in    => d02_out, d03_in    => d03_out, d04_in    => d04_out, d05_in    => d05_out, d06_in    => d06_out, d07_in    => d07_out, d08_in    => d08_out, 
d09_in    => d09_out, d10_in    => d10_out, d11_in    => d11_out, d12_in    => d12_out, d13_in    => d13_out, d14_in    => d14_out, d15_in    => d15_out, d16_in    => d16_out, 
d17_in    => d17_out, d18_in    => d18_out, d19_in    => d19_out, d20_in    => d20_out, d21_in    => d21_out, d22_in    => d22_out, d23_in    => d23_out, d24_in    => d24_out, 
d25_in    => d25_out, d26_in    => d26_out, d27_in    => d27_out, d28_in    => d28_out, d29_in    => d29_out, d30_in    => d30_out, d31_in    => d31_out, d32_in    => d32_out, 
d33_in    => d33_out, d34_in    => d34_out, d35_in    => d35_out, d36_in    => d36_out, d37_in    => d37_out, d38_in    => d38_out, d39_in    => d39_out, d40_in    => d40_out, 
d41_in    => d41_out, d42_in    => d42_out, d43_in    => d43_out, d44_in    => d44_out, d45_in    => d45_out, d46_in    => d46_out, d47_in    => d47_out, d48_in    => d48_out, 
d49_in    => d49_out, d50_in    => d50_out, d51_in    => d51_out, d52_in    => d52_out, d53_in    => d53_out, d54_in    => d54_out, d55_in    => d55_out, d56_in    => d56_out,
d57_in    => d57_out, d58_in    => d58_out, d59_in    => d59_out, d60_in    => d60_out, d61_in    => d61_out, d62_in    => d62_out, d63_in    => d63_out, d64_in    => d64_out, 
           en_in     => '0',
           sof_in    => '0',

           w01      => x"97", 
           w02      => x"31", 
           w03      => x"8c", 
           w04      => x"09", 
           w05      => x"48", 
           w06      => x"6a", 
           w07      => x"4f", 
           w08      => x"df", 
           w09      => x"a3", 
           w10      => x"46", 
           w11      => x"a0", 
           w12      => x"65", 
           w13      => x"b3", 
           w14      => x"47", 
           w15      => x"34", 
           w16      => x"50", 
           w17      => x"4f", 
           w18      => x"b9", 
           w19      => x"e0", 
           w20      => x"73", 
           w21      => x"bf", 
           w22      => x"e0", 
           w23      => x"91", 
           w24      => x"8e", 
           w25      => x"d4", 
           w26      => x"b6", 
           w27      => x"ae", 
           w28      => x"2b", 
           w29      => x"b4", 
           w30      => x"48", 
           w31      => x"15", 
           w32      => x"8f", 
           w33      => x"b0", 
           w34      => x"b5", 
           w35      => x"3c", 
           w36      => x"ae", 
           w37      => x"52", 
           w38      => x"44", 
           w39      => x"28", 
           w40      => x"61", 
           w41      => x"a3", 
           w42      => x"52", 
           w43      => x"3a", 
           w44      => x"b5", 
           w45      => x"e1", 
           w46      => x"4a", 
           w47      => x"6b", 
           w48      => x"2d", 
           w49      => x"8e", 
           w50      => x"a8", 
           w51      => x"cd", 
           w52      => x"ff", 
           w53      => x"fa", 
           w54      => x"83", 
           w55      => x"0e", 
           w56      => x"61", 
           w57      => x"50", 
           w58      => x"15", 
           w59      => x"20", 
           w60      => x"54", 
           w61      => x"f0", 
           w62      => x"76", 
           w63      => x"bc", 
           w64      => x"82", 
           d_out   => pca_d03_out, en_out  => open, sof_out => open );

PCA64_4_inst: PCA_64 
  generic map(
           mult_sum => mult_sum,
           N        => CL_W,
           M        => PCAweightW,
           in_row   => in_row,
           in_col   => in_col
           )
  port map (
           clk       => clk    ,
           rst       => rst    ,
d01_in    => d01_out, d02_in    => d02_out, d03_in    => d03_out, d04_in    => d04_out, d05_in    => d05_out, d06_in    => d06_out, d07_in    => d07_out, d08_in    => d08_out, 
d09_in    => d09_out, d10_in    => d10_out, d11_in    => d11_out, d12_in    => d12_out, d13_in    => d13_out, d14_in    => d14_out, d15_in    => d15_out, d16_in    => d16_out, 
d17_in    => d17_out, d18_in    => d18_out, d19_in    => d19_out, d20_in    => d20_out, d21_in    => d21_out, d22_in    => d22_out, d23_in    => d23_out, d24_in    => d24_out, 
d25_in    => d25_out, d26_in    => d26_out, d27_in    => d27_out, d28_in    => d28_out, d29_in    => d29_out, d30_in    => d30_out, d31_in    => d31_out, d32_in    => d32_out, 
d33_in    => d33_out, d34_in    => d34_out, d35_in    => d35_out, d36_in    => d36_out, d37_in    => d37_out, d38_in    => d38_out, d39_in    => d39_out, d40_in    => d40_out, 
d41_in    => d41_out, d42_in    => d42_out, d43_in    => d43_out, d44_in    => d44_out, d45_in    => d45_out, d46_in    => d46_out, d47_in    => d47_out, d48_in    => d48_out, 
d49_in    => d49_out, d50_in    => d50_out, d51_in    => d51_out, d52_in    => d52_out, d53_in    => d53_out, d54_in    => d54_out, d55_in    => d55_out, d56_in    => d56_out,
d57_in    => d57_out, d58_in    => d58_out, d59_in    => d59_out, d60_in    => d60_out, d61_in    => d61_out, d62_in    => d62_out, d63_in    => d63_out, d64_in    => d64_out, 
           en_in     => '0',
           sof_in    => '0',

           w01      => x"43", 
           w02      => x"ec", 
           w03      => x"ea", 
           w04      => x"40", 
           w05      => x"c8", 
           w06      => x"a0", 
           w07      => x"5d", 
           w08      => x"f4", 
           w09      => x"95", 
           w10      => x"19", 
           w11      => x"d9", 
           w12      => x"5a", 
           w13      => x"85", 
           w14      => x"99", 
           w15      => x"0d", 
           w16      => x"95", 
           w17      => x"2e", 
           w18      => x"79", 
           w19      => x"5f", 
           w20      => x"3e", 
           w21      => x"a3", 
           w22      => x"6a", 
           w23      => x"8f", 
           w24      => x"7f", 
           w25      => x"5e", 
           w26      => x"a5", 
           w27      => x"a3", 
           w28      => x"2a", 
           w29      => x"0a", 
           w30      => x"59", 
           w31      => x"8e", 
           w32      => x"f7", 
           w33      => x"87", 
           w34      => x"85", 
           w35      => x"e8", 
           w36      => x"e2", 
           w37      => x"ee", 
           w38      => x"4e", 
           w39      => x"c6", 
           w40      => x"99", 
           w41      => x"1a", 
           w42      => x"61", 
           w43      => x"7b", 
           w44      => x"ee", 
           w45      => x"52", 
           w46      => x"5c", 
           w47      => x"5a", 
           w48      => x"f0", 
           w49      => x"70", 
           w50      => x"ca", 
           w51      => x"0e", 
           w52      => x"b9", 
           w53      => x"23", 
           w54      => x"e5", 
           w55      => x"a1", 
           w56      => x"0d", 
           w57      => x"fb", 
           w58      => x"fa", 
           w59      => x"8b", 
           w60      => x"f6", 
           w61      => x"a9", 
           w62      => x"83", 
           w63      => x"13", 
           w64      => x"7b", 
           d_out   => pca_d04_out, en_out  => open, sof_out => open );

PCA64_5_inst: PCA_64 
  generic map(
           mult_sum => mult_sum,
           N        => CL_W,
           M        => PCAweightW,
           in_row   => in_row,
           in_col   => in_col
           )
  port map (
           clk       => clk    ,
           rst       => rst    ,
d01_in    => d01_out, d02_in    => d02_out, d03_in    => d03_out, d04_in    => d04_out, d05_in    => d05_out, d06_in    => d06_out, d07_in    => d07_out, d08_in    => d08_out, 
d09_in    => d09_out, d10_in    => d10_out, d11_in    => d11_out, d12_in    => d12_out, d13_in    => d13_out, d14_in    => d14_out, d15_in    => d15_out, d16_in    => d16_out, 
d17_in    => d17_out, d18_in    => d18_out, d19_in    => d19_out, d20_in    => d20_out, d21_in    => d21_out, d22_in    => d22_out, d23_in    => d23_out, d24_in    => d24_out, 
d25_in    => d25_out, d26_in    => d26_out, d27_in    => d27_out, d28_in    => d28_out, d29_in    => d29_out, d30_in    => d30_out, d31_in    => d31_out, d32_in    => d32_out, 
d33_in    => d33_out, d34_in    => d34_out, d35_in    => d35_out, d36_in    => d36_out, d37_in    => d37_out, d38_in    => d38_out, d39_in    => d39_out, d40_in    => d40_out, 
d41_in    => d41_out, d42_in    => d42_out, d43_in    => d43_out, d44_in    => d44_out, d45_in    => d45_out, d46_in    => d46_out, d47_in    => d47_out, d48_in    => d48_out, 
d49_in    => d49_out, d50_in    => d50_out, d51_in    => d51_out, d52_in    => d52_out, d53_in    => d53_out, d54_in    => d54_out, d55_in    => d55_out, d56_in    => d56_out,
d57_in    => d57_out, d58_in    => d58_out, d59_in    => d59_out, d60_in    => d60_out, d61_in    => d61_out, d62_in    => d62_out, d63_in    => d63_out, d64_in    => d64_out, 
           en_in     => '0',
           sof_in    => '0',

           w01      => x"e1", 
           w02      => x"dc", 
           w03      => x"9d", 
           w04      => x"8f", 
           w05      => x"a7", 
           w06      => x"7c", 
           w07      => x"f0", 
           w08      => x"a3", 
           w09      => x"7e", 
           w10      => x"7c", 
           w11      => x"ec", 
           w12      => x"cf", 
           w13      => x"0c", 
           w14      => x"75", 
           w15      => x"fd", 
           w16      => x"31", 
           w17      => x"4f", 
           w18      => x"c7", 
           w19      => x"e5", 
           w20      => x"eb", 
           w21      => x"16", 
           w22      => x"31", 
           w23      => x"88", 
           w24      => x"ab", 
           w25      => x"91", 
           w26      => x"cc", 
           w27      => x"21", 
           w28      => x"33", 
           w29      => x"af", 
           w30      => x"80", 
           w31      => x"48", 
           w32      => x"82", 
           w33      => x"19", 
           w34      => x"93", 
           w35      => x"bb", 
           w36      => x"38", 
           w37      => x"8a", 
           w38      => x"11", 
           w39      => x"20", 
           w40      => x"c7", 
           w41      => x"94", 
           w42      => x"78", 
           w43      => x"d4", 
           w44      => x"89", 
           w45      => x"46", 
           w46      => x"1f", 
           w47      => x"d1", 
           w48      => x"34", 
           w49      => x"e8", 
           w50      => x"c2", 
           w51      => x"e5", 
           w52      => x"63", 
           w53      => x"43", 
           w54      => x"ee", 
           w55      => x"7e", 
           w56      => x"1e", 
           w57      => x"99", 
           w58      => x"98", 
           w59      => x"ae", 
           w60      => x"1f", 
           w61      => x"bc", 
           w62      => x"9c", 
           w63      => x"7a", 
           w64      => x"f4", 
           d_out   => pca_d05_out, en_out  => open, sof_out => open );

PCA64_6_inst: PCA_64 
  generic map(
           mult_sum => mult_sum,
           N        => CL_W,
           M        => PCAweightW,
           in_row   => in_row,
           in_col   => in_col
           )
  port map (
           clk       => clk    ,
           rst       => rst    ,
d01_in    => d01_out, d02_in    => d02_out, d03_in    => d03_out, d04_in    => d04_out, d05_in    => d05_out, d06_in    => d06_out, d07_in    => d07_out, d08_in    => d08_out, 
d09_in    => d09_out, d10_in    => d10_out, d11_in    => d11_out, d12_in    => d12_out, d13_in    => d13_out, d14_in    => d14_out, d15_in    => d15_out, d16_in    => d16_out, 
d17_in    => d17_out, d18_in    => d18_out, d19_in    => d19_out, d20_in    => d20_out, d21_in    => d21_out, d22_in    => d22_out, d23_in    => d23_out, d24_in    => d24_out, 
d25_in    => d25_out, d26_in    => d26_out, d27_in    => d27_out, d28_in    => d28_out, d29_in    => d29_out, d30_in    => d30_out, d31_in    => d31_out, d32_in    => d32_out, 
d33_in    => d33_out, d34_in    => d34_out, d35_in    => d35_out, d36_in    => d36_out, d37_in    => d37_out, d38_in    => d38_out, d39_in    => d39_out, d40_in    => d40_out, 
d41_in    => d41_out, d42_in    => d42_out, d43_in    => d43_out, d44_in    => d44_out, d45_in    => d45_out, d46_in    => d46_out, d47_in    => d47_out, d48_in    => d48_out, 
d49_in    => d49_out, d50_in    => d50_out, d51_in    => d51_out, d52_in    => d52_out, d53_in    => d53_out, d54_in    => d54_out, d55_in    => d55_out, d56_in    => d56_out,
d57_in    => d57_out, d58_in    => d58_out, d59_in    => d59_out, d60_in    => d60_out, d61_in    => d61_out, d62_in    => d62_out, d63_in    => d63_out, d64_in    => d64_out, 
           en_in     => '0',
           sof_in    => '0',

           w01      => x"be", 
           w02      => x"45", 
           w03      => x"e8", 
           w04      => x"c7", 
           w05      => x"fc", 
           w06      => x"25", 
           w07      => x"94", 
           w08      => x"52", 
           w09      => x"42", 
           w10      => x"c8", 
           w11      => x"85", 
           w12      => x"1c", 
           w13      => x"56", 
           w14      => x"1c", 
           w15      => x"b0", 
           w16      => x"31", 
           w17      => x"cf", 
           w18      => x"a3", 
           w19      => x"8a", 
           w20      => x"c8", 
           w21      => x"f7", 
           w22      => x"8d", 
           w23      => x"6d", 
           w24      => x"9a", 
           w25      => x"c8", 
           w26      => x"41", 
           w27      => x"c9", 
           w28      => x"cb", 
           w29      => x"71", 
           w30      => x"6e", 
           w31      => x"94", 
           w32      => x"4f", 
           w33      => x"42", 
           w34      => x"61", 
           w35      => x"bd", 
           w36      => x"27", 
           w37      => x"b0", 
           w38      => x"50", 
           w39      => x"34", 
           w40      => x"70", 
           w41      => x"d5", 
           w42      => x"57", 
           w43      => x"c6", 
           w44      => x"26", 
           w45      => x"d3", 
           w46      => x"0d", 
           w47      => x"3a", 
           w48      => x"41", 
           w49      => x"dd", 
           w50      => x"1e", 
           w51      => x"64", 
           w52      => x"4b", 
           w53      => x"6e", 
           w54      => x"d2", 
           w55      => x"4e", 
           w56      => x"66", 
           w57      => x"66", 
           w58      => x"b6", 
           w59      => x"87", 
           w60      => x"c8", 
           w61      => x"a3", 
           w62      => x"e6", 
           w63      => x"22", 
           w64      => x"23", 
           d_out   => pca_d06_out, en_out  => open, sof_out => open );

PCA64_7_inst: PCA_64 
  generic map(
           mult_sum => mult_sum,
           N        => CL_W,
           M        => PCAweightW,
           in_row   => in_row,
           in_col   => in_col
           )
  port map (
           clk       => clk    ,
           rst       => rst    ,
d01_in    => d01_out, d02_in    => d02_out, d03_in    => d03_out, d04_in    => d04_out, d05_in    => d05_out, d06_in    => d06_out, d07_in    => d07_out, d08_in    => d08_out, 
d09_in    => d09_out, d10_in    => d10_out, d11_in    => d11_out, d12_in    => d12_out, d13_in    => d13_out, d14_in    => d14_out, d15_in    => d15_out, d16_in    => d16_out, 
d17_in    => d17_out, d18_in    => d18_out, d19_in    => d19_out, d20_in    => d20_out, d21_in    => d21_out, d22_in    => d22_out, d23_in    => d23_out, d24_in    => d24_out, 
d25_in    => d25_out, d26_in    => d26_out, d27_in    => d27_out, d28_in    => d28_out, d29_in    => d29_out, d30_in    => d30_out, d31_in    => d31_out, d32_in    => d32_out, 
d33_in    => d33_out, d34_in    => d34_out, d35_in    => d35_out, d36_in    => d36_out, d37_in    => d37_out, d38_in    => d38_out, d39_in    => d39_out, d40_in    => d40_out, 
d41_in    => d41_out, d42_in    => d42_out, d43_in    => d43_out, d44_in    => d44_out, d45_in    => d45_out, d46_in    => d46_out, d47_in    => d47_out, d48_in    => d48_out, 
d49_in    => d49_out, d50_in    => d50_out, d51_in    => d51_out, d52_in    => d52_out, d53_in    => d53_out, d54_in    => d54_out, d55_in    => d55_out, d56_in    => d56_out,
d57_in    => d57_out, d58_in    => d58_out, d59_in    => d59_out, d60_in    => d60_out, d61_in    => d61_out, d62_in    => d62_out, d63_in    => d63_out, d64_in    => d64_out, 
           en_in     => '0',
           sof_in    => '0',

           w01      => x"d2", 
           w02      => x"8b", 
           w03      => x"33", 
           w04      => x"5d", 
           w05      => x"41", 
           w06      => x"3e", 
           w07      => x"d7", 
           w08      => x"e3", 
           w09      => x"0f", 
           w10      => x"27", 
           w11      => x"23", 
           w12      => x"9b", 
           w13      => x"32", 
           w14      => x"b3", 
           w15      => x"8b", 
           w16      => x"5c", 
           w17      => x"68", 
           w18      => x"b0", 
           w19      => x"e9", 
           w20      => x"d8", 
           w21      => x"58", 
           w22      => x"0a", 
           w23      => x"98", 
           w24      => x"4f", 
           w25      => x"b8", 
           w26      => x"46", 
           w27      => x"12", 
           w28      => x"ba", 
           w29      => x"b8", 
           w30      => x"4b", 
           w31      => x"c0", 
           w32      => x"10", 
           w33      => x"fc", 
           w34      => x"2b", 
           w35      => x"b1", 
           w36      => x"83", 
           w37      => x"22", 
           w38      => x"d6", 
           w39      => x"6c", 
           w40      => x"cd", 
           w41      => x"14", 
           w42      => x"d4", 
           w43      => x"6b", 
           w44      => x"73", 
           w45      => x"c0", 
           w46      => x"87", 
           w47      => x"b5", 
           w48      => x"b4", 
           w49      => x"fc", 
           w50      => x"35", 
           w51      => x"ec", 
           w52      => x"11", 
           w53      => x"a7", 
           w54      => x"db", 
           w55      => x"5a", 
           w56      => x"74", 
           w57      => x"9e", 
           w58      => x"d9", 
           w59      => x"ed", 
           w60      => x"51", 
           w61      => x"72", 
           w62      => x"67", 
           w63      => x"8e", 
           w64      => x"ef", 
           d_out   => pca_d07_out, en_out  => open, sof_out => open );

PCA64_8_inst: PCA_64 
  generic map(
           mult_sum => mult_sum,
           N        => CL_W,
           M        => PCAweightW,
           in_row   => in_row,
           in_col   => in_col
           )
  port map (
           clk       => clk    ,
           rst       => rst    ,
d01_in    => d01_out, d02_in    => d02_out, d03_in    => d03_out, d04_in    => d04_out, d05_in    => d05_out, d06_in    => d06_out, d07_in    => d07_out, d08_in    => d08_out, 
d09_in    => d09_out, d10_in    => d10_out, d11_in    => d11_out, d12_in    => d12_out, d13_in    => d13_out, d14_in    => d14_out, d15_in    => d15_out, d16_in    => d16_out, 
d17_in    => d17_out, d18_in    => d18_out, d19_in    => d19_out, d20_in    => d20_out, d21_in    => d21_out, d22_in    => d22_out, d23_in    => d23_out, d24_in    => d24_out, 
d25_in    => d25_out, d26_in    => d26_out, d27_in    => d27_out, d28_in    => d28_out, d29_in    => d29_out, d30_in    => d30_out, d31_in    => d31_out, d32_in    => d32_out, 
d33_in    => d33_out, d34_in    => d34_out, d35_in    => d35_out, d36_in    => d36_out, d37_in    => d37_out, d38_in    => d38_out, d39_in    => d39_out, d40_in    => d40_out, 
d41_in    => d41_out, d42_in    => d42_out, d43_in    => d43_out, d44_in    => d44_out, d45_in    => d45_out, d46_in    => d46_out, d47_in    => d47_out, d48_in    => d48_out, 
d49_in    => d49_out, d50_in    => d50_out, d51_in    => d51_out, d52_in    => d52_out, d53_in    => d53_out, d54_in    => d54_out, d55_in    => d55_out, d56_in    => d56_out,
d57_in    => d57_out, d58_in    => d58_out, d59_in    => d59_out, d60_in    => d60_out, d61_in    => d61_out, d62_in    => d62_out, d63_in    => d63_out, d64_in    => d64_out, 
           en_in     => '0',
           sof_in    => '0',

           w01      => x"27", 
           w02      => x"b0", 
           w03      => x"15", 
           w04      => x"ee", 
           w05      => x"07", 
           w06      => x"fa", 
           w07      => x"cc", 
           w08      => x"22", 
           w09      => x"b3", 
           w10      => x"dc", 
           w11      => x"76", 
           w12      => x"cc", 
           w13      => x"67", 
           w14      => x"e2", 
           w15      => x"b7", 
           w16      => x"5b", 
           w17      => x"26", 
           w18      => x"88", 
           w19      => x"54", 
           w20      => x"c4", 
           w21      => x"92", 
           w22      => x"19", 
           w23      => x"79", 
           w24      => x"53", 
           w25      => x"50", 
           w26      => x"16", 
           w27      => x"23", 
           w28      => x"55", 
           w29      => x"aa", 
           w30      => x"2d", 
           w31      => x"64", 
           w32      => x"b9", 
           w33      => x"ff", 
           w34      => x"8b", 
           w35      => x"5d", 
           w36      => x"50", 
           w37      => x"fa", 
           w38      => x"5e", 
           w39      => x"61", 
           w40      => x"cb", 
           w41      => x"b7", 
           w42      => x"8e", 
           w43      => x"63", 
           w44      => x"f9", 
           w45      => x"10", 
           w46      => x"3a", 
           w47      => x"db", 
           w48      => x"70", 
           w49      => x"c2", 
           w50      => x"f5", 
           w51      => x"77", 
           w52      => x"43", 
           w53      => x"26", 
           w54      => x"76", 
           w55      => x"d7", 
           w56      => x"e8", 
           w57      => x"8b", 
           w58      => x"b6", 
           w59      => x"b8", 
           w60      => x"13", 
           w61      => x"89", 
           w62      => x"11", 
           w63      => x"55", 
           w64      => x"a4", 
           d_out   => pca_d08_out, en_out  => open, sof_out => open );

PCA64_9_inst: PCA_64 
  generic map(
           mult_sum => mult_sum,
           N        => CL_W,
           M        => PCAweightW,
           in_row   => in_row,
           in_col   => in_col
           )
  port map (
           clk       => clk    ,
           rst       => rst    ,
d01_in    => d01_out, d02_in    => d02_out, d03_in    => d03_out, d04_in    => d04_out, d05_in    => d05_out, d06_in    => d06_out, d07_in    => d07_out, d08_in    => d08_out, 
d09_in    => d09_out, d10_in    => d10_out, d11_in    => d11_out, d12_in    => d12_out, d13_in    => d13_out, d14_in    => d14_out, d15_in    => d15_out, d16_in    => d16_out, 
d17_in    => d17_out, d18_in    => d18_out, d19_in    => d19_out, d20_in    => d20_out, d21_in    => d21_out, d22_in    => d22_out, d23_in    => d23_out, d24_in    => d24_out, 
d25_in    => d25_out, d26_in    => d26_out, d27_in    => d27_out, d28_in    => d28_out, d29_in    => d29_out, d30_in    => d30_out, d31_in    => d31_out, d32_in    => d32_out, 
d33_in    => d33_out, d34_in    => d34_out, d35_in    => d35_out, d36_in    => d36_out, d37_in    => d37_out, d38_in    => d38_out, d39_in    => d39_out, d40_in    => d40_out, 
d41_in    => d41_out, d42_in    => d42_out, d43_in    => d43_out, d44_in    => d44_out, d45_in    => d45_out, d46_in    => d46_out, d47_in    => d47_out, d48_in    => d48_out, 
d49_in    => d49_out, d50_in    => d50_out, d51_in    => d51_out, d52_in    => d52_out, d53_in    => d53_out, d54_in    => d54_out, d55_in    => d55_out, d56_in    => d56_out,
d57_in    => d57_out, d58_in    => d58_out, d59_in    => d59_out, d60_in    => d60_out, d61_in    => d61_out, d62_in    => d62_out, d63_in    => d63_out, d64_in    => d64_out, 
           en_in     => '0',
           sof_in    => '0',

           w01      => x"85", 
           w02      => x"28", 
           w03      => x"47", 
           w04      => x"0a", 
           w05      => x"4c", 
           w06      => x"ee", 
           w07      => x"6f", 
           w08      => x"ae", 
           w09      => x"4b", 
           w10      => x"08", 
           w11      => x"0d", 
           w12      => x"9c", 
           w13      => x"60", 
           w14      => x"1d", 
           w15      => x"ed", 
           w16      => x"1a", 
           w17      => x"a5", 
           w18      => x"61", 
           w19      => x"7c", 
           w20      => x"a3", 
           w21      => x"92", 
           w22      => x"3b", 
           w23      => x"df", 
           w24      => x"4a", 
           w25      => x"ae", 
           w26      => x"cb", 
           w27      => x"8c", 
           w28      => x"85", 
           w29      => x"32", 
           w30      => x"14", 
           w31      => x"df", 
           w32      => x"b5", 
           w33      => x"ad", 
           w34      => x"66", 
           w35      => x"08", 
           w36      => x"36", 
           w37      => x"40", 
           w38      => x"0d", 
           w39      => x"e9", 
           w40      => x"5b", 
           w41      => x"3e", 
           w42      => x"dd", 
           w43      => x"55", 
           w44      => x"24", 
           w45      => x"a4", 
           w46      => x"e8", 
           w47      => x"a9", 
           w48      => x"b2", 
           w49      => x"ed", 
           w50      => x"08", 
           w51      => x"8c", 
           w52      => x"10", 
           w53      => x"28", 
           w54      => x"65", 
           w55      => x"0b", 
           w56      => x"52", 
           w57      => x"2b", 
           w58      => x"1a", 
           w59      => x"96", 
           w60      => x"f8", 
           w61      => x"89", 
           w62      => x"e4", 
           w63      => x"c6", 
           w64      => x"94", 
           d_out   => pca_d09_out, en_out  => open, sof_out => open );

PCA64_10_inst: PCA_64 
  generic map(
           mult_sum => mult_sum,
           N        => CL_W,
           M        => PCAweightW,
           in_row   => in_row,
           in_col   => in_col
           )
  port map (
           clk       => clk    ,
           rst       => rst    ,
d01_in    => d01_out, d02_in    => d02_out, d03_in    => d03_out, d04_in    => d04_out, d05_in    => d05_out, d06_in    => d06_out, d07_in    => d07_out, d08_in    => d08_out, 
d09_in    => d09_out, d10_in    => d10_out, d11_in    => d11_out, d12_in    => d12_out, d13_in    => d13_out, d14_in    => d14_out, d15_in    => d15_out, d16_in    => d16_out, 
d17_in    => d17_out, d18_in    => d18_out, d19_in    => d19_out, d20_in    => d20_out, d21_in    => d21_out, d22_in    => d22_out, d23_in    => d23_out, d24_in    => d24_out, 
d25_in    => d25_out, d26_in    => d26_out, d27_in    => d27_out, d28_in    => d28_out, d29_in    => d29_out, d30_in    => d30_out, d31_in    => d31_out, d32_in    => d32_out, 
d33_in    => d33_out, d34_in    => d34_out, d35_in    => d35_out, d36_in    => d36_out, d37_in    => d37_out, d38_in    => d38_out, d39_in    => d39_out, d40_in    => d40_out, 
d41_in    => d41_out, d42_in    => d42_out, d43_in    => d43_out, d44_in    => d44_out, d45_in    => d45_out, d46_in    => d46_out, d47_in    => d47_out, d48_in    => d48_out, 
d49_in    => d49_out, d50_in    => d50_out, d51_in    => d51_out, d52_in    => d52_out, d53_in    => d53_out, d54_in    => d54_out, d55_in    => d55_out, d56_in    => d56_out,
d57_in    => d57_out, d58_in    => d58_out, d59_in    => d59_out, d60_in    => d60_out, d61_in    => d61_out, d62_in    => d62_out, d63_in    => d63_out, d64_in    => d64_out, 
           en_in     => '0',
           sof_in    => '0',

           w01      => x"34", 
           w02      => x"ab", 
           w03      => x"73", 
           w04      => x"43", 
           w05      => x"63", 
           w06      => x"b3", 
           w07      => x"15", 
           w08      => x"d9", 
           w09      => x"c7", 
           w10      => x"3c", 
           w11      => x"f9", 
           w12      => x"0b", 
           w13      => x"9a", 
           w14      => x"81", 
           w15      => x"48", 
           w16      => x"ea", 
           w17      => x"4a", 
           w18      => x"cc", 
           w19      => x"ba", 
           w20      => x"10", 
           w21      => x"0e", 
           w22      => x"64", 
           w23      => x"89", 
           w24      => x"7f", 
           w25      => x"64", 
           w26      => x"16", 
           w27      => x"91", 
           w28      => x"d8", 
           w29      => x"f1", 
           w30      => x"1b", 
           w31      => x"ec", 
           w32      => x"47", 
           w33      => x"44", 
           w34      => x"b2", 
           w35      => x"53", 
           w36      => x"6e", 
           w37      => x"11", 
           w38      => x"fa", 
           w39      => x"af", 
           w40      => x"f7", 
           w41      => x"ce", 
           w42      => x"43", 
           w43      => x"e2", 
           w44      => x"25", 
           w45      => x"2c", 
           w46      => x"1e", 
           w47      => x"53", 
           w48      => x"2a", 
           w49      => x"08", 
           w50      => x"f0", 
           w51      => x"ea", 
           w52      => x"5a", 
           w53      => x"c6", 
           w54      => x"6a", 
           w55      => x"a9", 
           w56      => x"c5", 
           w57      => x"e4", 
           w58      => x"c2", 
           w59      => x"0d", 
           w60      => x"de", 
           w61      => x"aa", 
           w62      => x"7d", 
           w63      => x"3f", 
           w64      => x"5e", 
           d_out   => pca_d10_out, en_out  => open, sof_out => open );

PCA64_11_inst: PCA_64 
  generic map(
           mult_sum => mult_sum,
           N        => CL_W,
           M        => PCAweightW,
           in_row   => in_row,
           in_col   => in_col
           )
  port map (
           clk       => clk    ,
           rst       => rst    ,
d01_in    => d01_out, d02_in    => d02_out, d03_in    => d03_out, d04_in    => d04_out, d05_in    => d05_out, d06_in    => d06_out, d07_in    => d07_out, d08_in    => d08_out, 
d09_in    => d09_out, d10_in    => d10_out, d11_in    => d11_out, d12_in    => d12_out, d13_in    => d13_out, d14_in    => d14_out, d15_in    => d15_out, d16_in    => d16_out, 
d17_in    => d17_out, d18_in    => d18_out, d19_in    => d19_out, d20_in    => d20_out, d21_in    => d21_out, d22_in    => d22_out, d23_in    => d23_out, d24_in    => d24_out, 
d25_in    => d25_out, d26_in    => d26_out, d27_in    => d27_out, d28_in    => d28_out, d29_in    => d29_out, d30_in    => d30_out, d31_in    => d31_out, d32_in    => d32_out, 
d33_in    => d33_out, d34_in    => d34_out, d35_in    => d35_out, d36_in    => d36_out, d37_in    => d37_out, d38_in    => d38_out, d39_in    => d39_out, d40_in    => d40_out, 
d41_in    => d41_out, d42_in    => d42_out, d43_in    => d43_out, d44_in    => d44_out, d45_in    => d45_out, d46_in    => d46_out, d47_in    => d47_out, d48_in    => d48_out, 
d49_in    => d49_out, d50_in    => d50_out, d51_in    => d51_out, d52_in    => d52_out, d53_in    => d53_out, d54_in    => d54_out, d55_in    => d55_out, d56_in    => d56_out,
d57_in    => d57_out, d58_in    => d58_out, d59_in    => d59_out, d60_in    => d60_out, d61_in    => d61_out, d62_in    => d62_out, d63_in    => d63_out, d64_in    => d64_out, 
           en_in     => '0',
           sof_in    => '0',

           w01      => x"4f", 
           w02      => x"8d", 
           w03      => x"c9", 
           w04      => x"9b", 
           w05      => x"3b", 
           w06      => x"39", 
           w07      => x"12", 
           w08      => x"f8", 
           w09      => x"c1", 
           w10      => x"c2", 
           w11      => x"81", 
           w12      => x"4e", 
           w13      => x"b7", 
           w14      => x"1f", 
           w15      => x"8e", 
           w16      => x"89", 
           w17      => x"c9", 
           w18      => x"68", 
           w19      => x"6b", 
           w20      => x"4c", 
           w21      => x"f4", 
           w22      => x"d0", 
           w23      => x"35", 
           w24      => x"3e", 
           w25      => x"dd", 
           w26      => x"f9", 
           w27      => x"88", 
           w28      => x"50", 
           w29      => x"0d", 
           w30      => x"26", 
           w31      => x"87", 
           w32      => x"7e", 
           w33      => x"c6", 
           w34      => x"a2", 
           w35      => x"41", 
           w36      => x"3e", 
           w37      => x"5c", 
           w38      => x"fc", 
           w39      => x"b2", 
           w40      => x"3e", 
           w41      => x"86", 
           w42      => x"bb", 
           w43      => x"d7", 
           w44      => x"24", 
           w45      => x"c6", 
           w46      => x"f4", 
           w47      => x"cf", 
           w48      => x"09", 
           w49      => x"a3", 
           w50      => x"1b", 
           w51      => x"94", 
           w52      => x"57", 
           w53      => x"92", 
           w54      => x"1a", 
           w55      => x"d2", 
           w56      => x"2b", 
           w57      => x"5a", 
           w58      => x"ae", 
           w59      => x"bb", 
           w60      => x"30", 
           w61      => x"dc", 
           w62      => x"fb", 
           w63      => x"d4", 
           w64      => x"86", 
           d_out   => pca_d11_out, en_out  => open, sof_out => open );

PCA64_12_inst: PCA_64 
  generic map(
           mult_sum => mult_sum,
           N        => CL_W,
           M        => PCAweightW,
           in_row   => in_row,
           in_col   => in_col
           )
  port map (
           clk       => clk    ,
           rst       => rst    ,
d01_in    => d01_out, d02_in    => d02_out, d03_in    => d03_out, d04_in    => d04_out, d05_in    => d05_out, d06_in    => d06_out, d07_in    => d07_out, d08_in    => d08_out, 
d09_in    => d09_out, d10_in    => d10_out, d11_in    => d11_out, d12_in    => d12_out, d13_in    => d13_out, d14_in    => d14_out, d15_in    => d15_out, d16_in    => d16_out, 
d17_in    => d17_out, d18_in    => d18_out, d19_in    => d19_out, d20_in    => d20_out, d21_in    => d21_out, d22_in    => d22_out, d23_in    => d23_out, d24_in    => d24_out, 
d25_in    => d25_out, d26_in    => d26_out, d27_in    => d27_out, d28_in    => d28_out, d29_in    => d29_out, d30_in    => d30_out, d31_in    => d31_out, d32_in    => d32_out, 
d33_in    => d33_out, d34_in    => d34_out, d35_in    => d35_out, d36_in    => d36_out, d37_in    => d37_out, d38_in    => d38_out, d39_in    => d39_out, d40_in    => d40_out, 
d41_in    => d41_out, d42_in    => d42_out, d43_in    => d43_out, d44_in    => d44_out, d45_in    => d45_out, d46_in    => d46_out, d47_in    => d47_out, d48_in    => d48_out, 
d49_in    => d49_out, d50_in    => d50_out, d51_in    => d51_out, d52_in    => d52_out, d53_in    => d53_out, d54_in    => d54_out, d55_in    => d55_out, d56_in    => d56_out,
d57_in    => d57_out, d58_in    => d58_out, d59_in    => d59_out, d60_in    => d60_out, d61_in    => d61_out, d62_in    => d62_out, d63_in    => d63_out, d64_in    => d64_out, 
           en_in     => '0',
           sof_in    => '0',

           w01      => x"c5", 
           w02      => x"0d", 
           w03      => x"be", 
           w04      => x"40", 
           w05      => x"0c", 
           w06      => x"b6", 
           w07      => x"c1", 
           w08      => x"3b", 
           w09      => x"0e", 
           w10      => x"be", 
           w11      => x"bc", 
           w12      => x"8f", 
           w13      => x"76", 
           w14      => x"4f", 
           w15      => x"9f", 
           w16      => x"19", 
           w17      => x"98", 
           w18      => x"bf", 
           w19      => x"f8", 
           w20      => x"50", 
           w21      => x"5c", 
           w22      => x"a2", 
           w23      => x"5b", 
           w24      => x"42", 
           w25      => x"c4", 
           w26      => x"89", 
           w27      => x"ba", 
           w28      => x"7d", 
           w29      => x"84", 
           w30      => x"f2", 
           w31      => x"80", 
           w32      => x"18", 
           w33      => x"6f", 
           w34      => x"3e", 
           w35      => x"75", 
           w36      => x"c2", 
           w37      => x"90", 
           w38      => x"10", 
           w39      => x"f6", 
           w40      => x"b7", 
           w41      => x"b1", 
           w42      => x"7c", 
           w43      => x"b1", 
           w44      => x"6d", 
           w45      => x"d8", 
           w46      => x"f4", 
           w47      => x"63", 
           w48      => x"be", 
           w49      => x"1a", 
           w50      => x"4b", 
           w51      => x"a8", 
           w52      => x"bd", 
           w53      => x"9d", 
           w54      => x"bb", 
           w55      => x"bd", 
           w56      => x"49", 
           w57      => x"32", 
           w58      => x"25", 
           w59      => x"3d", 
           w60      => x"d2", 
           w61      => x"f0", 
           w62      => x"ce", 
           w63      => x"d8", 
           w64      => x"a5", 
           d_out   => pca_d12_out, en_out  => open, sof_out => open );

PCA64_13_inst: PCA_64 
  generic map(
           mult_sum => mult_sum,
           N        => CL_W,
           M        => PCAweightW,
           in_row   => in_row,
           in_col   => in_col
           )
  port map (
           clk       => clk    ,
           rst       => rst    ,
d01_in    => d01_out, d02_in    => d02_out, d03_in    => d03_out, d04_in    => d04_out, d05_in    => d05_out, d06_in    => d06_out, d07_in    => d07_out, d08_in    => d08_out, 
d09_in    => d09_out, d10_in    => d10_out, d11_in    => d11_out, d12_in    => d12_out, d13_in    => d13_out, d14_in    => d14_out, d15_in    => d15_out, d16_in    => d16_out, 
d17_in    => d17_out, d18_in    => d18_out, d19_in    => d19_out, d20_in    => d20_out, d21_in    => d21_out, d22_in    => d22_out, d23_in    => d23_out, d24_in    => d24_out, 
d25_in    => d25_out, d26_in    => d26_out, d27_in    => d27_out, d28_in    => d28_out, d29_in    => d29_out, d30_in    => d30_out, d31_in    => d31_out, d32_in    => d32_out, 
d33_in    => d33_out, d34_in    => d34_out, d35_in    => d35_out, d36_in    => d36_out, d37_in    => d37_out, d38_in    => d38_out, d39_in    => d39_out, d40_in    => d40_out, 
d41_in    => d41_out, d42_in    => d42_out, d43_in    => d43_out, d44_in    => d44_out, d45_in    => d45_out, d46_in    => d46_out, d47_in    => d47_out, d48_in    => d48_out, 
d49_in    => d49_out, d50_in    => d50_out, d51_in    => d51_out, d52_in    => d52_out, d53_in    => d53_out, d54_in    => d54_out, d55_in    => d55_out, d56_in    => d56_out,
d57_in    => d57_out, d58_in    => d58_out, d59_in    => d59_out, d60_in    => d60_out, d61_in    => d61_out, d62_in    => d62_out, d63_in    => d63_out, d64_in    => d64_out, 
           en_in     => '0',
           sof_in    => '0',

           w01      => x"dc", 
           w02      => x"d9", 
           w03      => x"36", 
           w04      => x"6c", 
           w05      => x"07", 
           w06      => x"c2", 
           w07      => x"38", 
           w08      => x"ac", 
           w09      => x"61", 
           w10      => x"45", 
           w11      => x"ca", 
           w12      => x"49", 
           w13      => x"78", 
           w14      => x"fb", 
           w15      => x"d1", 
           w16      => x"26", 
           w17      => x"91", 
           w18      => x"c0", 
           w19      => x"ea", 
           w20      => x"42", 
           w21      => x"61", 
           w22      => x"e9", 
           w23      => x"a6", 
           w24      => x"6b", 
           w25      => x"83", 
           w26      => x"49", 
           w27      => x"6a", 
           w28      => x"0d", 
           w29      => x"af", 
           w30      => x"7c", 
           w31      => x"9e", 
           w32      => x"5b", 
           w33      => x"9f", 
           w34      => x"82", 
           w35      => x"72", 
           w36      => x"3c", 
           w37      => x"a3", 
           w38      => x"b0", 
           w39      => x"cd", 
           w40      => x"83", 
           w41      => x"1e", 
           w42      => x"29", 
           w43      => x"15", 
           w44      => x"9d", 
           w45      => x"e0", 
           w46      => x"cb", 
           w47      => x"69", 
           w48      => x"21", 
           w49      => x"c7", 
           w50      => x"76", 
           w51      => x"94", 
           w52      => x"e4", 
           w53      => x"bc", 
           w54      => x"28", 
           w55      => x"55", 
           w56      => x"49", 
           w57      => x"b4", 
           w58      => x"30", 
           w59      => x"53", 
           w60      => x"2a", 
           w61      => x"c7", 
           w62      => x"a9", 
           w63      => x"7c", 
           w64      => x"2a", 
           d_out   => pca_d13_out, en_out  => open, sof_out => open );

PCA64_14_inst: PCA_64 
  generic map(
           mult_sum => mult_sum,
           N        => CL_W,
           M        => PCAweightW,
           in_row   => in_row,
           in_col   => in_col
           )
  port map (
           clk       => clk    ,
           rst       => rst    ,
d01_in    => d01_out, d02_in    => d02_out, d03_in    => d03_out, d04_in    => d04_out, d05_in    => d05_out, d06_in    => d06_out, d07_in    => d07_out, d08_in    => d08_out, 
d09_in    => d09_out, d10_in    => d10_out, d11_in    => d11_out, d12_in    => d12_out, d13_in    => d13_out, d14_in    => d14_out, d15_in    => d15_out, d16_in    => d16_out, 
d17_in    => d17_out, d18_in    => d18_out, d19_in    => d19_out, d20_in    => d20_out, d21_in    => d21_out, d22_in    => d22_out, d23_in    => d23_out, d24_in    => d24_out, 
d25_in    => d25_out, d26_in    => d26_out, d27_in    => d27_out, d28_in    => d28_out, d29_in    => d29_out, d30_in    => d30_out, d31_in    => d31_out, d32_in    => d32_out, 
d33_in    => d33_out, d34_in    => d34_out, d35_in    => d35_out, d36_in    => d36_out, d37_in    => d37_out, d38_in    => d38_out, d39_in    => d39_out, d40_in    => d40_out, 
d41_in    => d41_out, d42_in    => d42_out, d43_in    => d43_out, d44_in    => d44_out, d45_in    => d45_out, d46_in    => d46_out, d47_in    => d47_out, d48_in    => d48_out, 
d49_in    => d49_out, d50_in    => d50_out, d51_in    => d51_out, d52_in    => d52_out, d53_in    => d53_out, d54_in    => d54_out, d55_in    => d55_out, d56_in    => d56_out,
d57_in    => d57_out, d58_in    => d58_out, d59_in    => d59_out, d60_in    => d60_out, d61_in    => d61_out, d62_in    => d62_out, d63_in    => d63_out, d64_in    => d64_out, 
           en_in     => '0',
           sof_in    => '0',

           w01      => x"50", 
           w02      => x"fc", 
           w03      => x"d0", 
           w04      => x"3d", 
           w05      => x"89", 
           w06      => x"f0", 
           w07      => x"c2", 
           w08      => x"a2", 
           w09      => x"7d", 
           w10      => x"88", 
           w11      => x"17", 
           w12      => x"a0", 
           w13      => x"42", 
           w14      => x"94", 
           w15      => x"b0", 
           w16      => x"ef", 
           w17      => x"df", 
           w18      => x"b6", 
           w19      => x"5a", 
           w20      => x"30", 
           w21      => x"db", 
           w22      => x"1a", 
           w23      => x"a9", 
           w24      => x"58", 
           w25      => x"e7", 
           w26      => x"e5", 
           w27      => x"d5", 
           w28      => x"c6", 
           w29      => x"41", 
           w30      => x"70", 
           w31      => x"ab", 
           w32      => x"07", 
           w33      => x"a6", 
           w34      => x"d6", 
           w35      => x"20", 
           w36      => x"e6", 
           w37      => x"b8", 
           w38      => x"c3", 
           w39      => x"12", 
           w40      => x"5a", 
           w41      => x"1d", 
           w42      => x"cd", 
           w43      => x"8a", 
           w44      => x"32", 
           w45      => x"80", 
           w46      => x"f8", 
           w47      => x"be", 
           w48      => x"64", 
           w49      => x"a3", 
           w50      => x"cb", 
           w51      => x"1e", 
           w52      => x"21", 
           w53      => x"6e", 
           w54      => x"19", 
           w55      => x"08", 
           w56      => x"12", 
           w57      => x"1c", 
           w58      => x"b8", 
           w59      => x"d7", 
           w60      => x"62", 
           w61      => x"3f", 
           w62      => x"54", 
           w63      => x"9c", 
           w64      => x"2f", 
           d_out   => pca_d14_out, en_out  => open, sof_out => open );

PCA64_15_inst: PCA_64 
  generic map(
           mult_sum => mult_sum,
           N        => CL_W,
           M        => PCAweightW,
           in_row   => in_row,
           in_col   => in_col
           )
  port map (
           clk       => clk    ,
           rst       => rst    ,
d01_in    => d01_out, d02_in    => d02_out, d03_in    => d03_out, d04_in    => d04_out, d05_in    => d05_out, d06_in    => d06_out, d07_in    => d07_out, d08_in    => d08_out, 
d09_in    => d09_out, d10_in    => d10_out, d11_in    => d11_out, d12_in    => d12_out, d13_in    => d13_out, d14_in    => d14_out, d15_in    => d15_out, d16_in    => d16_out, 
d17_in    => d17_out, d18_in    => d18_out, d19_in    => d19_out, d20_in    => d20_out, d21_in    => d21_out, d22_in    => d22_out, d23_in    => d23_out, d24_in    => d24_out, 
d25_in    => d25_out, d26_in    => d26_out, d27_in    => d27_out, d28_in    => d28_out, d29_in    => d29_out, d30_in    => d30_out, d31_in    => d31_out, d32_in    => d32_out, 
d33_in    => d33_out, d34_in    => d34_out, d35_in    => d35_out, d36_in    => d36_out, d37_in    => d37_out, d38_in    => d38_out, d39_in    => d39_out, d40_in    => d40_out, 
d41_in    => d41_out, d42_in    => d42_out, d43_in    => d43_out, d44_in    => d44_out, d45_in    => d45_out, d46_in    => d46_out, d47_in    => d47_out, d48_in    => d48_out, 
d49_in    => d49_out, d50_in    => d50_out, d51_in    => d51_out, d52_in    => d52_out, d53_in    => d53_out, d54_in    => d54_out, d55_in    => d55_out, d56_in    => d56_out,
d57_in    => d57_out, d58_in    => d58_out, d59_in    => d59_out, d60_in    => d60_out, d61_in    => d61_out, d62_in    => d62_out, d63_in    => d63_out, d64_in    => d64_out, 
           en_in     => '0',
           sof_in    => '0',

           w01      => x"ef", 
           w02      => x"90", 
           w03      => x"0c", 
           w04      => x"c0", 
           w05      => x"6d", 
           w06      => x"de", 
           w07      => x"59", 
           w08      => x"1b", 
           w09      => x"86", 
           w10      => x"92", 
           w11      => x"64", 
           w12      => x"ba", 
           w13      => x"28", 
           w14      => x"8e", 
           w15      => x"11", 
           w16      => x"36", 
           w17      => x"ec", 
           w18      => x"ff", 
           w19      => x"47", 
           w20      => x"ce", 
           w21      => x"4d", 
           w22      => x"1e", 
           w23      => x"6e", 
           w24      => x"43", 
           w25      => x"84", 
           w26      => x"3f", 
           w27      => x"0c", 
           w28      => x"18", 
           w29      => x"c2", 
           w30      => x"ac", 
           w31      => x"ee", 
           w32      => x"f5", 
           w33      => x"ec", 
           w34      => x"7d", 
           w35      => x"1b", 
           w36      => x"a1", 
           w37      => x"82", 
           w38      => x"92", 
           w39      => x"3c", 
           w40      => x"32", 
           w41      => x"9d", 
           w42      => x"e3", 
           w43      => x"c9", 
           w44      => x"0c", 
           w45      => x"c3", 
           w46      => x"32", 
           w47      => x"a8", 
           w48      => x"98", 
           w49      => x"cb", 
           w50      => x"d4", 
           w51      => x"b3", 
           w52      => x"fd", 
           w53      => x"95", 
           w54      => x"62", 
           w55      => x"6a", 
           w56      => x"ad", 
           w57      => x"51", 
           w58      => x"6c", 
           w59      => x"53", 
           w60      => x"b2", 
           w61      => x"c4", 
           w62      => x"fa", 
           w63      => x"b4", 
           w64      => x"f4", 
           d_out   => pca_d15_out, en_out  => open, sof_out => open );

PCA64_16_inst: PCA_64 
  generic map(
           mult_sum => mult_sum,
           N        => CL_W,
           M        => PCAweightW,
           in_row   => in_row,
           in_col   => in_col
           )
  port map (
           clk       => clk    ,
           rst       => rst    ,
d01_in    => d01_out, d02_in    => d02_out, d03_in    => d03_out, d04_in    => d04_out, d05_in    => d05_out, d06_in    => d06_out, d07_in    => d07_out, d08_in    => d08_out, 
d09_in    => d09_out, d10_in    => d10_out, d11_in    => d11_out, d12_in    => d12_out, d13_in    => d13_out, d14_in    => d14_out, d15_in    => d15_out, d16_in    => d16_out, 
d17_in    => d17_out, d18_in    => d18_out, d19_in    => d19_out, d20_in    => d20_out, d21_in    => d21_out, d22_in    => d22_out, d23_in    => d23_out, d24_in    => d24_out, 
d25_in    => d25_out, d26_in    => d26_out, d27_in    => d27_out, d28_in    => d28_out, d29_in    => d29_out, d30_in    => d30_out, d31_in    => d31_out, d32_in    => d32_out, 
d33_in    => d33_out, d34_in    => d34_out, d35_in    => d35_out, d36_in    => d36_out, d37_in    => d37_out, d38_in    => d38_out, d39_in    => d39_out, d40_in    => d40_out, 
d41_in    => d41_out, d42_in    => d42_out, d43_in    => d43_out, d44_in    => d44_out, d45_in    => d45_out, d46_in    => d46_out, d47_in    => d47_out, d48_in    => d48_out, 
d49_in    => d49_out, d50_in    => d50_out, d51_in    => d51_out, d52_in    => d52_out, d53_in    => d53_out, d54_in    => d54_out, d55_in    => d55_out, d56_in    => d56_out,
d57_in    => d57_out, d58_in    => d58_out, d59_in    => d59_out, d60_in    => d60_out, d61_in    => d61_out, d62_in    => d62_out, d63_in    => d63_out, d64_in    => d64_out, 
           en_in     => '0',
           sof_in    => '0',

           w01      => x"9b", 
           w02      => x"23", 
           w03      => x"42", 
           w04      => x"19", 
           w05      => x"d2", 
           w06      => x"1b", 
           w07      => x"56", 
           w08      => x"93", 
           w09      => x"f4", 
           w10      => x"83", 
           w11      => x"32", 
           w12      => x"89", 
           w13      => x"31", 
           w14      => x"c2", 
           w15      => x"d4", 
           w16      => x"ba", 
           w17      => x"8a", 
           w18      => x"1d", 
           w19      => x"d9", 
           w20      => x"b8", 
           w21      => x"60", 
           w22      => x"66", 
           w23      => x"38", 
           w24      => x"12", 
           w25      => x"2f", 
           w26      => x"89", 
           w27      => x"bf", 
           w28      => x"18", 
           w29      => x"24", 
           w30      => x"9c", 
           w31      => x"f0", 
           w32      => x"b6", 
           w33      => x"7e", 
           w34      => x"55", 
           w35      => x"d0", 
           w36      => x"e6", 
           w37      => x"db", 
           w38      => x"cb", 
           w39      => x"fa", 
           w40      => x"4a", 
           w41      => x"57", 
           w42      => x"da", 
           w43      => x"52", 
           w44      => x"23", 
           w45      => x"ad", 
           w46      => x"f7", 
           w47      => x"b4", 
           w48      => x"4c", 
           w49      => x"ab", 
           w50      => x"43", 
           w51      => x"8d", 
           w52      => x"d1", 
           w53      => x"16", 
           w54      => x"cd", 
           w55      => x"51", 
           w56      => x"cc", 
           w57      => x"19", 
           w58      => x"3a", 
           w59      => x"3a", 
           w60      => x"c4", 
           w61      => x"53", 
           w62      => x"54", 
           w63      => x"81", 
           w64      => x"ac", 
           d_out   => pca_d16_out, en_out  => open, sof_out => open );

PCA64_17_inst: PCA_64 
  generic map(
           mult_sum => mult_sum,
           N        => CL_W,
           M        => PCAweightW,
           in_row   => in_row,
           in_col   => in_col
           )
  port map (
           clk       => clk    ,
           rst       => rst    ,
d01_in    => d01_out, d02_in    => d02_out, d03_in    => d03_out, d04_in    => d04_out, d05_in    => d05_out, d06_in    => d06_out, d07_in    => d07_out, d08_in    => d08_out, 
d09_in    => d09_out, d10_in    => d10_out, d11_in    => d11_out, d12_in    => d12_out, d13_in    => d13_out, d14_in    => d14_out, d15_in    => d15_out, d16_in    => d16_out, 
d17_in    => d17_out, d18_in    => d18_out, d19_in    => d19_out, d20_in    => d20_out, d21_in    => d21_out, d22_in    => d22_out, d23_in    => d23_out, d24_in    => d24_out, 
d25_in    => d25_out, d26_in    => d26_out, d27_in    => d27_out, d28_in    => d28_out, d29_in    => d29_out, d30_in    => d30_out, d31_in    => d31_out, d32_in    => d32_out, 
d33_in    => d33_out, d34_in    => d34_out, d35_in    => d35_out, d36_in    => d36_out, d37_in    => d37_out, d38_in    => d38_out, d39_in    => d39_out, d40_in    => d40_out, 
d41_in    => d41_out, d42_in    => d42_out, d43_in    => d43_out, d44_in    => d44_out, d45_in    => d45_out, d46_in    => d46_out, d47_in    => d47_out, d48_in    => d48_out, 
d49_in    => d49_out, d50_in    => d50_out, d51_in    => d51_out, d52_in    => d52_out, d53_in    => d53_out, d54_in    => d54_out, d55_in    => d55_out, d56_in    => d56_out,
d57_in    => d57_out, d58_in    => d58_out, d59_in    => d59_out, d60_in    => d60_out, d61_in    => d61_out, d62_in    => d62_out, d63_in    => d63_out, d64_in    => d64_out, 
           en_in     => '0',
           sof_in    => '0',

           w01      => x"15", 
           w02      => x"75", 
           w03      => x"9b", 
           w04      => x"68", 
           w05      => x"be", 
           w06      => x"d9", 
           w07      => x"a6", 
           w08      => x"16", 
           w09      => x"80", 
           w10      => x"f6", 
           w11      => x"43", 
           w12      => x"31", 
           w13      => x"3f", 
           w14      => x"f6", 
           w15      => x"35", 
           w16      => x"97", 
           w17      => x"19", 
           w18      => x"2c", 
           w19      => x"15", 
           w20      => x"59", 
           w21      => x"d4", 
           w22      => x"c4", 
           w23      => x"63", 
           w24      => x"20", 
           w25      => x"41", 
           w26      => x"17", 
           w27      => x"e7", 
           w28      => x"58", 
           w29      => x"23", 
           w30      => x"7c", 
           w31      => x"55", 
           w32      => x"86", 
           w33      => x"44", 
           w34      => x"cf", 
           w35      => x"15", 
           w36      => x"83", 
           w37      => x"1f", 
           w38      => x"88", 
           w39      => x"77", 
           w40      => x"d1", 
           w41      => x"10", 
           w42      => x"ec", 
           w43      => x"49", 
           w44      => x"f2", 
           w45      => x"ad", 
           w46      => x"93", 
           w47      => x"0c", 
           w48      => x"86", 
           w49      => x"32", 
           w50      => x"36", 
           w51      => x"51", 
           w52      => x"aa", 
           w53      => x"d3", 
           w54      => x"9b", 
           w55      => x"6a", 
           w56      => x"f3", 
           w57      => x"eb", 
           w58      => x"4e", 
           w59      => x"93", 
           w60      => x"89", 
           w61      => x"a2", 
           w62      => x"e6", 
           w63      => x"92", 
           w64      => x"26", 
           d_out   => pca_d17_out, en_out  => open, sof_out => open );

PCA64_18_inst: PCA_64 
  generic map(
           mult_sum => mult_sum,
           N        => CL_W,
           M        => PCAweightW,
           in_row   => in_row,
           in_col   => in_col
           )
  port map (
           clk       => clk    ,
           rst       => rst    ,
d01_in    => d01_out, d02_in    => d02_out, d03_in    => d03_out, d04_in    => d04_out, d05_in    => d05_out, d06_in    => d06_out, d07_in    => d07_out, d08_in    => d08_out, 
d09_in    => d09_out, d10_in    => d10_out, d11_in    => d11_out, d12_in    => d12_out, d13_in    => d13_out, d14_in    => d14_out, d15_in    => d15_out, d16_in    => d16_out, 
d17_in    => d17_out, d18_in    => d18_out, d19_in    => d19_out, d20_in    => d20_out, d21_in    => d21_out, d22_in    => d22_out, d23_in    => d23_out, d24_in    => d24_out, 
d25_in    => d25_out, d26_in    => d26_out, d27_in    => d27_out, d28_in    => d28_out, d29_in    => d29_out, d30_in    => d30_out, d31_in    => d31_out, d32_in    => d32_out, 
d33_in    => d33_out, d34_in    => d34_out, d35_in    => d35_out, d36_in    => d36_out, d37_in    => d37_out, d38_in    => d38_out, d39_in    => d39_out, d40_in    => d40_out, 
d41_in    => d41_out, d42_in    => d42_out, d43_in    => d43_out, d44_in    => d44_out, d45_in    => d45_out, d46_in    => d46_out, d47_in    => d47_out, d48_in    => d48_out, 
d49_in    => d49_out, d50_in    => d50_out, d51_in    => d51_out, d52_in    => d52_out, d53_in    => d53_out, d54_in    => d54_out, d55_in    => d55_out, d56_in    => d56_out,
d57_in    => d57_out, d58_in    => d58_out, d59_in    => d59_out, d60_in    => d60_out, d61_in    => d61_out, d62_in    => d62_out, d63_in    => d63_out, d64_in    => d64_out, 
           en_in     => '0',
           sof_in    => '0',

           w01      => x"42", 
           w02      => x"3e", 
           w03      => x"c0", 
           w04      => x"a8", 
           w05      => x"2d", 
           w06      => x"23", 
           w07      => x"5d", 
           w08      => x"31", 
           w09      => x"b3", 
           w10      => x"c1", 
           w11      => x"29", 
           w12      => x"9c", 
           w13      => x"f2", 
           w14      => x"fa", 
           w15      => x"d7", 
           w16      => x"25", 
           w17      => x"e7", 
           w18      => x"f6", 
           w19      => x"d0", 
           w20      => x"ad", 
           w21      => x"ef", 
           w22      => x"11", 
           w23      => x"76", 
           w24      => x"56", 
           w25      => x"6d", 
           w26      => x"1e", 
           w27      => x"3d", 
           w28      => x"d9", 
           w29      => x"e6", 
           w30      => x"7e", 
           w31      => x"e1", 
           w32      => x"9b", 
           w33      => x"be", 
           w34      => x"69", 
           w35      => x"c1", 
           w36      => x"4a", 
           w37      => x"ef", 
           w38      => x"78", 
           w39      => x"1b", 
           w40      => x"75", 
           w41      => x"26", 
           w42      => x"ba", 
           w43      => x"1f", 
           w44      => x"82", 
           w45      => x"fc", 
           w46      => x"40", 
           w47      => x"36", 
           w48      => x"a0", 
           w49      => x"9d", 
           w50      => x"59", 
           w51      => x"3e", 
           w52      => x"8b", 
           w53      => x"57", 
           w54      => x"e1", 
           w55      => x"cf", 
           w56      => x"bd", 
           w57      => x"83", 
           w58      => x"7a", 
           w59      => x"76", 
           w60      => x"b5", 
           w61      => x"1b", 
           w62      => x"23", 
           w63      => x"49", 
           w64      => x"61", 
           d_out   => pca_d18_out, en_out  => open, sof_out => open );

PCA64_19_inst: PCA_64 
  generic map(
           mult_sum => mult_sum,
           N        => CL_W,
           M        => PCAweightW,
           in_row   => in_row,
           in_col   => in_col
           )
  port map (
           clk       => clk    ,
           rst       => rst    ,
d01_in    => d01_out, d02_in    => d02_out, d03_in    => d03_out, d04_in    => d04_out, d05_in    => d05_out, d06_in    => d06_out, d07_in    => d07_out, d08_in    => d08_out, 
d09_in    => d09_out, d10_in    => d10_out, d11_in    => d11_out, d12_in    => d12_out, d13_in    => d13_out, d14_in    => d14_out, d15_in    => d15_out, d16_in    => d16_out, 
d17_in    => d17_out, d18_in    => d18_out, d19_in    => d19_out, d20_in    => d20_out, d21_in    => d21_out, d22_in    => d22_out, d23_in    => d23_out, d24_in    => d24_out, 
d25_in    => d25_out, d26_in    => d26_out, d27_in    => d27_out, d28_in    => d28_out, d29_in    => d29_out, d30_in    => d30_out, d31_in    => d31_out, d32_in    => d32_out, 
d33_in    => d33_out, d34_in    => d34_out, d35_in    => d35_out, d36_in    => d36_out, d37_in    => d37_out, d38_in    => d38_out, d39_in    => d39_out, d40_in    => d40_out, 
d41_in    => d41_out, d42_in    => d42_out, d43_in    => d43_out, d44_in    => d44_out, d45_in    => d45_out, d46_in    => d46_out, d47_in    => d47_out, d48_in    => d48_out, 
d49_in    => d49_out, d50_in    => d50_out, d51_in    => d51_out, d52_in    => d52_out, d53_in    => d53_out, d54_in    => d54_out, d55_in    => d55_out, d56_in    => d56_out,
d57_in    => d57_out, d58_in    => d58_out, d59_in    => d59_out, d60_in    => d60_out, d61_in    => d61_out, d62_in    => d62_out, d63_in    => d63_out, d64_in    => d64_out, 
           en_in     => '0',
           sof_in    => '0',

           w01      => x"7a", 
           w02      => x"ab", 
           w03      => x"b5", 
           w04      => x"f7", 
           w05      => x"76", 
           w06      => x"7b", 
           w07      => x"12", 
           w08      => x"d6", 
           w09      => x"91", 
           w10      => x"32", 
           w11      => x"e7", 
           w12      => x"a8", 
           w13      => x"2c", 
           w14      => x"9f", 
           w15      => x"55", 
           w16      => x"9a", 
           w17      => x"87", 
           w18      => x"1a", 
           w19      => x"c5", 
           w20      => x"ec", 
           w21      => x"61", 
           w22      => x"af", 
           w23      => x"7e", 
           w24      => x"41", 
           w25      => x"a7", 
           w26      => x"b8", 
           w27      => x"ce", 
           w28      => x"53", 
           w29      => x"4d", 
           w30      => x"9f", 
           w31      => x"86", 
           w32      => x"8d", 
           w33      => x"8e", 
           w34      => x"80", 
           w35      => x"5b", 
           w36      => x"ee", 
           w37      => x"9e", 
           w38      => x"78", 
           w39      => x"f5", 
           w40      => x"67", 
           w41      => x"f5", 
           w42      => x"73", 
           w43      => x"fc", 
           w44      => x"2c", 
           w45      => x"0b", 
           w46      => x"36", 
           w47      => x"10", 
           w48      => x"c7", 
           w49      => x"8d", 
           w50      => x"bf", 
           w51      => x"54", 
           w52      => x"44", 
           w53      => x"49", 
           w54      => x"1b", 
           w55      => x"cc", 
           w56      => x"16", 
           w57      => x"43", 
           w58      => x"ef", 
           w59      => x"bc", 
           w60      => x"95", 
           w61      => x"40", 
           w62      => x"e5", 
           w63      => x"68", 
           w64      => x"36", 
           d_out   => pca_d19_out, en_out  => open, sof_out => open );

PCA64_20_inst: PCA_64 
  generic map(
           mult_sum => mult_sum,
           N        => CL_W,
           M        => PCAweightW,
           in_row   => in_row,
           in_col   => in_col
           )
  port map (
           clk       => clk    ,
           rst       => rst    ,
d01_in    => d01_out, d02_in    => d02_out, d03_in    => d03_out, d04_in    => d04_out, d05_in    => d05_out, d06_in    => d06_out, d07_in    => d07_out, d08_in    => d08_out, 
d09_in    => d09_out, d10_in    => d10_out, d11_in    => d11_out, d12_in    => d12_out, d13_in    => d13_out, d14_in    => d14_out, d15_in    => d15_out, d16_in    => d16_out, 
d17_in    => d17_out, d18_in    => d18_out, d19_in    => d19_out, d20_in    => d20_out, d21_in    => d21_out, d22_in    => d22_out, d23_in    => d23_out, d24_in    => d24_out, 
d25_in    => d25_out, d26_in    => d26_out, d27_in    => d27_out, d28_in    => d28_out, d29_in    => d29_out, d30_in    => d30_out, d31_in    => d31_out, d32_in    => d32_out, 
d33_in    => d33_out, d34_in    => d34_out, d35_in    => d35_out, d36_in    => d36_out, d37_in    => d37_out, d38_in    => d38_out, d39_in    => d39_out, d40_in    => d40_out, 
d41_in    => d41_out, d42_in    => d42_out, d43_in    => d43_out, d44_in    => d44_out, d45_in    => d45_out, d46_in    => d46_out, d47_in    => d47_out, d48_in    => d48_out, 
d49_in    => d49_out, d50_in    => d50_out, d51_in    => d51_out, d52_in    => d52_out, d53_in    => d53_out, d54_in    => d54_out, d55_in    => d55_out, d56_in    => d56_out,
d57_in    => d57_out, d58_in    => d58_out, d59_in    => d59_out, d60_in    => d60_out, d61_in    => d61_out, d62_in    => d62_out, d63_in    => d63_out, d64_in    => d64_out, 
           en_in     => '0',
           sof_in    => '0',

           w01      => x"72", 
           w02      => x"29", 
           w03      => x"bb", 
           w04      => x"75", 
           w05      => x"6e", 
           w06      => x"a7", 
           w07      => x"ce", 
           w08      => x"57", 
           w09      => x"f9", 
           w10      => x"6e", 
           w11      => x"35", 
           w12      => x"9d", 
           w13      => x"23", 
           w14      => x"54", 
           w15      => x"ad", 
           w16      => x"2d", 
           w17      => x"1b", 
           w18      => x"8a", 
           w19      => x"f5", 
           w20      => x"10", 
           w21      => x"76", 
           w22      => x"60", 
           w23      => x"2a", 
           w24      => x"2f", 
           w25      => x"fe", 
           w26      => x"49", 
           w27      => x"b1", 
           w28      => x"0e", 
           w29      => x"62", 
           w30      => x"37", 
           w31      => x"9c", 
           w32      => x"26", 
           w33      => x"55", 
           w34      => x"bf", 
           w35      => x"d3", 
           w36      => x"64", 
           w37      => x"cd", 
           w38      => x"c6", 
           w39      => x"2f", 
           w40      => x"7c", 
           w41      => x"ae", 
           w42      => x"c7", 
           w43      => x"66", 
           w44      => x"08", 
           w45      => x"ae", 
           w46      => x"79", 
           w47      => x"19", 
           w48      => x"5f", 
           w49      => x"46", 
           w50      => x"91", 
           w51      => x"71", 
           w52      => x"59", 
           w53      => x"97", 
           w54      => x"da", 
           w55      => x"ab", 
           w56      => x"72", 
           w57      => x"0d", 
           w58      => x"4a", 
           w59      => x"7a", 
           w60      => x"0a", 
           w61      => x"49", 
           w62      => x"97", 
           w63      => x"87", 
           w64      => x"71", 
           d_out   => pca_d20_out, en_out  => open, sof_out => open );

PCA64_21_inst: PCA_64 
  generic map(
           mult_sum => mult_sum,
           N        => CL_W,
           M        => PCAweightW,
           in_row   => in_row,
           in_col   => in_col
           )
  port map (
           clk       => clk    ,
           rst       => rst    ,
d01_in    => d01_out, d02_in    => d02_out, d03_in    => d03_out, d04_in    => d04_out, d05_in    => d05_out, d06_in    => d06_out, d07_in    => d07_out, d08_in    => d08_out, 
d09_in    => d09_out, d10_in    => d10_out, d11_in    => d11_out, d12_in    => d12_out, d13_in    => d13_out, d14_in    => d14_out, d15_in    => d15_out, d16_in    => d16_out, 
d17_in    => d17_out, d18_in    => d18_out, d19_in    => d19_out, d20_in    => d20_out, d21_in    => d21_out, d22_in    => d22_out, d23_in    => d23_out, d24_in    => d24_out, 
d25_in    => d25_out, d26_in    => d26_out, d27_in    => d27_out, d28_in    => d28_out, d29_in    => d29_out, d30_in    => d30_out, d31_in    => d31_out, d32_in    => d32_out, 
d33_in    => d33_out, d34_in    => d34_out, d35_in    => d35_out, d36_in    => d36_out, d37_in    => d37_out, d38_in    => d38_out, d39_in    => d39_out, d40_in    => d40_out, 
d41_in    => d41_out, d42_in    => d42_out, d43_in    => d43_out, d44_in    => d44_out, d45_in    => d45_out, d46_in    => d46_out, d47_in    => d47_out, d48_in    => d48_out, 
d49_in    => d49_out, d50_in    => d50_out, d51_in    => d51_out, d52_in    => d52_out, d53_in    => d53_out, d54_in    => d54_out, d55_in    => d55_out, d56_in    => d56_out,
d57_in    => d57_out, d58_in    => d58_out, d59_in    => d59_out, d60_in    => d60_out, d61_in    => d61_out, d62_in    => d62_out, d63_in    => d63_out, d64_in    => d64_out, 
           en_in     => '0',
           sof_in    => '0',

           w01      => x"3d", 
           w02      => x"b1", 
           w03      => x"c7", 
           w04      => x"31", 
           w05      => x"42", 
           w06      => x"c1", 
           w07      => x"28", 
           w08      => x"82", 
           w09      => x"5c", 
           w10      => x"99", 
           w11      => x"22", 
           w12      => x"63", 
           w13      => x"8b", 
           w14      => x"9e", 
           w15      => x"66", 
           w16      => x"cb", 
           w17      => x"87", 
           w18      => x"94", 
           w19      => x"cc", 
           w20      => x"9a", 
           w21      => x"d0", 
           w22      => x"5f", 
           w23      => x"c2", 
           w24      => x"07", 
           w25      => x"5a", 
           w26      => x"cb", 
           w27      => x"47", 
           w28      => x"5c", 
           w29      => x"f2", 
           w30      => x"f9", 
           w31      => x"7a", 
           w32      => x"15", 
           w33      => x"79", 
           w34      => x"98", 
           w35      => x"d9", 
           w36      => x"3a", 
           w37      => x"bb", 
           w38      => x"25", 
           w39      => x"9d", 
           w40      => x"4c", 
           w41      => x"c5", 
           w42      => x"39", 
           w43      => x"c6", 
           w44      => x"3d", 
           w45      => x"20", 
           w46      => x"43", 
           w47      => x"09", 
           w48      => x"9f", 
           w49      => x"c0", 
           w50      => x"c4", 
           w51      => x"74", 
           w52      => x"de", 
           w53      => x"c3", 
           w54      => x"8c", 
           w55      => x"af", 
           w56      => x"46", 
           w57      => x"0c", 
           w58      => x"77", 
           w59      => x"68", 
           w60      => x"34", 
           w61      => x"dd", 
           w62      => x"6c", 
           w63      => x"17", 
           w64      => x"f7", 
           d_out   => pca_d21_out, en_out  => open, sof_out => open );
PCA64_22_inst: PCA_64 
  generic map(
           mult_sum => mult_sum,
           N        => CL_W,
           M        => PCAweightW,
           in_row   => in_row,
           in_col   => in_col
           )
  port map (
           clk       => clk    ,
           rst       => rst    ,
d01_in    => d01_out, d02_in    => d02_out, d03_in    => d03_out, d04_in    => d04_out, d05_in    => d05_out, d06_in    => d06_out, d07_in    => d07_out, d08_in    => d08_out, 
d09_in    => d09_out, d10_in    => d10_out, d11_in    => d11_out, d12_in    => d12_out, d13_in    => d13_out, d14_in    => d14_out, d15_in    => d15_out, d16_in    => d16_out, 
d17_in    => d17_out, d18_in    => d18_out, d19_in    => d19_out, d20_in    => d20_out, d21_in    => d21_out, d22_in    => d22_out, d23_in    => d23_out, d24_in    => d24_out, 
d25_in    => d25_out, d26_in    => d26_out, d27_in    => d27_out, d28_in    => d28_out, d29_in    => d29_out, d30_in    => d30_out, d31_in    => d31_out, d32_in    => d32_out, 
d33_in    => d33_out, d34_in    => d34_out, d35_in    => d35_out, d36_in    => d36_out, d37_in    => d37_out, d38_in    => d38_out, d39_in    => d39_out, d40_in    => d40_out, 
d41_in    => d41_out, d42_in    => d42_out, d43_in    => d43_out, d44_in    => d44_out, d45_in    => d45_out, d46_in    => d46_out, d47_in    => d47_out, d48_in    => d48_out, 
d49_in    => d49_out, d50_in    => d50_out, d51_in    => d51_out, d52_in    => d52_out, d53_in    => d53_out, d54_in    => d54_out, d55_in    => d55_out, d56_in    => d56_out,
d57_in    => d57_out, d58_in    => d58_out, d59_in    => d59_out, d60_in    => d60_out, d61_in    => d61_out, d62_in    => d62_out, d63_in    => d63_out, d64_in    => d64_out, 
           en_in     => '0',
           sof_in    => '0',

           w01      => x"b6", 
           w02      => x"0d", 
           w03      => x"59", 
           w04      => x"ec", 
           w05      => x"76", 
           w06      => x"ea", 
           w07      => x"8a", 
           w08      => x"cb", 
           w09      => x"4b", 
           w10      => x"a2", 
           w11      => x"c2", 
           w12      => x"87", 
           w13      => x"e5", 
           w14      => x"43", 
           w15      => x"25", 
           w16      => x"cf", 
           w17      => x"7e", 
           w18      => x"20", 
           w19      => x"f9", 
           w20      => x"d8", 
           w21      => x"c2", 
           w22      => x"9a", 
           w23      => x"c9", 
           w24      => x"65", 
           w25      => x"1a", 
           w26      => x"8e", 
           w27      => x"26", 
           w28      => x"33", 
           w29      => x"59", 
           w30      => x"8e", 
           w31      => x"1b", 
           w32      => x"ef", 
           w33      => x"0d", 
           w34      => x"26", 
           w35      => x"4a", 
           w36      => x"a0", 
           w37      => x"40", 
           w38      => x"b2", 
           w39      => x"c4", 
           w40      => x"ec", 
           w41      => x"d0", 
           w42      => x"e1", 
           w43      => x"ab", 
           w44      => x"25", 
           w45      => x"39", 
           w46      => x"48", 
           w47      => x"42", 
           w48      => x"80", 
           w49      => x"69", 
           w50      => x"ee", 
           w51      => x"53", 
           w52      => x"9a", 
           w53      => x"6d", 
           w54      => x"46", 
           w55      => x"46", 
           w56      => x"ab", 
           w57      => x"b8", 
           w58      => x"c6", 
           w59      => x"4f", 
           w60      => x"a6", 
           w61      => x"45", 
           w62      => x"7e", 
           w63      => x"ad", 
           w64      => x"2f", 
           d_out   => pca_d22_out, en_out  => open, sof_out => open );

PCA64_23_inst: PCA_64 
  generic map(
           mult_sum => mult_sum,
           N        => CL_W,
           M        => PCAweightW,
           in_row   => in_row,
           in_col   => in_col
           )
  port map (
           clk       => clk    ,
           rst       => rst    ,
d01_in    => d01_out, d02_in    => d02_out, d03_in    => d03_out, d04_in    => d04_out, d05_in    => d05_out, d06_in    => d06_out, d07_in    => d07_out, d08_in    => d08_out, 
d09_in    => d09_out, d10_in    => d10_out, d11_in    => d11_out, d12_in    => d12_out, d13_in    => d13_out, d14_in    => d14_out, d15_in    => d15_out, d16_in    => d16_out, 
d17_in    => d17_out, d18_in    => d18_out, d19_in    => d19_out, d20_in    => d20_out, d21_in    => d21_out, d22_in    => d22_out, d23_in    => d23_out, d24_in    => d24_out, 
d25_in    => d25_out, d26_in    => d26_out, d27_in    => d27_out, d28_in    => d28_out, d29_in    => d29_out, d30_in    => d30_out, d31_in    => d31_out, d32_in    => d32_out, 
d33_in    => d33_out, d34_in    => d34_out, d35_in    => d35_out, d36_in    => d36_out, d37_in    => d37_out, d38_in    => d38_out, d39_in    => d39_out, d40_in    => d40_out, 
d41_in    => d41_out, d42_in    => d42_out, d43_in    => d43_out, d44_in    => d44_out, d45_in    => d45_out, d46_in    => d46_out, d47_in    => d47_out, d48_in    => d48_out, 
d49_in    => d49_out, d50_in    => d50_out, d51_in    => d51_out, d52_in    => d52_out, d53_in    => d53_out, d54_in    => d54_out, d55_in    => d55_out, d56_in    => d56_out,
d57_in    => d57_out, d58_in    => d58_out, d59_in    => d59_out, d60_in    => d60_out, d61_in    => d61_out, d62_in    => d62_out, d63_in    => d63_out, d64_in    => d64_out, 
           en_in     => '0',
           sof_in    => '0',

           w01      => x"87", 
           w02      => x"0c", 
           w03      => x"1c", 
           w04      => x"2e", 
           w05      => x"64", 
           w06      => x"df", 
           w07      => x"ab", 
           w08      => x"14", 
           w09      => x"50", 
           w10      => x"cf", 
           w11      => x"ae", 
           w12      => x"d1", 
           w13      => x"d3", 
           w14      => x"f6", 
           w15      => x"de", 
           w16      => x"67", 
           w17      => x"2a", 
           w18      => x"e3", 
           w19      => x"ed", 
           w20      => x"49", 
           w21      => x"6e", 
           w22      => x"3d", 
           w23      => x"17", 
           w24      => x"c3", 
           w25      => x"94", 
           w26      => x"c2", 
           w27      => x"2a", 
           w28      => x"38", 
           w29      => x"7d", 
           w30      => x"65", 
           w31      => x"52", 
           w32      => x"bf", 
           w33      => x"a7", 
           w34      => x"e3", 
           w35      => x"87", 
           w36      => x"c0", 
           w37      => x"70", 
           w38      => x"d8", 
           w39      => x"b6", 
           w40      => x"88", 
           w41      => x"1c", 
           w42      => x"e4", 
           w43      => x"c4", 
           w44      => x"74", 
           w45      => x"d8", 
           w46      => x"2d", 
           w47      => x"09", 
           w48      => x"65", 
           w49      => x"d6", 
           w50      => x"30", 
           w51      => x"34", 
           w52      => x"ae", 
           w53      => x"c3", 
           w54      => x"12", 
           w55      => x"e1", 
           w56      => x"f0", 
           w57      => x"a6", 
           w58      => x"2c", 
           w59      => x"89", 
           w60      => x"e2", 
           w61      => x"cf", 
           w62      => x"84", 
           w63      => x"09", 
           w64      => x"cf", 
           d_out   => pca_d23_out, en_out  => open, sof_out => open );

PCA64_24_inst: PCA_64 
  generic map(
           mult_sum => mult_sum,
           N        => CL_W,
           M        => PCAweightW,
           in_row   => in_row,
           in_col   => in_col
           )
  port map (
           clk       => clk    ,
           rst       => rst    ,
d01_in    => d01_out, d02_in    => d02_out, d03_in    => d03_out, d04_in    => d04_out, d05_in    => d05_out, d06_in    => d06_out, d07_in    => d07_out, d08_in    => d08_out, 
d09_in    => d09_out, d10_in    => d10_out, d11_in    => d11_out, d12_in    => d12_out, d13_in    => d13_out, d14_in    => d14_out, d15_in    => d15_out, d16_in    => d16_out, 
d17_in    => d17_out, d18_in    => d18_out, d19_in    => d19_out, d20_in    => d20_out, d21_in    => d21_out, d22_in    => d22_out, d23_in    => d23_out, d24_in    => d24_out, 
d25_in    => d25_out, d26_in    => d26_out, d27_in    => d27_out, d28_in    => d28_out, d29_in    => d29_out, d30_in    => d30_out, d31_in    => d31_out, d32_in    => d32_out, 
d33_in    => d33_out, d34_in    => d34_out, d35_in    => d35_out, d36_in    => d36_out, d37_in    => d37_out, d38_in    => d38_out, d39_in    => d39_out, d40_in    => d40_out, 
d41_in    => d41_out, d42_in    => d42_out, d43_in    => d43_out, d44_in    => d44_out, d45_in    => d45_out, d46_in    => d46_out, d47_in    => d47_out, d48_in    => d48_out, 
d49_in    => d49_out, d50_in    => d50_out, d51_in    => d51_out, d52_in    => d52_out, d53_in    => d53_out, d54_in    => d54_out, d55_in    => d55_out, d56_in    => d56_out,
d57_in    => d57_out, d58_in    => d58_out, d59_in    => d59_out, d60_in    => d60_out, d61_in    => d61_out, d62_in    => d62_out, d63_in    => d63_out, d64_in    => d64_out, 
           en_in     => '0',
           sof_in    => '0',

           w01      => x"3c", 
           w02      => x"e4", 
           w03      => x"5e", 
           w04      => x"27", 
           w05      => x"a2", 
           w06      => x"5d", 
           w07      => x"e1", 
           w08      => x"4a", 
           w09      => x"db", 
           w10      => x"45", 
           w11      => x"a1", 
           w12      => x"5d", 
           w13      => x"a9", 
           w14      => x"3e", 
           w15      => x"af", 
           w16      => x"21", 
           w17      => x"8c", 
           w18      => x"ad", 
           w19      => x"76", 
           w20      => x"65", 
           w21      => x"fa", 
           w22      => x"9c", 
           w23      => x"5a", 
           w24      => x"dc", 
           w25      => x"39", 
           w26      => x"bd", 
           w27      => x"a4", 
           w28      => x"aa", 
           w29      => x"48", 
           w30      => x"dc", 
           w31      => x"46", 
           w32      => x"e7", 
           w33      => x"7e", 
           w34      => x"3f", 
           w35      => x"a6", 
           w36      => x"88", 
           w37      => x"29", 
           w38      => x"27", 
           w39      => x"70", 
           w40      => x"a4", 
           w41      => x"82", 
           w42      => x"27", 
           w43      => x"73", 
           w44      => x"60", 
           w45      => x"ca", 
           w46      => x"76", 
           w47      => x"5e", 
           w48      => x"70", 
           w49      => x"58", 
           w50      => x"7e", 
           w51      => x"22", 
           w52      => x"0e", 
           w53      => x"33", 
           w54      => x"ee", 
           w55      => x"3b", 
           w56      => x"76", 
           w57      => x"79", 
           w58      => x"df", 
           w59      => x"f4", 
           w60      => x"47", 
           w61      => x"7e", 
           w62      => x"1a", 
           w63      => x"0a", 
           w64      => x"0a", 
           d_out   => pca_d24_out, en_out  => open, sof_out => open );

PCA64_25_inst: PCA_64 
  generic map(
           mult_sum => mult_sum,
           N        => CL_W,
           M        => PCAweightW,
           in_row   => in_row,
           in_col   => in_col
           )
  port map (
           clk       => clk    ,
           rst       => rst    ,
d01_in    => d01_out, d02_in    => d02_out, d03_in    => d03_out, d04_in    => d04_out, d05_in    => d05_out, d06_in    => d06_out, d07_in    => d07_out, d08_in    => d08_out, 
d09_in    => d09_out, d10_in    => d10_out, d11_in    => d11_out, d12_in    => d12_out, d13_in    => d13_out, d14_in    => d14_out, d15_in    => d15_out, d16_in    => d16_out, 
d17_in    => d17_out, d18_in    => d18_out, d19_in    => d19_out, d20_in    => d20_out, d21_in    => d21_out, d22_in    => d22_out, d23_in    => d23_out, d24_in    => d24_out, 
d25_in    => d25_out, d26_in    => d26_out, d27_in    => d27_out, d28_in    => d28_out, d29_in    => d29_out, d30_in    => d30_out, d31_in    => d31_out, d32_in    => d32_out, 
d33_in    => d33_out, d34_in    => d34_out, d35_in    => d35_out, d36_in    => d36_out, d37_in    => d37_out, d38_in    => d38_out, d39_in    => d39_out, d40_in    => d40_out, 
d41_in    => d41_out, d42_in    => d42_out, d43_in    => d43_out, d44_in    => d44_out, d45_in    => d45_out, d46_in    => d46_out, d47_in    => d47_out, d48_in    => d48_out, 
d49_in    => d49_out, d50_in    => d50_out, d51_in    => d51_out, d52_in    => d52_out, d53_in    => d53_out, d54_in    => d54_out, d55_in    => d55_out, d56_in    => d56_out,
d57_in    => d57_out, d58_in    => d58_out, d59_in    => d59_out, d60_in    => d60_out, d61_in    => d61_out, d62_in    => d62_out, d63_in    => d63_out, d64_in    => d64_out, 
           en_in     => '0',
           sof_in    => '0',

           w01      => x"ca", 
           w02      => x"68", 
           w03      => x"9a", 
           w04      => x"2d", 
           w05      => x"b6", 
           w06      => x"5d", 
           w07      => x"8d", 
           w08      => x"1f", 
           w09      => x"fe", 
           w10      => x"35", 
           w11      => x"eb", 
           w12      => x"62", 
           w13      => x"3f", 
           w14      => x"70", 
           w15      => x"53", 
           w16      => x"dc", 
           w17      => x"8a", 
           w18      => x"88", 
           w19      => x"c3", 
           w20      => x"4b", 
           w21      => x"36", 
           w22      => x"f6", 
           w23      => x"1a", 
           w24      => x"8b", 
           w25      => x"50", 
           w26      => x"5f", 
           w27      => x"f4", 
           w28      => x"87", 
           w29      => x"6d", 
           w30      => x"21", 
           w31      => x"fb", 
           w32      => x"dd", 
           w33      => x"85", 
           w34      => x"6b", 
           w35      => x"b5", 
           w36      => x"17", 
           w37      => x"8c", 
           w38      => x"fc", 
           w39      => x"15", 
           w40      => x"4d", 
           w41      => x"d4", 
           w42      => x"d1", 
           w43      => x"cf", 
           w44      => x"56", 
           w45      => x"c3", 
           w46      => x"46", 
           w47      => x"f2", 
           w48      => x"76", 
           w49      => x"d0", 
           w50      => x"cd", 
           w51      => x"4c", 
           w52      => x"ee", 
           w53      => x"97", 
           w54      => x"1a", 
           w55      => x"ea", 
           w56      => x"aa", 
           w57      => x"4d", 
           w58      => x"ef", 
           w59      => x"ad", 
           w60      => x"15", 
           w61      => x"bf", 
           w62      => x"b8", 
           w63      => x"84", 
           w64      => x"a9", 
           d_out   => pca_d25_out, en_out  => open, sof_out => open );

PCA64_26_inst: PCA_64 
  generic map(
           mult_sum => mult_sum,
           N        => CL_W,
           M        => PCAweightW,
           in_row   => in_row,
           in_col   => in_col
           )
  port map (
           clk       => clk    ,
           rst       => rst    ,
d01_in    => d01_out, d02_in    => d02_out, d03_in    => d03_out, d04_in    => d04_out, d05_in    => d05_out, d06_in    => d06_out, d07_in    => d07_out, d08_in    => d08_out, 
d09_in    => d09_out, d10_in    => d10_out, d11_in    => d11_out, d12_in    => d12_out, d13_in    => d13_out, d14_in    => d14_out, d15_in    => d15_out, d16_in    => d16_out, 
d17_in    => d17_out, d18_in    => d18_out, d19_in    => d19_out, d20_in    => d20_out, d21_in    => d21_out, d22_in    => d22_out, d23_in    => d23_out, d24_in    => d24_out, 
d25_in    => d25_out, d26_in    => d26_out, d27_in    => d27_out, d28_in    => d28_out, d29_in    => d29_out, d30_in    => d30_out, d31_in    => d31_out, d32_in    => d32_out, 
d33_in    => d33_out, d34_in    => d34_out, d35_in    => d35_out, d36_in    => d36_out, d37_in    => d37_out, d38_in    => d38_out, d39_in    => d39_out, d40_in    => d40_out, 
d41_in    => d41_out, d42_in    => d42_out, d43_in    => d43_out, d44_in    => d44_out, d45_in    => d45_out, d46_in    => d46_out, d47_in    => d47_out, d48_in    => d48_out, 
d49_in    => d49_out, d50_in    => d50_out, d51_in    => d51_out, d52_in    => d52_out, d53_in    => d53_out, d54_in    => d54_out, d55_in    => d55_out, d56_in    => d56_out,
d57_in    => d57_out, d58_in    => d58_out, d59_in    => d59_out, d60_in    => d60_out, d61_in    => d61_out, d62_in    => d62_out, d63_in    => d63_out, d64_in    => d64_out, 
           en_in     => '0',
           sof_in    => '0',

           w01      => x"bf", 
           w02      => x"6f", 
           w03      => x"46", 
           w04      => x"9c", 
           w05      => x"a3", 
           w06      => x"27", 
           w07      => x"67", 
           w08      => x"c8", 
           w09      => x"87", 
           w10      => x"51", 
           w11      => x"62", 
           w12      => x"34", 
           w13      => x"3d", 
           w14      => x"ae", 
           w15      => x"3d", 
           w16      => x"45", 
           w17      => x"1a", 
           w18      => x"7f", 
           w19      => x"59", 
           w20      => x"68", 
           w21      => x"48", 
           w22      => x"df", 
           w23      => x"36", 
           w24      => x"65", 
           w25      => x"b9", 
           w26      => x"ac", 
           w27      => x"bd", 
           w28      => x"e9", 
           w29      => x"c3", 
           w30      => x"0d", 
           w31      => x"86", 
           w32      => x"f0", 
           w33      => x"8d", 
           w34      => x"63", 
           w35      => x"f5", 
           w36      => x"35", 
           w37      => x"b5", 
           w38      => x"12", 
           w39      => x"e7", 
           w40      => x"a7", 
           w41      => x"30", 
           w42      => x"6f", 
           w43      => x"38", 
           w44      => x"7c", 
           w45      => x"d6", 
           w46      => x"11", 
           w47      => x"55", 
           w48      => x"1f", 
           w49      => x"98", 
           w50      => x"be", 
           w51      => x"71", 
           w52      => x"16", 
           w53      => x"93", 
           w54      => x"da", 
           w55      => x"9d", 
           w56      => x"f7", 
           w57      => x"78", 
           w58      => x"ef", 
           w59      => x"cf", 
           w60      => x"d7", 
           w61      => x"0e", 
           w62      => x"63", 
           w63      => x"1e", 
           w64      => x"c6", 
           d_out   => pca_d26_out, en_out  => open, sof_out => open );

PCA64_27_inst: PCA_64 
  generic map(
           mult_sum => mult_sum,
           N        => CL_W,
           M        => PCAweightW,
           in_row   => in_row,
           in_col   => in_col
           )
  port map (
           clk       => clk    ,
           rst       => rst    ,
d01_in    => d01_out, d02_in    => d02_out, d03_in    => d03_out, d04_in    => d04_out, d05_in    => d05_out, d06_in    => d06_out, d07_in    => d07_out, d08_in    => d08_out, 
d09_in    => d09_out, d10_in    => d10_out, d11_in    => d11_out, d12_in    => d12_out, d13_in    => d13_out, d14_in    => d14_out, d15_in    => d15_out, d16_in    => d16_out, 
d17_in    => d17_out, d18_in    => d18_out, d19_in    => d19_out, d20_in    => d20_out, d21_in    => d21_out, d22_in    => d22_out, d23_in    => d23_out, d24_in    => d24_out, 
d25_in    => d25_out, d26_in    => d26_out, d27_in    => d27_out, d28_in    => d28_out, d29_in    => d29_out, d30_in    => d30_out, d31_in    => d31_out, d32_in    => d32_out, 
d33_in    => d33_out, d34_in    => d34_out, d35_in    => d35_out, d36_in    => d36_out, d37_in    => d37_out, d38_in    => d38_out, d39_in    => d39_out, d40_in    => d40_out, 
d41_in    => d41_out, d42_in    => d42_out, d43_in    => d43_out, d44_in    => d44_out, d45_in    => d45_out, d46_in    => d46_out, d47_in    => d47_out, d48_in    => d48_out, 
d49_in    => d49_out, d50_in    => d50_out, d51_in    => d51_out, d52_in    => d52_out, d53_in    => d53_out, d54_in    => d54_out, d55_in    => d55_out, d56_in    => d56_out,
d57_in    => d57_out, d58_in    => d58_out, d59_in    => d59_out, d60_in    => d60_out, d61_in    => d61_out, d62_in    => d62_out, d63_in    => d63_out, d64_in    => d64_out, 
           en_in     => '0',
           sof_in    => '0',

           w01      => x"38", 
           w02      => x"5a", 
           w03      => x"85", 
           w04      => x"fc", 
           w05      => x"af", 
           w06      => x"d7", 
           w07      => x"ce", 
           w08      => x"8d", 
           w09      => x"0b", 
           w10      => x"ec", 
           w11      => x"83", 
           w12      => x"56", 
           w13      => x"1d", 
           w14      => x"e8", 
           w15      => x"9d", 
           w16      => x"85", 
           w17      => x"73", 
           w18      => x"6a", 
           w19      => x"d2", 
           w20      => x"c1", 
           w21      => x"4d", 
           w22      => x"b7", 
           w23      => x"6d", 
           w24      => x"95", 
           w25      => x"85", 
           w26      => x"c3", 
           w27      => x"a2", 
           w28      => x"5b", 
           w29      => x"e6", 
           w30      => x"36", 
           w31      => x"3d", 
           w32      => x"9c", 
           w33      => x"5d", 
           w34      => x"7b", 
           w35      => x"a2", 
           w36      => x"f9", 
           w37      => x"e7", 
           w38      => x"fe", 
           w39      => x"4a", 
           w40      => x"1a", 
           w41      => x"9b", 
           w42      => x"d9", 
           w43      => x"a6", 
           w44      => x"11", 
           w45      => x"9a", 
           w46      => x"50", 
           w47      => x"88", 
           w48      => x"ea", 
           w49      => x"44", 
           w50      => x"50", 
           w51      => x"12", 
           w52      => x"b0", 
           w53      => x"4a", 
           w54      => x"7b", 
           w55      => x"1b", 
           w56      => x"ce", 
           w57      => x"94", 
           w58      => x"b9", 
           w59      => x"71", 
           w60      => x"e4", 
           w61      => x"1a", 
           w62      => x"fb", 
           w63      => x"3d", 
           w64      => x"41", 
           d_out   => pca_d27_out, en_out  => open, sof_out => open );

PCA64_28_inst: PCA_64 
  generic map(
           mult_sum => mult_sum,
           N        => CL_W,
           M        => PCAweightW,
           in_row   => in_row,
           in_col   => in_col
           )
  port map (
           clk       => clk    ,
           rst       => rst    ,
d01_in    => d01_out, d02_in    => d02_out, d03_in    => d03_out, d04_in    => d04_out, d05_in    => d05_out, d06_in    => d06_out, d07_in    => d07_out, d08_in    => d08_out, 
d09_in    => d09_out, d10_in    => d10_out, d11_in    => d11_out, d12_in    => d12_out, d13_in    => d13_out, d14_in    => d14_out, d15_in    => d15_out, d16_in    => d16_out, 
d17_in    => d17_out, d18_in    => d18_out, d19_in    => d19_out, d20_in    => d20_out, d21_in    => d21_out, d22_in    => d22_out, d23_in    => d23_out, d24_in    => d24_out, 
d25_in    => d25_out, d26_in    => d26_out, d27_in    => d27_out, d28_in    => d28_out, d29_in    => d29_out, d30_in    => d30_out, d31_in    => d31_out, d32_in    => d32_out, 
d33_in    => d33_out, d34_in    => d34_out, d35_in    => d35_out, d36_in    => d36_out, d37_in    => d37_out, d38_in    => d38_out, d39_in    => d39_out, d40_in    => d40_out, 
d41_in    => d41_out, d42_in    => d42_out, d43_in    => d43_out, d44_in    => d44_out, d45_in    => d45_out, d46_in    => d46_out, d47_in    => d47_out, d48_in    => d48_out, 
d49_in    => d49_out, d50_in    => d50_out, d51_in    => d51_out, d52_in    => d52_out, d53_in    => d53_out, d54_in    => d54_out, d55_in    => d55_out, d56_in    => d56_out,
d57_in    => d57_out, d58_in    => d58_out, d59_in    => d59_out, d60_in    => d60_out, d61_in    => d61_out, d62_in    => d62_out, d63_in    => d63_out, d64_in    => d64_out, 
           en_in     => '0',
           sof_in    => '0',

           w01      => x"6e", 
           w02      => x"e2", 
           w03      => x"31", 
           w04      => x"c7", 
           w05      => x"77", 
           w06      => x"74", 
           w07      => x"dc", 
           w08      => x"b2", 
           w09      => x"5d", 
           w10      => x"d0", 
           w11      => x"fa", 
           w12      => x"59", 
           w13      => x"44", 
           w14      => x"ff", 
           w15      => x"d2", 
           w16      => x"1e", 
           w17      => x"4b", 
           w18      => x"f0", 
           w19      => x"1a", 
           w20      => x"48", 
           w21      => x"81", 
           w22      => x"2f", 
           w23      => x"0d", 
           w24      => x"8c", 
           w25      => x"a5", 
           w26      => x"30", 
           w27      => x"54", 
           w28      => x"0b", 
           w29      => x"cb", 
           w30      => x"0f", 
           w31      => x"96", 
           w32      => x"e4", 
           w33      => x"6a", 
           w34      => x"6e", 
           w35      => x"93", 
           w36      => x"27", 
           w37      => x"80", 
           w38      => x"75", 
           w39      => x"e6", 
           w40      => x"09", 
           w41      => x"36", 
           w42      => x"94", 
           w43      => x"a9", 
           w44      => x"26", 
           w45      => x"d8", 
           w46      => x"c1", 
           w47      => x"5d", 
           w48      => x"f7", 
           w49      => x"6e", 
           w50      => x"95", 
           w51      => x"3b", 
           w52      => x"11", 
           w53      => x"16", 
           w54      => x"2a", 
           w55      => x"1c", 
           w56      => x"f5", 
           w57      => x"8c", 
           w58      => x"0d", 
           w59      => x"f3", 
           w60      => x"f4", 
           w61      => x"35", 
           w62      => x"9b", 
           w63      => x"82", 
           w64      => x"29", 
           d_out   => pca_d28_out, en_out  => open, sof_out => open );

PCA64_29_inst: PCA_64 
  generic map(
           mult_sum => mult_sum,
           N        => CL_W,
           M        => PCAweightW,
           in_row   => in_row,
           in_col   => in_col
           )
  port map (
           clk       => clk    ,
           rst       => rst    ,
d01_in    => d01_out, d02_in    => d02_out, d03_in    => d03_out, d04_in    => d04_out, d05_in    => d05_out, d06_in    => d06_out, d07_in    => d07_out, d08_in    => d08_out, 
d09_in    => d09_out, d10_in    => d10_out, d11_in    => d11_out, d12_in    => d12_out, d13_in    => d13_out, d14_in    => d14_out, d15_in    => d15_out, d16_in    => d16_out, 
d17_in    => d17_out, d18_in    => d18_out, d19_in    => d19_out, d20_in    => d20_out, d21_in    => d21_out, d22_in    => d22_out, d23_in    => d23_out, d24_in    => d24_out, 
d25_in    => d25_out, d26_in    => d26_out, d27_in    => d27_out, d28_in    => d28_out, d29_in    => d29_out, d30_in    => d30_out, d31_in    => d31_out, d32_in    => d32_out, 
d33_in    => d33_out, d34_in    => d34_out, d35_in    => d35_out, d36_in    => d36_out, d37_in    => d37_out, d38_in    => d38_out, d39_in    => d39_out, d40_in    => d40_out, 
d41_in    => d41_out, d42_in    => d42_out, d43_in    => d43_out, d44_in    => d44_out, d45_in    => d45_out, d46_in    => d46_out, d47_in    => d47_out, d48_in    => d48_out, 
d49_in    => d49_out, d50_in    => d50_out, d51_in    => d51_out, d52_in    => d52_out, d53_in    => d53_out, d54_in    => d54_out, d55_in    => d55_out, d56_in    => d56_out,
d57_in    => d57_out, d58_in    => d58_out, d59_in    => d59_out, d60_in    => d60_out, d61_in    => d61_out, d62_in    => d62_out, d63_in    => d63_out, d64_in    => d64_out, 
           en_in     => '0',
           sof_in    => '0',

           w01      => x"73", 
           w02      => x"4e", 
           w03      => x"68", 
           w04      => x"89", 
           w05      => x"fe", 
           w06      => x"5d", 
           w07      => x"83", 
           w08      => x"ad", 
           w09      => x"1f", 
           w10      => x"c9", 
           w11      => x"d6", 
           w12      => x"fc", 
           w13      => x"29", 
           w14      => x"7a", 
           w15      => x"ce", 
           w16      => x"ac", 
           w17      => x"b0", 
           w18      => x"a0", 
           w19      => x"a0", 
           w20      => x"7a", 
           w21      => x"5d", 
           w22      => x"16", 
           w23      => x"d5", 
           w24      => x"65", 
           w25      => x"8d", 
           w26      => x"8f", 
           w27      => x"12", 
           w28      => x"c0", 
           w29      => x"a4", 
           w30      => x"6e", 
           w31      => x"8c", 
           w32      => x"4e", 
           w33      => x"42", 
           w34      => x"41", 
           w35      => x"e4", 
           w36      => x"ec", 
           w37      => x"c1", 
           w38      => x"ff", 
           w39      => x"a4", 
           w40      => x"e5", 
           w41      => x"10", 
           w42      => x"62", 
           w43      => x"9e", 
           w44      => x"de", 
           w45      => x"8c", 
           w46      => x"cf", 
           w47      => x"ca", 
           w48      => x"43", 
           w49      => x"92", 
           w50      => x"33", 
           w51      => x"dc", 
           w52      => x"92", 
           w53      => x"fa", 
           w54      => x"2b", 
           w55      => x"c0", 
           w56      => x"6c", 
           w57      => x"5e", 
           w58      => x"b5", 
           w59      => x"90", 
           w60      => x"1a", 
           w61      => x"69", 
           w62      => x"25", 
           w63      => x"57", 
           w64      => x"6e", 
           d_out   => pca_d29_out, en_out  => open, sof_out => open );

PCA64_30_inst: PCA_64 
  generic map(
           mult_sum => mult_sum,
           N        => CL_W,
           M        => PCAweightW,
           in_row   => in_row,
           in_col   => in_col
           )
  port map (
           clk       => clk    ,
           rst       => rst    ,
d01_in    => d01_out, d02_in    => d02_out, d03_in    => d03_out, d04_in    => d04_out, d05_in    => d05_out, d06_in    => d06_out, d07_in    => d07_out, d08_in    => d08_out, 
d09_in    => d09_out, d10_in    => d10_out, d11_in    => d11_out, d12_in    => d12_out, d13_in    => d13_out, d14_in    => d14_out, d15_in    => d15_out, d16_in    => d16_out, 
d17_in    => d17_out, d18_in    => d18_out, d19_in    => d19_out, d20_in    => d20_out, d21_in    => d21_out, d22_in    => d22_out, d23_in    => d23_out, d24_in    => d24_out, 
d25_in    => d25_out, d26_in    => d26_out, d27_in    => d27_out, d28_in    => d28_out, d29_in    => d29_out, d30_in    => d30_out, d31_in    => d31_out, d32_in    => d32_out, 
d33_in    => d33_out, d34_in    => d34_out, d35_in    => d35_out, d36_in    => d36_out, d37_in    => d37_out, d38_in    => d38_out, d39_in    => d39_out, d40_in    => d40_out, 
d41_in    => d41_out, d42_in    => d42_out, d43_in    => d43_out, d44_in    => d44_out, d45_in    => d45_out, d46_in    => d46_out, d47_in    => d47_out, d48_in    => d48_out, 
d49_in    => d49_out, d50_in    => d50_out, d51_in    => d51_out, d52_in    => d52_out, d53_in    => d53_out, d54_in    => d54_out, d55_in    => d55_out, d56_in    => d56_out,
d57_in    => d57_out, d58_in    => d58_out, d59_in    => d59_out, d60_in    => d60_out, d61_in    => d61_out, d62_in    => d62_out, d63_in    => d63_out, d64_in    => d64_out, 
           en_in     => '0',
           sof_in    => '0',

           w01      => x"bd", 
           w02      => x"b0", 
           w03      => x"eb", 
           w04      => x"db", 
           w05      => x"e4", 
           w06      => x"d3", 
           w07      => x"f9", 
           w08      => x"cb", 
           w09      => x"35", 
           w10      => x"67", 
           w11      => x"0b", 
           w12      => x"e4", 
           w13      => x"25", 
           w14      => x"24", 
           w15      => x"5f", 
           w16      => x"b4", 
           w17      => x"c5", 
           w18      => x"bf", 
           w19      => x"91", 
           w20      => x"ea", 
           w21      => x"85", 
           w22      => x"75", 
           w23      => x"82", 
           w24      => x"d6", 
           w25      => x"78", 
           w26      => x"81", 
           w27      => x"75", 
           w28      => x"6a", 
           w29      => x"8f", 
           w30      => x"f8", 
           w31      => x"b9", 
           w32      => x"49", 
           w33      => x"eb", 
           w34      => x"91", 
           w35      => x"fb", 
           w36      => x"29", 
           w37      => x"65", 
           w38      => x"7b", 
           w39      => x"bd", 
           w40      => x"65", 
           w41      => x"de", 
           w42      => x"a8", 
           w43      => x"e4", 
           w44      => x"49", 
           w45      => x"e0", 
           w46      => x"2e", 
           w47      => x"b7", 
           w48      => x"9e", 
           w49      => x"66", 
           w50      => x"83", 
           w51      => x"50", 
           w52      => x"fd", 
           w53      => x"8a", 
           w54      => x"b6", 
           w55      => x"cb", 
           w56      => x"1f", 
           w57      => x"45", 
           w58      => x"a9", 
           w59      => x"6d", 
           w60      => x"45", 
           w61      => x"1e", 
           w62      => x"e3", 
           w63      => x"75", 
           w64      => x"21", 
           d_out   => pca_d30_out, en_out  => open, sof_out => open );

PCA64_31_inst: PCA_64 
  generic map(
           mult_sum => mult_sum,
           N        => CL_W,
           M        => PCAweightW,
           in_row   => in_row,
           in_col   => in_col
           )
  port map (
           clk       => clk    ,
           rst       => rst    ,
d01_in    => d01_out, d02_in    => d02_out, d03_in    => d03_out, d04_in    => d04_out, d05_in    => d05_out, d06_in    => d06_out, d07_in    => d07_out, d08_in    => d08_out, 
d09_in    => d09_out, d10_in    => d10_out, d11_in    => d11_out, d12_in    => d12_out, d13_in    => d13_out, d14_in    => d14_out, d15_in    => d15_out, d16_in    => d16_out, 
d17_in    => d17_out, d18_in    => d18_out, d19_in    => d19_out, d20_in    => d20_out, d21_in    => d21_out, d22_in    => d22_out, d23_in    => d23_out, d24_in    => d24_out, 
d25_in    => d25_out, d26_in    => d26_out, d27_in    => d27_out, d28_in    => d28_out, d29_in    => d29_out, d30_in    => d30_out, d31_in    => d31_out, d32_in    => d32_out, 
d33_in    => d33_out, d34_in    => d34_out, d35_in    => d35_out, d36_in    => d36_out, d37_in    => d37_out, d38_in    => d38_out, d39_in    => d39_out, d40_in    => d40_out, 
d41_in    => d41_out, d42_in    => d42_out, d43_in    => d43_out, d44_in    => d44_out, d45_in    => d45_out, d46_in    => d46_out, d47_in    => d47_out, d48_in    => d48_out, 
d49_in    => d49_out, d50_in    => d50_out, d51_in    => d51_out, d52_in    => d52_out, d53_in    => d53_out, d54_in    => d54_out, d55_in    => d55_out, d56_in    => d56_out,
d57_in    => d57_out, d58_in    => d58_out, d59_in    => d59_out, d60_in    => d60_out, d61_in    => d61_out, d62_in    => d62_out, d63_in    => d63_out, d64_in    => d64_out, 
           en_in     => '0',
           sof_in    => '0',

           w01      => x"3d", 
           w02      => x"22", 
           w03      => x"99", 
           w04      => x"e3", 
           w05      => x"b3", 
           w06      => x"34", 
           w07      => x"5b", 
           w08      => x"f0", 
           w09      => x"25", 
           w10      => x"7b", 
           w11      => x"32", 
           w12      => x"fb", 
           w13      => x"bc", 
           w14      => x"6e", 
           w15      => x"50", 
           w16      => x"b7", 
           w17      => x"76", 
           w18      => x"37", 
           w19      => x"b8", 
           w20      => x"c5", 
           w21      => x"b8", 
           w22      => x"91", 
           w23      => x"56", 
           w24      => x"ad", 
           w25      => x"e7", 
           w26      => x"fc", 
           w27      => x"e4", 
           w28      => x"c6", 
           w29      => x"ec", 
           w30      => x"52", 
           w31      => x"eb", 
           w32      => x"c1", 
           w33      => x"ff", 
           w34      => x"3f", 
           w35      => x"bb", 
           w36      => x"48", 
           w37      => x"22", 
           w38      => x"0f", 
           w39      => x"1f", 
           w40      => x"c2", 
           w41      => x"84", 
           w42      => x"a7", 
           w43      => x"51", 
           w44      => x"8b", 
           w45      => x"2e", 
           w46      => x"e1", 
           w47      => x"eb", 
           w48      => x"41", 
           w49      => x"7f", 
           w50      => x"60", 
           w51      => x"c2", 
           w52      => x"70", 
           w53      => x"75", 
           w54      => x"62", 
           w55      => x"c4", 
           w56      => x"24", 
           w57      => x"92", 
           w58      => x"0e", 
           w59      => x"87", 
           w60      => x"d3", 
           w61      => x"39", 
           w62      => x"a1", 
           w63      => x"0f", 
           w64      => x"f7", 
           d_out   => pca_d31_out, en_out  => open, sof_out => open );

PCA64_32_inst: PCA_64 
  generic map(
           mult_sum => mult_sum,
           N        => CL_W,
           M        => PCAweightW,
           in_row   => in_row,
           in_col   => in_col
           )
  port map (
           clk       => clk    ,
           rst       => rst    ,
d01_in    => d01_out, d02_in    => d02_out, d03_in    => d03_out, d04_in    => d04_out, d05_in    => d05_out, d06_in    => d06_out, d07_in    => d07_out, d08_in    => d08_out, 
d09_in    => d09_out, d10_in    => d10_out, d11_in    => d11_out, d12_in    => d12_out, d13_in    => d13_out, d14_in    => d14_out, d15_in    => d15_out, d16_in    => d16_out, 
d17_in    => d17_out, d18_in    => d18_out, d19_in    => d19_out, d20_in    => d20_out, d21_in    => d21_out, d22_in    => d22_out, d23_in    => d23_out, d24_in    => d24_out, 
d25_in    => d25_out, d26_in    => d26_out, d27_in    => d27_out, d28_in    => d28_out, d29_in    => d29_out, d30_in    => d30_out, d31_in    => d31_out, d32_in    => d32_out, 
d33_in    => d33_out, d34_in    => d34_out, d35_in    => d35_out, d36_in    => d36_out, d37_in    => d37_out, d38_in    => d38_out, d39_in    => d39_out, d40_in    => d40_out, 
d41_in    => d41_out, d42_in    => d42_out, d43_in    => d43_out, d44_in    => d44_out, d45_in    => d45_out, d46_in    => d46_out, d47_in    => d47_out, d48_in    => d48_out, 
d49_in    => d49_out, d50_in    => d50_out, d51_in    => d51_out, d52_in    => d52_out, d53_in    => d53_out, d54_in    => d54_out, d55_in    => d55_out, d56_in    => d56_out,
d57_in    => d57_out, d58_in    => d58_out, d59_in    => d59_out, d60_in    => d60_out, d61_in    => d61_out, d62_in    => d62_out, d63_in    => d63_out, d64_in    => d64_out, 
           en_in     => '0',
           sof_in    => '0',

           w01      => x"c6", 
           w02      => x"4c", 
           w03      => x"6d", 
           w04      => x"9e", 
           w05      => x"1f", 
           w06      => x"b1", 
           w07      => x"f0", 
           w08      => x"44", 
           w09      => x"8c", 
           w10      => x"ff", 
           w11      => x"54", 
           w12      => x"60", 
           w13      => x"80", 
           w14      => x"eb", 
           w15      => x"47", 
           w16      => x"14", 
           w17      => x"15", 
           w18      => x"9c", 
           w19      => x"cd", 
           w20      => x"a1", 
           w21      => x"0c", 
           w22      => x"bd", 
           w23      => x"52", 
           w24      => x"d3", 
           w25      => x"85", 
           w26      => x"70", 
           w27      => x"72", 
           w28      => x"bc", 
           w29      => x"f9", 
           w30      => x"0e", 
           w31      => x"59", 
           w32      => x"96", 
           w33      => x"9e", 
           w34      => x"96", 
           w35      => x"f6", 
           w36      => x"10", 
           w37      => x"dc", 
           w38      => x"ed", 
           w39      => x"fb", 
           w40      => x"4e", 
           w41      => x"55", 
           w42      => x"f8", 
           w43      => x"8b", 
           w44      => x"0d", 
           w45      => x"55", 
           w46      => x"c4", 
           w47      => x"4b", 
           w48      => x"7c", 
           w49      => x"24", 
           w50      => x"db", 
           w51      => x"b6", 
           w52      => x"8f", 
           w53      => x"a5", 
           w54      => x"76", 
           w55      => x"91", 
           w56      => x"39", 
           w57      => x"67", 
           w58      => x"fc", 
           w59      => x"5d", 
           w60      => x"76", 
           w61      => x"cd", 
           w62      => x"30", 
           w63      => x"a0", 
           w64      => x"0a", 
           d_out   => pca_d32_out, en_out  => open, sof_out => open );

PCA64_33_inst: PCA_64 
  generic map(
           mult_sum => mult_sum,
           N        => CL_W,
           M        => PCAweightW,
           in_row   => in_row,
           in_col   => in_col
           )
  port map (
           clk       => clk    ,
           rst       => rst    ,
d01_in    => d01_out, d02_in    => d02_out, d03_in    => d03_out, d04_in    => d04_out, d05_in    => d05_out, d06_in    => d06_out, d07_in    => d07_out, d08_in    => d08_out, 
d09_in    => d09_out, d10_in    => d10_out, d11_in    => d11_out, d12_in    => d12_out, d13_in    => d13_out, d14_in    => d14_out, d15_in    => d15_out, d16_in    => d16_out, 
d17_in    => d17_out, d18_in    => d18_out, d19_in    => d19_out, d20_in    => d20_out, d21_in    => d21_out, d22_in    => d22_out, d23_in    => d23_out, d24_in    => d24_out, 
d25_in    => d25_out, d26_in    => d26_out, d27_in    => d27_out, d28_in    => d28_out, d29_in    => d29_out, d30_in    => d30_out, d31_in    => d31_out, d32_in    => d32_out, 
d33_in    => d33_out, d34_in    => d34_out, d35_in    => d35_out, d36_in    => d36_out, d37_in    => d37_out, d38_in    => d38_out, d39_in    => d39_out, d40_in    => d40_out, 
d41_in    => d41_out, d42_in    => d42_out, d43_in    => d43_out, d44_in    => d44_out, d45_in    => d45_out, d46_in    => d46_out, d47_in    => d47_out, d48_in    => d48_out, 
d49_in    => d49_out, d50_in    => d50_out, d51_in    => d51_out, d52_in    => d52_out, d53_in    => d53_out, d54_in    => d54_out, d55_in    => d55_out, d56_in    => d56_out,
d57_in    => d57_out, d58_in    => d58_out, d59_in    => d59_out, d60_in    => d60_out, d61_in    => d61_out, d62_in    => d62_out, d63_in    => d63_out, d64_in    => d64_out, 
           en_in     => '0',
           sof_in    => '0',

           w01      => x"7d", 
           w02      => x"db", 
           w03      => x"11", 
           w04      => x"9c", 
           w05      => x"42", 
           w06      => x"86", 
           w07      => x"80", 
           w08      => x"6f", 
           w09      => x"c1", 
           w10      => x"08", 
           w11      => x"77", 
           w12      => x"84", 
           w13      => x"5d", 
           w14      => x"b0", 
           w15      => x"43", 
           w16      => x"0f", 
           w17      => x"cf", 
           w18      => x"e4", 
           w19      => x"b4", 
           w20      => x"66", 
           w21      => x"1d", 
           w22      => x"35", 
           w23      => x"f4", 
           w24      => x"16", 
           w25      => x"08", 
           w26      => x"b8", 
           w27      => x"f0", 
           w28      => x"a1", 
           w29      => x"47", 
           w30      => x"3e", 
           w31      => x"5a", 
           w32      => x"91", 
           w33      => x"24", 
           w34      => x"45", 
           w35      => x"80", 
           w36      => x"34", 
           w37      => x"64", 
           w38      => x"3d", 
           w39      => x"96", 
           w40      => x"3c", 
           w41      => x"5c", 
           w42      => x"f4", 
           w43      => x"dc", 
           w44      => x"f3", 
           w45      => x"db", 
           w46      => x"09", 
           w47      => x"78", 
           w48      => x"a0", 
           w49      => x"0c", 
           w50      => x"3d", 
           w51      => x"83", 
           w52      => x"92", 
           w53      => x"43", 
           w54      => x"c6", 
           w55      => x"ef", 
           w56      => x"42", 
           w57      => x"c7", 
           w58      => x"5d", 
           w59      => x"dc", 
           w60      => x"8d", 
           w61      => x"30", 
           w62      => x"20", 
           w63      => x"93", 
           w64      => x"0b", 
           d_out   => pca_d33_out, en_out  => open, sof_out => open );

PCA64_34_inst: PCA_64 
  generic map(
           mult_sum => mult_sum,
           N        => CL_W,
           M        => PCAweightW,
           in_row   => in_row,
           in_col   => in_col
           )
  port map (
           clk       => clk    ,
           rst       => rst    ,
d01_in    => d01_out, d02_in    => d02_out, d03_in    => d03_out, d04_in    => d04_out, d05_in    => d05_out, d06_in    => d06_out, d07_in    => d07_out, d08_in    => d08_out, 
d09_in    => d09_out, d10_in    => d10_out, d11_in    => d11_out, d12_in    => d12_out, d13_in    => d13_out, d14_in    => d14_out, d15_in    => d15_out, d16_in    => d16_out, 
d17_in    => d17_out, d18_in    => d18_out, d19_in    => d19_out, d20_in    => d20_out, d21_in    => d21_out, d22_in    => d22_out, d23_in    => d23_out, d24_in    => d24_out, 
d25_in    => d25_out, d26_in    => d26_out, d27_in    => d27_out, d28_in    => d28_out, d29_in    => d29_out, d30_in    => d30_out, d31_in    => d31_out, d32_in    => d32_out, 
d33_in    => d33_out, d34_in    => d34_out, d35_in    => d35_out, d36_in    => d36_out, d37_in    => d37_out, d38_in    => d38_out, d39_in    => d39_out, d40_in    => d40_out, 
d41_in    => d41_out, d42_in    => d42_out, d43_in    => d43_out, d44_in    => d44_out, d45_in    => d45_out, d46_in    => d46_out, d47_in    => d47_out, d48_in    => d48_out, 
d49_in    => d49_out, d50_in    => d50_out, d51_in    => d51_out, d52_in    => d52_out, d53_in    => d53_out, d54_in    => d54_out, d55_in    => d55_out, d56_in    => d56_out,
d57_in    => d57_out, d58_in    => d58_out, d59_in    => d59_out, d60_in    => d60_out, d61_in    => d61_out, d62_in    => d62_out, d63_in    => d63_out, d64_in    => d64_out, 
           en_in     => '0',
           sof_in    => '0',

           w01      => x"8c", 
           w02      => x"68", 
           w03      => x"33", 
           w04      => x"51", 
           w05      => x"0d", 
           w06      => x"fe", 
           w07      => x"58", 
           w08      => x"ac", 
           w09      => x"9e", 
           w10      => x"84", 
           w11      => x"84", 
           w12      => x"8d", 
           w13      => x"fb", 
           w14      => x"1f", 
           w15      => x"a1", 
           w16      => x"eb", 
           w17      => x"64", 
           w18      => x"31", 
           w19      => x"ad", 
           w20      => x"32", 
           w21      => x"cd", 
           w22      => x"1e", 
           w23      => x"7f", 
           w24      => x"ec", 
           w25      => x"e8", 
           w26      => x"6a", 
           w27      => x"c7", 
           w28      => x"62", 
           w29      => x"6f", 
           w30      => x"17", 
           w31      => x"54", 
           w32      => x"87", 
           w33      => x"6c", 
           w34      => x"7a", 
           w35      => x"c9", 
           w36      => x"ba", 
           w37      => x"40", 
           w38      => x"ae", 
           w39      => x"38", 
           w40      => x"58", 
           w41      => x"fe", 
           w42      => x"a6", 
           w43      => x"60", 
           w44      => x"15", 
           w45      => x"40", 
           w46      => x"b9", 
           w47      => x"78", 
           w48      => x"30", 
           w49      => x"11", 
           w50      => x"c5", 
           w51      => x"1e", 
           w52      => x"b6", 
           w53      => x"69", 
           w54      => x"99", 
           w55      => x"a3", 
           w56      => x"10", 
           w57      => x"b0", 
           w58      => x"be", 
           w59      => x"50", 
           w60      => x"4c", 
           w61      => x"2f", 
           w62      => x"96", 
           w63      => x"74", 
           w64      => x"85", 
           d_out   => pca_d34_out, en_out  => open, sof_out => open );

PCA64_35_inst: PCA_64 
  generic map(
           mult_sum => mult_sum,
           N        => CL_W,
           M        => PCAweightW,
           in_row   => in_row,
           in_col   => in_col
           )
  port map (
           clk       => clk    ,
           rst       => rst    ,
d01_in    => d01_out, d02_in    => d02_out, d03_in    => d03_out, d04_in    => d04_out, d05_in    => d05_out, d06_in    => d06_out, d07_in    => d07_out, d08_in    => d08_out, 
d09_in    => d09_out, d10_in    => d10_out, d11_in    => d11_out, d12_in    => d12_out, d13_in    => d13_out, d14_in    => d14_out, d15_in    => d15_out, d16_in    => d16_out, 
d17_in    => d17_out, d18_in    => d18_out, d19_in    => d19_out, d20_in    => d20_out, d21_in    => d21_out, d22_in    => d22_out, d23_in    => d23_out, d24_in    => d24_out, 
d25_in    => d25_out, d26_in    => d26_out, d27_in    => d27_out, d28_in    => d28_out, d29_in    => d29_out, d30_in    => d30_out, d31_in    => d31_out, d32_in    => d32_out, 
d33_in    => d33_out, d34_in    => d34_out, d35_in    => d35_out, d36_in    => d36_out, d37_in    => d37_out, d38_in    => d38_out, d39_in    => d39_out, d40_in    => d40_out, 
d41_in    => d41_out, d42_in    => d42_out, d43_in    => d43_out, d44_in    => d44_out, d45_in    => d45_out, d46_in    => d46_out, d47_in    => d47_out, d48_in    => d48_out, 
d49_in    => d49_out, d50_in    => d50_out, d51_in    => d51_out, d52_in    => d52_out, d53_in    => d53_out, d54_in    => d54_out, d55_in    => d55_out, d56_in    => d56_out,
d57_in    => d57_out, d58_in    => d58_out, d59_in    => d59_out, d60_in    => d60_out, d61_in    => d61_out, d62_in    => d62_out, d63_in    => d63_out, d64_in    => d64_out, 
           en_in     => '0',
           sof_in    => '0',

           w01      => x"b4", 
           w02      => x"f5", 
           w03      => x"66", 
           w04      => x"95", 
           w05      => x"a0", 
           w06      => x"de", 
           w07      => x"4a", 
           w08      => x"da", 
           w09      => x"61", 
           w10      => x"f2", 
           w11      => x"8b", 
           w12      => x"4c", 
           w13      => x"92", 
           w14      => x"81", 
           w15      => x"8b", 
           w16      => x"ba", 
           w17      => x"67", 
           w18      => x"75", 
           w19      => x"5a", 
           w20      => x"65", 
           w21      => x"da", 
           w22      => x"5c", 
           w23      => x"cf", 
           w24      => x"3e", 
           w25      => x"ba", 
           w26      => x"93", 
           w27      => x"2b", 
           w28      => x"9c", 
           w29      => x"b9", 
           w30      => x"77", 
           w31      => x"ee", 
           w32      => x"61", 
           w33      => x"fc", 
           w34      => x"70", 
           w35      => x"de", 
           w36      => x"e0", 
           w37      => x"2a", 
           w38      => x"c7", 
           w39      => x"75", 
           w40      => x"dd", 
           w41      => x"c3", 
           w42      => x"5f", 
           w43      => x"e3", 
           w44      => x"75", 
           w45      => x"0f", 
           w46      => x"d3", 
           w47      => x"be", 
           w48      => x"7e", 
           w49      => x"c1", 
           w50      => x"b8", 
           w51      => x"42", 
           w52      => x"2f", 
           w53      => x"8b", 
           w54      => x"2b", 
           w55      => x"4c", 
           w56      => x"c0", 
           w57      => x"a1", 
           w58      => x"bf", 
           w59      => x"fc", 
           w60      => x"10", 
           w61      => x"78", 
           w62      => x"bf", 
           w63      => x"ae", 
           w64      => x"14", 
           d_out   => pca_d35_out, en_out  => open, sof_out => open );

PCA64_36_inst: PCA_64 
  generic map(
           mult_sum => mult_sum,
           N        => CL_W,
           M        => PCAweightW,
           in_row   => in_row,
           in_col   => in_col
           )
  port map (
           clk       => clk    ,
           rst       => rst    ,
d01_in    => d01_out, d02_in    => d02_out, d03_in    => d03_out, d04_in    => d04_out, d05_in    => d05_out, d06_in    => d06_out, d07_in    => d07_out, d08_in    => d08_out, 
d09_in    => d09_out, d10_in    => d10_out, d11_in    => d11_out, d12_in    => d12_out, d13_in    => d13_out, d14_in    => d14_out, d15_in    => d15_out, d16_in    => d16_out, 
d17_in    => d17_out, d18_in    => d18_out, d19_in    => d19_out, d20_in    => d20_out, d21_in    => d21_out, d22_in    => d22_out, d23_in    => d23_out, d24_in    => d24_out, 
d25_in    => d25_out, d26_in    => d26_out, d27_in    => d27_out, d28_in    => d28_out, d29_in    => d29_out, d30_in    => d30_out, d31_in    => d31_out, d32_in    => d32_out, 
d33_in    => d33_out, d34_in    => d34_out, d35_in    => d35_out, d36_in    => d36_out, d37_in    => d37_out, d38_in    => d38_out, d39_in    => d39_out, d40_in    => d40_out, 
d41_in    => d41_out, d42_in    => d42_out, d43_in    => d43_out, d44_in    => d44_out, d45_in    => d45_out, d46_in    => d46_out, d47_in    => d47_out, d48_in    => d48_out, 
d49_in    => d49_out, d50_in    => d50_out, d51_in    => d51_out, d52_in    => d52_out, d53_in    => d53_out, d54_in    => d54_out, d55_in    => d55_out, d56_in    => d56_out,
d57_in    => d57_out, d58_in    => d58_out, d59_in    => d59_out, d60_in    => d60_out, d61_in    => d61_out, d62_in    => d62_out, d63_in    => d63_out, d64_in    => d64_out, 
           en_in     => '0',
           sof_in    => '0',

           w01      => x"65", 
           w02      => x"33", 
           w03      => x"93", 
           w04      => x"73", 
           w05      => x"32", 
           w06      => x"40", 
           w07      => x"54", 
           w08      => x"0d", 
           w09      => x"3a", 
           w10      => x"66", 
           w11      => x"7e", 
           w12      => x"30", 
           w13      => x"48", 
           w14      => x"93", 
           w15      => x"ae", 
           w16      => x"e4", 
           w17      => x"3d", 
           w18      => x"66", 
           w19      => x"4f", 
           w20      => x"d5", 
           w21      => x"66", 
           w22      => x"fd", 
           w23      => x"fd", 
           w24      => x"3b", 
           w25      => x"5b", 
           w26      => x"94", 
           w27      => x"3a", 
           w28      => x"4a", 
           w29      => x"36", 
           w30      => x"f1", 
           w31      => x"44", 
           w32      => x"9e", 
           w33      => x"78", 
           w34      => x"13", 
           w35      => x"19", 
           w36      => x"31", 
           w37      => x"9b", 
           w38      => x"f4", 
           w39      => x"f6", 
           w40      => x"4d", 
           w41      => x"3f", 
           w42      => x"c1", 
           w43      => x"bb", 
           w44      => x"e7", 
           w45      => x"21", 
           w46      => x"e3", 
           w47      => x"44", 
           w48      => x"9c", 
           w49      => x"d9", 
           w50      => x"97", 
           w51      => x"a2", 
           w52      => x"88", 
           w53      => x"38", 
           w54      => x"ef", 
           w55      => x"ae", 
           w56      => x"93", 
           w57      => x"ef", 
           w58      => x"e2", 
           w59      => x"eb", 
           w60      => x"30", 
           w61      => x"a6", 
           w62      => x"b8", 
           w63      => x"c6", 
           w64      => x"d1", 
           d_out   => pca_d36_out, en_out  => open, sof_out => open );

PCA64_37_inst: PCA_64 
  generic map(
           mult_sum => mult_sum,
           N        => CL_W,
           M        => PCAweightW,
           in_row   => in_row,
           in_col   => in_col
           )
  port map (
           clk       => clk    ,
           rst       => rst    ,
d01_in    => d01_out, d02_in    => d02_out, d03_in    => d03_out, d04_in    => d04_out, d05_in    => d05_out, d06_in    => d06_out, d07_in    => d07_out, d08_in    => d08_out, 
d09_in    => d09_out, d10_in    => d10_out, d11_in    => d11_out, d12_in    => d12_out, d13_in    => d13_out, d14_in    => d14_out, d15_in    => d15_out, d16_in    => d16_out, 
d17_in    => d17_out, d18_in    => d18_out, d19_in    => d19_out, d20_in    => d20_out, d21_in    => d21_out, d22_in    => d22_out, d23_in    => d23_out, d24_in    => d24_out, 
d25_in    => d25_out, d26_in    => d26_out, d27_in    => d27_out, d28_in    => d28_out, d29_in    => d29_out, d30_in    => d30_out, d31_in    => d31_out, d32_in    => d32_out, 
d33_in    => d33_out, d34_in    => d34_out, d35_in    => d35_out, d36_in    => d36_out, d37_in    => d37_out, d38_in    => d38_out, d39_in    => d39_out, d40_in    => d40_out, 
d41_in    => d41_out, d42_in    => d42_out, d43_in    => d43_out, d44_in    => d44_out, d45_in    => d45_out, d46_in    => d46_out, d47_in    => d47_out, d48_in    => d48_out, 
d49_in    => d49_out, d50_in    => d50_out, d51_in    => d51_out, d52_in    => d52_out, d53_in    => d53_out, d54_in    => d54_out, d55_in    => d55_out, d56_in    => d56_out,
d57_in    => d57_out, d58_in    => d58_out, d59_in    => d59_out, d60_in    => d60_out, d61_in    => d61_out, d62_in    => d62_out, d63_in    => d63_out, d64_in    => d64_out, 
           en_in     => '0',
           sof_in    => '0',

           w01      => x"6b", 
           w02      => x"55", 
           w03      => x"f0", 
           w04      => x"a5", 
           w05      => x"da", 
           w06      => x"86", 
           w07      => x"23", 
           w08      => x"4f", 
           w09      => x"21", 
           w10      => x"5d", 
           w11      => x"ee", 
           w12      => x"8e", 
           w13      => x"eb", 
           w14      => x"ed", 
           w15      => x"99", 
           w16      => x"e0", 
           w17      => x"6e", 
           w18      => x"7a", 
           w19      => x"42", 
           w20      => x"21", 
           w21      => x"fe", 
           w22      => x"d6", 
           w23      => x"cd", 
           w24      => x"36", 
           w25      => x"3f", 
           w26      => x"61", 
           w27      => x"2d", 
           w28      => x"94", 
           w29      => x"d2", 
           w30      => x"46", 
           w31      => x"4e", 
           w32      => x"f0", 
           w33      => x"19", 
           w34      => x"90", 
           w35      => x"54", 
           w36      => x"65", 
           w37      => x"fe", 
           w38      => x"13", 
           w39      => x"f0", 
           w40      => x"a1", 
           w41      => x"ba", 
           w42      => x"5c", 
           w43      => x"59", 
           w44      => x"76", 
           w45      => x"8f", 
           w46      => x"50", 
           w47      => x"92", 
           w48      => x"c9", 
           w49      => x"0f", 
           w50      => x"b7", 
           w51      => x"52", 
           w52      => x"97", 
           w53      => x"cf", 
           w54      => x"b5", 
           w55      => x"ee", 
           w56      => x"3f", 
           w57      => x"a1", 
           w58      => x"cd", 
           w59      => x"f5", 
           w60      => x"7d", 
           w61      => x"90", 
           w62      => x"3c", 
           w63      => x"46", 
           w64      => x"ca", 
           d_out   => pca_d37_out, en_out  => open, sof_out => open );


PCA64_38_inst: PCA_64 
  generic map(
           mult_sum => mult_sum,
           N        => CL_W,
           M        => PCAweightW,
           in_row   => in_row,
           in_col   => in_col
           )
  port map (
           clk       => clk    ,
           rst       => rst    ,
d01_in    => d01_out, d02_in    => d02_out, d03_in    => d03_out, d04_in    => d04_out, d05_in    => d05_out, d06_in    => d06_out, d07_in    => d07_out, d08_in    => d08_out, 
d09_in    => d09_out, d10_in    => d10_out, d11_in    => d11_out, d12_in    => d12_out, d13_in    => d13_out, d14_in    => d14_out, d15_in    => d15_out, d16_in    => d16_out, 
d17_in    => d17_out, d18_in    => d18_out, d19_in    => d19_out, d20_in    => d20_out, d21_in    => d21_out, d22_in    => d22_out, d23_in    => d23_out, d24_in    => d24_out, 
d25_in    => d25_out, d26_in    => d26_out, d27_in    => d27_out, d28_in    => d28_out, d29_in    => d29_out, d30_in    => d30_out, d31_in    => d31_out, d32_in    => d32_out, 
d33_in    => d33_out, d34_in    => d34_out, d35_in    => d35_out, d36_in    => d36_out, d37_in    => d37_out, d38_in    => d38_out, d39_in    => d39_out, d40_in    => d40_out, 
d41_in    => d41_out, d42_in    => d42_out, d43_in    => d43_out, d44_in    => d44_out, d45_in    => d45_out, d46_in    => d46_out, d47_in    => d47_out, d48_in    => d48_out, 
d49_in    => d49_out, d50_in    => d50_out, d51_in    => d51_out, d52_in    => d52_out, d53_in    => d53_out, d54_in    => d54_out, d55_in    => d55_out, d56_in    => d56_out,
d57_in    => d57_out, d58_in    => d58_out, d59_in    => d59_out, d60_in    => d60_out, d61_in    => d61_out, d62_in    => d62_out, d63_in    => d63_out, d64_in    => d64_out, 
           en_in     => '0',
           sof_in    => '0',

           w01      => x"a6", 
           w02      => x"90", 
           w03      => x"70", 
           w04      => x"81", 
           w05      => x"34", 
           w06      => x"9d", 
           w07      => x"97", 
           w08      => x"ab", 
           w09      => x"0f", 
           w10      => x"43", 
           w11      => x"e9", 
           w12      => x"c3", 
           w13      => x"b9", 
           w14      => x"40", 
           w15      => x"a4", 
           w16      => x"4f", 
           w17      => x"f0", 
           w18      => x"32", 
           w19      => x"94", 
           w20      => x"8d", 
           w21      => x"e0", 
           w22      => x"d7", 
           w23      => x"70", 
           w24      => x"f3", 
           w25      => x"18", 
           w26      => x"ee", 
           w27      => x"bb", 
           w28      => x"68", 
           w29      => x"9e", 
           w30      => x"3e", 
           w31      => x"24", 
           w32      => x"1d", 
           w33      => x"e0", 
           w34      => x"a1", 
           w35      => x"30", 
           w36      => x"29", 
           w37      => x"ce", 
           w38      => x"8f", 
           w39      => x"8c", 
           w40      => x"d4", 
           w41      => x"2b", 
           w42      => x"f7", 
           w43      => x"dd", 
           w44      => x"c3", 
           w45      => x"ac", 
           w46      => x"52", 
           w47      => x"ca", 
           w48      => x"60", 
           w49      => x"e6", 
           w50      => x"90", 
           w51      => x"ad", 
           w52      => x"40", 
           w53      => x"71", 
           w54      => x"ed", 
           w55      => x"d6", 
           w56      => x"c0", 
           w57      => x"c4", 
           w58      => x"d9", 
           w59      => x"5a", 
           w60      => x"0c", 
           w61      => x"2b", 
           w62      => x"24", 
           w63      => x"f9", 
           w64      => x"4b", 
           d_out   => pca_d38_out, en_out  => open, sof_out => open );

PCA64_39_inst: PCA_64 
  generic map(
           mult_sum => mult_sum,
           N        => CL_W,
           M        => PCAweightW,
           in_row   => in_row,
           in_col   => in_col
           )
  port map (
           clk       => clk    ,
           rst       => rst    ,
d01_in    => d01_out, d02_in    => d02_out, d03_in    => d03_out, d04_in    => d04_out, d05_in    => d05_out, d06_in    => d06_out, d07_in    => d07_out, d08_in    => d08_out, 
d09_in    => d09_out, d10_in    => d10_out, d11_in    => d11_out, d12_in    => d12_out, d13_in    => d13_out, d14_in    => d14_out, d15_in    => d15_out, d16_in    => d16_out, 
d17_in    => d17_out, d18_in    => d18_out, d19_in    => d19_out, d20_in    => d20_out, d21_in    => d21_out, d22_in    => d22_out, d23_in    => d23_out, d24_in    => d24_out, 
d25_in    => d25_out, d26_in    => d26_out, d27_in    => d27_out, d28_in    => d28_out, d29_in    => d29_out, d30_in    => d30_out, d31_in    => d31_out, d32_in    => d32_out, 
d33_in    => d33_out, d34_in    => d34_out, d35_in    => d35_out, d36_in    => d36_out, d37_in    => d37_out, d38_in    => d38_out, d39_in    => d39_out, d40_in    => d40_out, 
d41_in    => d41_out, d42_in    => d42_out, d43_in    => d43_out, d44_in    => d44_out, d45_in    => d45_out, d46_in    => d46_out, d47_in    => d47_out, d48_in    => d48_out, 
d49_in    => d49_out, d50_in    => d50_out, d51_in    => d51_out, d52_in    => d52_out, d53_in    => d53_out, d54_in    => d54_out, d55_in    => d55_out, d56_in    => d56_out,
d57_in    => d57_out, d58_in    => d58_out, d59_in    => d59_out, d60_in    => d60_out, d61_in    => d61_out, d62_in    => d62_out, d63_in    => d63_out, d64_in    => d64_out, 
           en_in     => '0',
           sof_in    => '0',

           w01      => x"38", 
           w02      => x"42", 
           w03      => x"c6", 
           w04      => x"55", 
           w05      => x"65", 
           w06      => x"d8", 
           w07      => x"cd", 
           w08      => x"39", 
           w09      => x"5d", 
           w10      => x"1b", 
           w11      => x"ce", 
           w12      => x"8d", 
           w13      => x"57", 
           w14      => x"b8", 
           w15      => x"b2", 
           w16      => x"63", 
           w17      => x"ac", 
           w18      => x"df", 
           w19      => x"e4", 
           w20      => x"a4", 
           w21      => x"65", 
           w22      => x"71", 
           w23      => x"94", 
           w24      => x"70", 
           w25      => x"20", 
           w26      => x"29", 
           w27      => x"e5", 
           w28      => x"6a", 
           w29      => x"c1", 
           w30      => x"3f", 
           w31      => x"b1", 
           w32      => x"53", 
           w33      => x"c3", 
           w34      => x"37", 
           w35      => x"bc", 
           w36      => x"83", 
           w37      => x"a5", 
           w38      => x"c8", 
           w39      => x"0c", 
           w40      => x"df", 
           w41      => x"cd", 
           w42      => x"c5", 
           w43      => x"bb", 
           w44      => x"32", 
           w45      => x"12", 
           w46      => x"ca", 
           w47      => x"27", 
           w48      => x"57", 
           w49      => x"a3", 
           w50      => x"53", 
           w51      => x"78", 
           w52      => x"7a", 
           w53      => x"71", 
           w54      => x"9a", 
           w55      => x"30", 
           w56      => x"78", 
           w57      => x"8c", 
           w58      => x"8d", 
           w59      => x"79", 
           w60      => x"cd", 
           w61      => x"b3", 
           w62      => x"08", 
           w63      => x"98", 
           w64      => x"d8", 
           d_out   => pca_d39_out, en_out  => open, sof_out => open );

PCA64_40_inst: PCA_64 
  generic map(
           mult_sum => mult_sum,
           N        => CL_W,
           M        => PCAweightW,
           in_row   => in_row,
           in_col   => in_col
           )
  port map (
           clk       => clk    ,
           rst       => rst    ,
d01_in    => d01_out, d02_in    => d02_out, d03_in    => d03_out, d04_in    => d04_out, d05_in    => d05_out, d06_in    => d06_out, d07_in    => d07_out, d08_in    => d08_out, 
d09_in    => d09_out, d10_in    => d10_out, d11_in    => d11_out, d12_in    => d12_out, d13_in    => d13_out, d14_in    => d14_out, d15_in    => d15_out, d16_in    => d16_out, 
d17_in    => d17_out, d18_in    => d18_out, d19_in    => d19_out, d20_in    => d20_out, d21_in    => d21_out, d22_in    => d22_out, d23_in    => d23_out, d24_in    => d24_out, 
d25_in    => d25_out, d26_in    => d26_out, d27_in    => d27_out, d28_in    => d28_out, d29_in    => d29_out, d30_in    => d30_out, d31_in    => d31_out, d32_in    => d32_out, 
d33_in    => d33_out, d34_in    => d34_out, d35_in    => d35_out, d36_in    => d36_out, d37_in    => d37_out, d38_in    => d38_out, d39_in    => d39_out, d40_in    => d40_out, 
d41_in    => d41_out, d42_in    => d42_out, d43_in    => d43_out, d44_in    => d44_out, d45_in    => d45_out, d46_in    => d46_out, d47_in    => d47_out, d48_in    => d48_out, 
d49_in    => d49_out, d50_in    => d50_out, d51_in    => d51_out, d52_in    => d52_out, d53_in    => d53_out, d54_in    => d54_out, d55_in    => d55_out, d56_in    => d56_out,
d57_in    => d57_out, d58_in    => d58_out, d59_in    => d59_out, d60_in    => d60_out, d61_in    => d61_out, d62_in    => d62_out, d63_in    => d63_out, d64_in    => d64_out, 
           en_in     => '0',
           sof_in    => '0',

           w01      => x"74", 
           w02      => x"29", 
           w03      => x"d0", 
           w04      => x"35", 
           w05      => x"cd", 
           w06      => x"81", 
           w07      => x"8f", 
           w08      => x"6d", 
           w09      => x"49", 
           w10      => x"08", 
           w11      => x"33", 
           w12      => x"9a", 
           w13      => x"6d", 
           w14      => x"42", 
           w15      => x"bb", 
           w16      => x"b8", 
           w17      => x"72", 
           w18      => x"51", 
           w19      => x"a6", 
           w20      => x"97", 
           w21      => x"30", 
           w22      => x"17", 
           w23      => x"07", 
           w24      => x"40", 
           w25      => x"d7", 
           w26      => x"0d", 
           w27      => x"d8", 
           w28      => x"48", 
           w29      => x"cb", 
           w30      => x"58", 
           w31      => x"61", 
           w32      => x"89", 
           w33      => x"a8", 
           w34      => x"85", 
           w35      => x"a0", 
           w36      => x"b3", 
           w37      => x"f1", 
           w38      => x"33", 
           w39      => x"87", 
           w40      => x"f6", 
           w41      => x"9e", 
           w42      => x"0f", 
           w43      => x"35", 
           w44      => x"1b", 
           w45      => x"8d", 
           w46      => x"5a", 
           w47      => x"63", 
           w48      => x"13", 
           w49      => x"ce", 
           w50      => x"f8", 
           w51      => x"c4", 
           w52      => x"67", 
           w53      => x"9e", 
           w54      => x"12", 
           w55      => x"53", 
           w56      => x"bb", 
           w57      => x"f0", 
           w58      => x"ff", 
           w59      => x"0d", 
           w60      => x"af", 
           w61      => x"27", 
           w62      => x"1a", 
           w63      => x"52", 
           w64      => x"4f", 
           d_out   => pca_d40_out, en_out  => open, sof_out => open );

PCA64_41_inst: PCA_64 
  generic map(
           mult_sum => mult_sum,
           N        => CL_W,
           M        => PCAweightW,
           in_row   => in_row,
           in_col   => in_col
           )
  port map (
           clk       => clk    ,
           rst       => rst    ,
d01_in    => d01_out, d02_in    => d02_out, d03_in    => d03_out, d04_in    => d04_out, d05_in    => d05_out, d06_in    => d06_out, d07_in    => d07_out, d08_in    => d08_out, 
d09_in    => d09_out, d10_in    => d10_out, d11_in    => d11_out, d12_in    => d12_out, d13_in    => d13_out, d14_in    => d14_out, d15_in    => d15_out, d16_in    => d16_out, 
d17_in    => d17_out, d18_in    => d18_out, d19_in    => d19_out, d20_in    => d20_out, d21_in    => d21_out, d22_in    => d22_out, d23_in    => d23_out, d24_in    => d24_out, 
d25_in    => d25_out, d26_in    => d26_out, d27_in    => d27_out, d28_in    => d28_out, d29_in    => d29_out, d30_in    => d30_out, d31_in    => d31_out, d32_in    => d32_out, 
d33_in    => d33_out, d34_in    => d34_out, d35_in    => d35_out, d36_in    => d36_out, d37_in    => d37_out, d38_in    => d38_out, d39_in    => d39_out, d40_in    => d40_out, 
d41_in    => d41_out, d42_in    => d42_out, d43_in    => d43_out, d44_in    => d44_out, d45_in    => d45_out, d46_in    => d46_out, d47_in    => d47_out, d48_in    => d48_out, 
d49_in    => d49_out, d50_in    => d50_out, d51_in    => d51_out, d52_in    => d52_out, d53_in    => d53_out, d54_in    => d54_out, d55_in    => d55_out, d56_in    => d56_out,
d57_in    => d57_out, d58_in    => d58_out, d59_in    => d59_out, d60_in    => d60_out, d61_in    => d61_out, d62_in    => d62_out, d63_in    => d63_out, d64_in    => d64_out, 
           en_in     => '0',
           sof_in    => '0',

           w01      => x"23", 
           w02      => x"89", 
           w03      => x"4e", 
           w04      => x"0f", 
           w05      => x"94", 
           w06      => x"4c", 
           w07      => x"6e", 
           w08      => x"e1", 
           w09      => x"71", 
           w10      => x"b8", 
           w11      => x"b5", 
           w12      => x"fe", 
           w13      => x"0a", 
           w14      => x"e1", 
           w15      => x"22", 
           w16      => x"a4", 
           w17      => x"a1", 
           w18      => x"95", 
           w19      => x"4b", 
           w20      => x"b7", 
           w21      => x"d9", 
           w22      => x"7d", 
           w23      => x"6d", 
           w24      => x"9a", 
           w25      => x"ec", 
           w26      => x"1d", 
           w27      => x"85", 
           w28      => x"c4", 
           w29      => x"74", 
           w30      => x"8f", 
           w31      => x"9e", 
           w32      => x"16", 
           w33      => x"07", 
           w34      => x"0a", 
           w35      => x"36", 
           w36      => x"78", 
           w37      => x"8b", 
           w38      => x"08", 
           w39      => x"d5", 
           w40      => x"fa", 
           w41      => x"0d", 
           w42      => x"10", 
           w43      => x"11", 
           w44      => x"20", 
           w45      => x"d4", 
           w46      => x"65", 
           w47      => x"6b", 
           w48      => x"0e", 
           w49      => x"fb", 
           w50      => x"73", 
           w51      => x"19", 
           w52      => x"45", 
           w53      => x"39", 
           w54      => x"e2", 
           w55      => x"d3", 
           w56      => x"14", 
           w57      => x"43", 
           w58      => x"73", 
           w59      => x"59", 
           w60      => x"ea", 
           w61      => x"f8", 
           w62      => x"a5", 
           w63      => x"c0", 
           w64      => x"81", 
           d_out   => pca_d41_out, en_out  => open, sof_out => open );

PCA64_42_inst: PCA_64 
  generic map(
           mult_sum => mult_sum,
           N        => CL_W,
           M        => PCAweightW,
           in_row   => in_row,
           in_col   => in_col
           )
  port map (
           clk       => clk    ,
           rst       => rst    ,
d01_in    => d01_out, d02_in    => d02_out, d03_in    => d03_out, d04_in    => d04_out, d05_in    => d05_out, d06_in    => d06_out, d07_in    => d07_out, d08_in    => d08_out, 
d09_in    => d09_out, d10_in    => d10_out, d11_in    => d11_out, d12_in    => d12_out, d13_in    => d13_out, d14_in    => d14_out, d15_in    => d15_out, d16_in    => d16_out, 
d17_in    => d17_out, d18_in    => d18_out, d19_in    => d19_out, d20_in    => d20_out, d21_in    => d21_out, d22_in    => d22_out, d23_in    => d23_out, d24_in    => d24_out, 
d25_in    => d25_out, d26_in    => d26_out, d27_in    => d27_out, d28_in    => d28_out, d29_in    => d29_out, d30_in    => d30_out, d31_in    => d31_out, d32_in    => d32_out, 
d33_in    => d33_out, d34_in    => d34_out, d35_in    => d35_out, d36_in    => d36_out, d37_in    => d37_out, d38_in    => d38_out, d39_in    => d39_out, d40_in    => d40_out, 
d41_in    => d41_out, d42_in    => d42_out, d43_in    => d43_out, d44_in    => d44_out, d45_in    => d45_out, d46_in    => d46_out, d47_in    => d47_out, d48_in    => d48_out, 
d49_in    => d49_out, d50_in    => d50_out, d51_in    => d51_out, d52_in    => d52_out, d53_in    => d53_out, d54_in    => d54_out, d55_in    => d55_out, d56_in    => d56_out,
d57_in    => d57_out, d58_in    => d58_out, d59_in    => d59_out, d60_in    => d60_out, d61_in    => d61_out, d62_in    => d62_out, d63_in    => d63_out, d64_in    => d64_out, 
           en_in     => '0',
           sof_in    => '0',

           w01      => x"42", 
           w02      => x"77", 
           w03      => x"99", 
           w04      => x"25", 
           w05      => x"74", 
           w06      => x"71", 
           w07      => x"cc", 
           w08      => x"c5", 
           w09      => x"9c", 
           w10      => x"9b", 
           w11      => x"36", 
           w12      => x"c1", 
           w13      => x"95", 
           w14      => x"7b", 
           w15      => x"19", 
           w16      => x"22", 
           w17      => x"84", 
           w18      => x"35", 
           w19      => x"8f", 
           w20      => x"dd", 
           w21      => x"b9", 
           w22      => x"80", 
           w23      => x"36", 
           w24      => x"97", 
           w25      => x"d0", 
           w26      => x"8c", 
           w27      => x"0f", 
           w28      => x"3e", 
           w29      => x"9d", 
           w30      => x"1f", 
           w31      => x"fd", 
           w32      => x"9f", 
           w33      => x"14", 
           w34      => x"1b", 
           w35      => x"23", 
           w36      => x"1b", 
           w37      => x"a8", 
           w38      => x"bf", 
           w39      => x"3c", 
           w40      => x"50", 
           w41      => x"24", 
           w42      => x"c4", 
           w43      => x"2b", 
           w44      => x"7e", 
           w45      => x"d9", 
           w46      => x"70", 
           w47      => x"99", 
           w48      => x"c2", 
           w49      => x"0a", 
           w50      => x"85", 
           w51      => x"6a", 
           w52      => x"f0", 
           w53      => x"17", 
           w54      => x"50", 
           w55      => x"9b", 
           w56      => x"59", 
           w57      => x"b5", 
           w58      => x"36", 
           w59      => x"08", 
           w60      => x"fc", 
           w61      => x"82", 
           w62      => x"86", 
           w63      => x"4d", 
           w64      => x"74", 
           d_out   => pca_d42_out, en_out  => open, sof_out => open );

PCA64_43_inst: PCA_64 
  generic map(
           mult_sum => mult_sum,
           N        => CL_W,
           M        => PCAweightW,
           in_row   => in_row,
           in_col   => in_col
           )
  port map (
           clk       => clk    ,
           rst       => rst    ,
d01_in    => d01_out, d02_in    => d02_out, d03_in    => d03_out, d04_in    => d04_out, d05_in    => d05_out, d06_in    => d06_out, d07_in    => d07_out, d08_in    => d08_out, 
d09_in    => d09_out, d10_in    => d10_out, d11_in    => d11_out, d12_in    => d12_out, d13_in    => d13_out, d14_in    => d14_out, d15_in    => d15_out, d16_in    => d16_out, 
d17_in    => d17_out, d18_in    => d18_out, d19_in    => d19_out, d20_in    => d20_out, d21_in    => d21_out, d22_in    => d22_out, d23_in    => d23_out, d24_in    => d24_out, 
d25_in    => d25_out, d26_in    => d26_out, d27_in    => d27_out, d28_in    => d28_out, d29_in    => d29_out, d30_in    => d30_out, d31_in    => d31_out, d32_in    => d32_out, 
d33_in    => d33_out, d34_in    => d34_out, d35_in    => d35_out, d36_in    => d36_out, d37_in    => d37_out, d38_in    => d38_out, d39_in    => d39_out, d40_in    => d40_out, 
d41_in    => d41_out, d42_in    => d42_out, d43_in    => d43_out, d44_in    => d44_out, d45_in    => d45_out, d46_in    => d46_out, d47_in    => d47_out, d48_in    => d48_out, 
d49_in    => d49_out, d50_in    => d50_out, d51_in    => d51_out, d52_in    => d52_out, d53_in    => d53_out, d54_in    => d54_out, d55_in    => d55_out, d56_in    => d56_out,
d57_in    => d57_out, d58_in    => d58_out, d59_in    => d59_out, d60_in    => d60_out, d61_in    => d61_out, d62_in    => d62_out, d63_in    => d63_out, d64_in    => d64_out, 
           en_in     => '0',
           sof_in    => '0',

           w01      => x"72", 
           w02      => x"e7", 
           w03      => x"61", 
           w04      => x"cc", 
           w05      => x"0f", 
           w06      => x"c3", 
           w07      => x"b3", 
           w08      => x"79", 
           w09      => x"9b", 
           w10      => x"4c", 
           w11      => x"7b", 
           w12      => x"4f", 
           w13      => x"ae", 
           w14      => x"ed", 
           w15      => x"cc", 
           w16      => x"67", 
           w17      => x"0d", 
           w18      => x"34", 
           w19      => x"83", 
           w20      => x"ae", 
           w21      => x"f7", 
           w22      => x"2a", 
           w23      => x"16", 
           w24      => x"c0", 
           w25      => x"5a", 
           w26      => x"27", 
           w27      => x"c3", 
           w28      => x"42", 
           w29      => x"32", 
           w30      => x"b7", 
           w31      => x"49", 
           w32      => x"a6", 
           w33      => x"d5", 
           w34      => x"19", 
           w35      => x"85", 
           w36      => x"11", 
           w37      => x"1e", 
           w38      => x"a8", 
           w39      => x"da", 
           w40      => x"20", 
           w41      => x"e7", 
           w42      => x"ff", 
           w43      => x"df", 
           w44      => x"19", 
           w45      => x"4d", 
           w46      => x"22", 
           w47      => x"94", 
           w48      => x"c8", 
           w49      => x"a0", 
           w50      => x"21", 
           w51      => x"2e", 
           w52      => x"d5", 
           w53      => x"b1", 
           w54      => x"f3", 
           w55      => x"85", 
           w56      => x"2b", 
           w57      => x"1b", 
           w58      => x"79", 
           w59      => x"0a", 
           w60      => x"a2", 
           w61      => x"c1", 
           w62      => x"3d", 
           w63      => x"29", 
           w64      => x"67", 
           d_out   => pca_d43_out, en_out  => open, sof_out => open );

PCA64_44_inst: PCA_64 
  generic map(
           mult_sum => mult_sum,
           N        => CL_W,
           M        => PCAweightW,
           in_row   => in_row,
           in_col   => in_col
           )
  port map (
           clk       => clk    ,
           rst       => rst    ,
d01_in    => d01_out, d02_in    => d02_out, d03_in    => d03_out, d04_in    => d04_out, d05_in    => d05_out, d06_in    => d06_out, d07_in    => d07_out, d08_in    => d08_out, 
d09_in    => d09_out, d10_in    => d10_out, d11_in    => d11_out, d12_in    => d12_out, d13_in    => d13_out, d14_in    => d14_out, d15_in    => d15_out, d16_in    => d16_out, 
d17_in    => d17_out, d18_in    => d18_out, d19_in    => d19_out, d20_in    => d20_out, d21_in    => d21_out, d22_in    => d22_out, d23_in    => d23_out, d24_in    => d24_out, 
d25_in    => d25_out, d26_in    => d26_out, d27_in    => d27_out, d28_in    => d28_out, d29_in    => d29_out, d30_in    => d30_out, d31_in    => d31_out, d32_in    => d32_out, 
d33_in    => d33_out, d34_in    => d34_out, d35_in    => d35_out, d36_in    => d36_out, d37_in    => d37_out, d38_in    => d38_out, d39_in    => d39_out, d40_in    => d40_out, 
d41_in    => d41_out, d42_in    => d42_out, d43_in    => d43_out, d44_in    => d44_out, d45_in    => d45_out, d46_in    => d46_out, d47_in    => d47_out, d48_in    => d48_out, 
d49_in    => d49_out, d50_in    => d50_out, d51_in    => d51_out, d52_in    => d52_out, d53_in    => d53_out, d54_in    => d54_out, d55_in    => d55_out, d56_in    => d56_out,
d57_in    => d57_out, d58_in    => d58_out, d59_in    => d59_out, d60_in    => d60_out, d61_in    => d61_out, d62_in    => d62_out, d63_in    => d63_out, d64_in    => d64_out, 
           en_in     => '0',
           sof_in    => '0',

           w01      => x"a4", 
           w02      => x"7c", 
           w03      => x"11", 
           w04      => x"2b", 
           w05      => x"9f", 
           w06      => x"cb", 
           w07      => x"1e", 
           w08      => x"7a", 
           w09      => x"a2", 
           w10      => x"fd", 
           w11      => x"eb", 
           w12      => x"0c", 
           w13      => x"17", 
           w14      => x"ea", 
           w15      => x"fe", 
           w16      => x"83", 
           w17      => x"7d", 
           w18      => x"c6", 
           w19      => x"a8", 
           w20      => x"76", 
           w21      => x"57", 
           w22      => x"a5", 
           w23      => x"d7", 
           w24      => x"62", 
           w25      => x"56", 
           w26      => x"2b", 
           w27      => x"5c", 
           w28      => x"56", 
           w29      => x"7e", 
           w30      => x"fc", 
           w31      => x"a9", 
           w32      => x"6b", 
           w33      => x"d2", 
           w34      => x"92", 
           w35      => x"b5", 
           w36      => x"52", 
           w37      => x"93", 
           w38      => x"45", 
           w39      => x"fd", 
           w40      => x"3e", 
           w41      => x"c5", 
           w42      => x"0e", 
           w43      => x"ad", 
           w44      => x"2b", 
           w45      => x"11", 
           w46      => x"40", 
           w47      => x"58", 
           w48      => x"ac", 
           w49      => x"46", 
           w50      => x"86", 
           w51      => x"ff", 
           w52      => x"38", 
           w53      => x"d3", 
           w54      => x"2f", 
           w55      => x"e5", 
           w56      => x"86", 
           w57      => x"12", 
           w58      => x"07", 
           w59      => x"21", 
           w60      => x"eb", 
           w61      => x"f6", 
           w62      => x"1b", 
           w63      => x"67", 
           w64      => x"46", 
           d_out   => pca_d44_out, en_out  => open, sof_out => open );

PCA64_45_inst: PCA_64 
  generic map(
           mult_sum => mult_sum,
           N        => CL_W,
           M        => PCAweightW,
           in_row   => in_row,
           in_col   => in_col
           )
  port map (
           clk       => clk    ,
           rst       => rst    ,
d01_in    => d01_out, d02_in    => d02_out, d03_in    => d03_out, d04_in    => d04_out, d05_in    => d05_out, d06_in    => d06_out, d07_in    => d07_out, d08_in    => d08_out, 
d09_in    => d09_out, d10_in    => d10_out, d11_in    => d11_out, d12_in    => d12_out, d13_in    => d13_out, d14_in    => d14_out, d15_in    => d15_out, d16_in    => d16_out, 
d17_in    => d17_out, d18_in    => d18_out, d19_in    => d19_out, d20_in    => d20_out, d21_in    => d21_out, d22_in    => d22_out, d23_in    => d23_out, d24_in    => d24_out, 
d25_in    => d25_out, d26_in    => d26_out, d27_in    => d27_out, d28_in    => d28_out, d29_in    => d29_out, d30_in    => d30_out, d31_in    => d31_out, d32_in    => d32_out, 
d33_in    => d33_out, d34_in    => d34_out, d35_in    => d35_out, d36_in    => d36_out, d37_in    => d37_out, d38_in    => d38_out, d39_in    => d39_out, d40_in    => d40_out, 
d41_in    => d41_out, d42_in    => d42_out, d43_in    => d43_out, d44_in    => d44_out, d45_in    => d45_out, d46_in    => d46_out, d47_in    => d47_out, d48_in    => d48_out, 
d49_in    => d49_out, d50_in    => d50_out, d51_in    => d51_out, d52_in    => d52_out, d53_in    => d53_out, d54_in    => d54_out, d55_in    => d55_out, d56_in    => d56_out,
d57_in    => d57_out, d58_in    => d58_out, d59_in    => d59_out, d60_in    => d60_out, d61_in    => d61_out, d62_in    => d62_out, d63_in    => d63_out, d64_in    => d64_out, 
           en_in     => '0',
           sof_in    => '0',

           w01      => x"ea", 
           w02      => x"ca", 
           w03      => x"ab", 
           w04      => x"79", 
           w05      => x"67", 
           w06      => x"46", 
           w07      => x"c9", 
           w08      => x"0a", 
           w09      => x"91", 
           w10      => x"b6", 
           w11      => x"10", 
           w12      => x"be", 
           w13      => x"a7", 
           w14      => x"95", 
           w15      => x"20", 
           w16      => x"a8", 
           w17      => x"5a", 
           w18      => x"5c", 
           w19      => x"5f", 
           w20      => x"86", 
           w21      => x"44", 
           w22      => x"74", 
           w23      => x"7e", 
           w24      => x"9a", 
           w25      => x"ad", 
           w26      => x"df", 
           w27      => x"5c", 
           w28      => x"4d", 
           w29      => x"0e", 
           w30      => x"38", 
           w31      => x"33", 
           w32      => x"a6", 
           w33      => x"a5", 
           w34      => x"85", 
           w35      => x"26", 
           w36      => x"22", 
           w37      => x"c2", 
           w38      => x"3f", 
           w39      => x"f0", 
           w40      => x"1c", 
           w41      => x"d6", 
           w42      => x"83", 
           w43      => x"15", 
           w44      => x"60", 
           w45      => x"07", 
           w46      => x"d2", 
           w47      => x"3d", 
           w48      => x"74", 
           w49      => x"e3", 
           w50      => x"a1", 
           w51      => x"76", 
           w52      => x"ec", 
           w53      => x"5c", 
           w54      => x"25", 
           w55      => x"ab", 
           w56      => x"4c", 
           w57      => x"63", 
           w58      => x"cc", 
           w59      => x"bf", 
           w60      => x"ef", 
           w61      => x"11", 
           w62      => x"dd", 
           w63      => x"95", 
           w64      => x"f0", 
           d_out   => pca_d45_out, en_out  => open, sof_out => open );

PCA64_46_inst: PCA_64 
  generic map(
           mult_sum => mult_sum,
           N        => CL_W,
           M        => PCAweightW,
           in_row   => in_row,
           in_col   => in_col
           )
  port map (
           clk       => clk    ,
           rst       => rst    ,
d01_in    => d01_out, d02_in    => d02_out, d03_in    => d03_out, d04_in    => d04_out, d05_in    => d05_out, d06_in    => d06_out, d07_in    => d07_out, d08_in    => d08_out, 
d09_in    => d09_out, d10_in    => d10_out, d11_in    => d11_out, d12_in    => d12_out, d13_in    => d13_out, d14_in    => d14_out, d15_in    => d15_out, d16_in    => d16_out, 
d17_in    => d17_out, d18_in    => d18_out, d19_in    => d19_out, d20_in    => d20_out, d21_in    => d21_out, d22_in    => d22_out, d23_in    => d23_out, d24_in    => d24_out, 
d25_in    => d25_out, d26_in    => d26_out, d27_in    => d27_out, d28_in    => d28_out, d29_in    => d29_out, d30_in    => d30_out, d31_in    => d31_out, d32_in    => d32_out, 
d33_in    => d33_out, d34_in    => d34_out, d35_in    => d35_out, d36_in    => d36_out, d37_in    => d37_out, d38_in    => d38_out, d39_in    => d39_out, d40_in    => d40_out, 
d41_in    => d41_out, d42_in    => d42_out, d43_in    => d43_out, d44_in    => d44_out, d45_in    => d45_out, d46_in    => d46_out, d47_in    => d47_out, d48_in    => d48_out, 
d49_in    => d49_out, d50_in    => d50_out, d51_in    => d51_out, d52_in    => d52_out, d53_in    => d53_out, d54_in    => d54_out, d55_in    => d55_out, d56_in    => d56_out,
d57_in    => d57_out, d58_in    => d58_out, d59_in    => d59_out, d60_in    => d60_out, d61_in    => d61_out, d62_in    => d62_out, d63_in    => d63_out, d64_in    => d64_out, 
           en_in     => '0',
           sof_in    => '0',

           w01      => x"dc", 
           w02      => x"0c", 
           w03      => x"e9", 
           w04      => x"9e", 
           w05      => x"e0", 
           w06      => x"eb", 
           w07      => x"09", 
           w08      => x"f9", 
           w09      => x"cd", 
           w10      => x"7f", 
           w11      => x"d1", 
           w12      => x"5f", 
           w13      => x"c9", 
           w14      => x"3a", 
           w15      => x"85", 
           w16      => x"69", 
           w17      => x"89", 
           w18      => x"7c", 
           w19      => x"9d", 
           w20      => x"f2", 
           w21      => x"b8", 
           w22      => x"88", 
           w23      => x"c8", 
           w24      => x"33", 
           w25      => x"37", 
           w26      => x"e1", 
           w27      => x"25", 
           w28      => x"d4", 
           w29      => x"b2", 
           w30      => x"df", 
           w31      => x"51", 
           w32      => x"5e", 
           w33      => x"9f", 
           w34      => x"59", 
           w35      => x"c8", 
           w36      => x"70", 
           w37      => x"58", 
           w38      => x"b1", 
           w39      => x"fa", 
           w40      => x"a3", 
           w41      => x"cb", 
           w42      => x"18", 
           w43      => x"40", 
           w44      => x"4d", 
           w45      => x"76", 
           w46      => x"f7", 
           w47      => x"6c", 
           w48      => x"6e", 
           w49      => x"e4", 
           w50      => x"f8", 
           w51      => x"87", 
           w52      => x"1a", 
           w53      => x"e7", 
           w54      => x"87", 
           w55      => x"3e", 
           w56      => x"7c", 
           w57      => x"d7", 
           w58      => x"bb", 
           w59      => x"57", 
           w60      => x"f2", 
           w61      => x"4d", 
           w62      => x"c1", 
           w63      => x"d5", 
           w64      => x"eb", 
           d_out   => pca_d46_out, en_out  => open, sof_out => open );

PCA64_47_inst: PCA_64 
  generic map(
           mult_sum => mult_sum,
           N        => CL_W,
           M        => PCAweightW,
           in_row   => in_row,
           in_col   => in_col
           )
  port map (
           clk       => clk    ,
           rst       => rst    ,
d01_in    => d01_out, d02_in    => d02_out, d03_in    => d03_out, d04_in    => d04_out, d05_in    => d05_out, d06_in    => d06_out, d07_in    => d07_out, d08_in    => d08_out, 
d09_in    => d09_out, d10_in    => d10_out, d11_in    => d11_out, d12_in    => d12_out, d13_in    => d13_out, d14_in    => d14_out, d15_in    => d15_out, d16_in    => d16_out, 
d17_in    => d17_out, d18_in    => d18_out, d19_in    => d19_out, d20_in    => d20_out, d21_in    => d21_out, d22_in    => d22_out, d23_in    => d23_out, d24_in    => d24_out, 
d25_in    => d25_out, d26_in    => d26_out, d27_in    => d27_out, d28_in    => d28_out, d29_in    => d29_out, d30_in    => d30_out, d31_in    => d31_out, d32_in    => d32_out, 
d33_in    => d33_out, d34_in    => d34_out, d35_in    => d35_out, d36_in    => d36_out, d37_in    => d37_out, d38_in    => d38_out, d39_in    => d39_out, d40_in    => d40_out, 
d41_in    => d41_out, d42_in    => d42_out, d43_in    => d43_out, d44_in    => d44_out, d45_in    => d45_out, d46_in    => d46_out, d47_in    => d47_out, d48_in    => d48_out, 
d49_in    => d49_out, d50_in    => d50_out, d51_in    => d51_out, d52_in    => d52_out, d53_in    => d53_out, d54_in    => d54_out, d55_in    => d55_out, d56_in    => d56_out,
d57_in    => d57_out, d58_in    => d58_out, d59_in    => d59_out, d60_in    => d60_out, d61_in    => d61_out, d62_in    => d62_out, d63_in    => d63_out, d64_in    => d64_out, 
           en_in     => '0',
           sof_in    => '0',

           w01      => x"5c", 
           w02      => x"b2", 
           w03      => x"e1", 
           w04      => x"a8", 
           w05      => x"b5", 
           w06      => x"ce", 
           w07      => x"7f", 
           w08      => x"89", 
           w09      => x"0b", 
           w10      => x"e9", 
           w11      => x"92", 
           w12      => x"c5", 
           w13      => x"6d", 
           w14      => x"c8", 
           w15      => x"1c", 
           w16      => x"61", 
           w17      => x"d6", 
           w18      => x"0d", 
           w19      => x"b1", 
           w20      => x"4a", 
           w21      => x"2b", 
           w22      => x"f9", 
           w23      => x"a1", 
           w24      => x"54", 
           w25      => x"0b", 
           w26      => x"96", 
           w27      => x"a0", 
           w28      => x"2c", 
           w29      => x"29", 
           w30      => x"0a", 
           w31      => x"57", 
           w32      => x"99", 
           w33      => x"70", 
           w34      => x"7e", 
           w35      => x"15", 
           w36      => x"ac", 
           w37      => x"db", 
           w38      => x"76", 
           w39      => x"5e", 
           w40      => x"de", 
           w41      => x"7f", 
           w42      => x"54", 
           w43      => x"f0", 
           w44      => x"af", 
           w45      => x"64", 
           w46      => x"e8", 
           w47      => x"3a", 
           w48      => x"ed", 
           w49      => x"f8", 
           w50      => x"17", 
           w51      => x"97", 
           w52      => x"e7", 
           w53      => x"26", 
           w54      => x"a1", 
           w55      => x"8f", 
           w56      => x"b9", 
           w57      => x"f6", 
           w58      => x"e0", 
           w59      => x"51", 
           w60      => x"e6", 
           w61      => x"b5", 
           w62      => x"cc", 
           w63      => x"75", 
           w64      => x"51", 
           d_out   => pca_d47_out, en_out  => open, sof_out => open );

PCA64_48_inst: PCA_64 
  generic map(
           mult_sum => mult_sum,
           N        => CL_W,
           M        => PCAweightW,
           in_row   => in_row,
           in_col   => in_col
           )
  port map (
           clk       => clk    ,
           rst       => rst    ,
d01_in    => d01_out, d02_in    => d02_out, d03_in    => d03_out, d04_in    => d04_out, d05_in    => d05_out, d06_in    => d06_out, d07_in    => d07_out, d08_in    => d08_out, 
d09_in    => d09_out, d10_in    => d10_out, d11_in    => d11_out, d12_in    => d12_out, d13_in    => d13_out, d14_in    => d14_out, d15_in    => d15_out, d16_in    => d16_out, 
d17_in    => d17_out, d18_in    => d18_out, d19_in    => d19_out, d20_in    => d20_out, d21_in    => d21_out, d22_in    => d22_out, d23_in    => d23_out, d24_in    => d24_out, 
d25_in    => d25_out, d26_in    => d26_out, d27_in    => d27_out, d28_in    => d28_out, d29_in    => d29_out, d30_in    => d30_out, d31_in    => d31_out, d32_in    => d32_out, 
d33_in    => d33_out, d34_in    => d34_out, d35_in    => d35_out, d36_in    => d36_out, d37_in    => d37_out, d38_in    => d38_out, d39_in    => d39_out, d40_in    => d40_out, 
d41_in    => d41_out, d42_in    => d42_out, d43_in    => d43_out, d44_in    => d44_out, d45_in    => d45_out, d46_in    => d46_out, d47_in    => d47_out, d48_in    => d48_out, 
d49_in    => d49_out, d50_in    => d50_out, d51_in    => d51_out, d52_in    => d52_out, d53_in    => d53_out, d54_in    => d54_out, d55_in    => d55_out, d56_in    => d56_out,
d57_in    => d57_out, d58_in    => d58_out, d59_in    => d59_out, d60_in    => d60_out, d61_in    => d61_out, d62_in    => d62_out, d63_in    => d63_out, d64_in    => d64_out, 
           en_in     => '0',
           sof_in    => '0',

           w01      => x"5d", 
           w02      => x"30", 
           w03      => x"bb", 
           w04      => x"2c", 
           w05      => x"64", 
           w06      => x"24", 
           w07      => x"76", 
           w08      => x"66", 
           w09      => x"75", 
           w10      => x"26", 
           w11      => x"c8", 
           w12      => x"20", 
           w13      => x"a5", 
           w14      => x"a4", 
           w15      => x"7f", 
           w16      => x"f0", 
           w17      => x"38", 
           w18      => x"e6", 
           w19      => x"52", 
           w20      => x"d4", 
           w21      => x"0d", 
           w22      => x"9b", 
           w23      => x"84", 
           w24      => x"61", 
           w25      => x"22", 
           w26      => x"5c", 
           w27      => x"7f", 
           w28      => x"83", 
           w29      => x"d9", 
           w30      => x"e8", 
           w31      => x"82", 
           w32      => x"2d", 
           w33      => x"20", 
           w34      => x"c3", 
           w35      => x"07", 
           w36      => x"b3", 
           w37      => x"9a", 
           w38      => x"ae", 
           w39      => x"7a", 
           w40      => x"73", 
           w41      => x"96", 
           w42      => x"67", 
           w43      => x"9f", 
           w44      => x"96", 
           w45      => x"5c", 
           w46      => x"26", 
           w47      => x"89", 
           w48      => x"14", 
           w49      => x"bd", 
           w50      => x"ee", 
           w51      => x"bb", 
           w52      => x"84", 
           w53      => x"6b", 
           w54      => x"9f", 
           w55      => x"ba", 
           w56      => x"f7", 
           w57      => x"4b", 
           w58      => x"83", 
           w59      => x"3a", 
           w60      => x"ef", 
           w61      => x"3c", 
           w62      => x"27", 
           w63      => x"7d", 
           w64      => x"81", 
           d_out   => pca_d48_out, en_out  => open, sof_out => open );

PCA64_49_inst: PCA_64 
  generic map(
           mult_sum => mult_sum,
           N        => CL_W,
           M        => PCAweightW,
           in_row   => in_row,
           in_col   => in_col
           )
  port map (
           clk       => clk    ,
           rst       => rst    ,
d01_in    => d01_out, d02_in    => d02_out, d03_in    => d03_out, d04_in    => d04_out, d05_in    => d05_out, d06_in    => d06_out, d07_in    => d07_out, d08_in    => d08_out, 
d09_in    => d09_out, d10_in    => d10_out, d11_in    => d11_out, d12_in    => d12_out, d13_in    => d13_out, d14_in    => d14_out, d15_in    => d15_out, d16_in    => d16_out, 
d17_in    => d17_out, d18_in    => d18_out, d19_in    => d19_out, d20_in    => d20_out, d21_in    => d21_out, d22_in    => d22_out, d23_in    => d23_out, d24_in    => d24_out, 
d25_in    => d25_out, d26_in    => d26_out, d27_in    => d27_out, d28_in    => d28_out, d29_in    => d29_out, d30_in    => d30_out, d31_in    => d31_out, d32_in    => d32_out, 
d33_in    => d33_out, d34_in    => d34_out, d35_in    => d35_out, d36_in    => d36_out, d37_in    => d37_out, d38_in    => d38_out, d39_in    => d39_out, d40_in    => d40_out, 
d41_in    => d41_out, d42_in    => d42_out, d43_in    => d43_out, d44_in    => d44_out, d45_in    => d45_out, d46_in    => d46_out, d47_in    => d47_out, d48_in    => d48_out, 
d49_in    => d49_out, d50_in    => d50_out, d51_in    => d51_out, d52_in    => d52_out, d53_in    => d53_out, d54_in    => d54_out, d55_in    => d55_out, d56_in    => d56_out,
d57_in    => d57_out, d58_in    => d58_out, d59_in    => d59_out, d60_in    => d60_out, d61_in    => d61_out, d62_in    => d62_out, d63_in    => d63_out, d64_in    => d64_out, 
           en_in     => '0',
           sof_in    => '0',

           w01      => x"9d", 
           w02      => x"13", 
           w03      => x"c8", 
           w04      => x"9f", 
           w05      => x"4b", 
           w06      => x"5a", 
           w07      => x"ea", 
           w08      => x"34", 
           w09      => x"f0", 
           w10      => x"c4", 
           w11      => x"5b", 
           w12      => x"29", 
           w13      => x"22", 
           w14      => x"8b", 
           w15      => x"e4", 
           w16      => x"0f", 
           w17      => x"bb", 
           w18      => x"0a", 
           w19      => x"54", 
           w20      => x"1f", 
           w21      => x"2a", 
           w22      => x"ff", 
           w23      => x"14", 
           w24      => x"d3", 
           w25      => x"85", 
           w26      => x"1d", 
           w27      => x"e8", 
           w28      => x"72", 
           w29      => x"b1", 
           w30      => x"cf", 
           w31      => x"c1", 
           w32      => x"4d", 
           w33      => x"30", 
           w34      => x"b9", 
           w35      => x"af", 
           w36      => x"9a", 
           w37      => x"16", 
           w38      => x"c7", 
           w39      => x"a2", 
           w40      => x"7d", 
           w41      => x"25", 
           w42      => x"40", 
           w43      => x"20", 
           w44      => x"f5", 
           w45      => x"ba", 
           w46      => x"1b", 
           w47      => x"de", 
           w48      => x"86", 
           w49      => x"8d", 
           w50      => x"08", 
           w51      => x"50", 
           w52      => x"55", 
           w53      => x"0f", 
           w54      => x"08", 
           w55      => x"dc", 
           w56      => x"34", 
           w57      => x"dc", 
           w58      => x"2c", 
           w59      => x"8d", 
           w60      => x"19", 
           w61      => x"0c", 
           w62      => x"d2", 
           w63      => x"70", 
           w64      => x"f8", 
           d_out   => pca_d49_out, en_out  => open, sof_out => open );

PCA64_50_inst: PCA_64 
  generic map(
           mult_sum => mult_sum,
           N        => CL_W,
           M        => PCAweightW,
           in_row   => in_row,
           in_col   => in_col
           )
  port map (
           clk       => clk    ,
           rst       => rst    ,
d01_in    => d01_out, d02_in    => d02_out, d03_in    => d03_out, d04_in    => d04_out, d05_in    => d05_out, d06_in    => d06_out, d07_in    => d07_out, d08_in    => d08_out, 
d09_in    => d09_out, d10_in    => d10_out, d11_in    => d11_out, d12_in    => d12_out, d13_in    => d13_out, d14_in    => d14_out, d15_in    => d15_out, d16_in    => d16_out, 
d17_in    => d17_out, d18_in    => d18_out, d19_in    => d19_out, d20_in    => d20_out, d21_in    => d21_out, d22_in    => d22_out, d23_in    => d23_out, d24_in    => d24_out, 
d25_in    => d25_out, d26_in    => d26_out, d27_in    => d27_out, d28_in    => d28_out, d29_in    => d29_out, d30_in    => d30_out, d31_in    => d31_out, d32_in    => d32_out, 
d33_in    => d33_out, d34_in    => d34_out, d35_in    => d35_out, d36_in    => d36_out, d37_in    => d37_out, d38_in    => d38_out, d39_in    => d39_out, d40_in    => d40_out, 
d41_in    => d41_out, d42_in    => d42_out, d43_in    => d43_out, d44_in    => d44_out, d45_in    => d45_out, d46_in    => d46_out, d47_in    => d47_out, d48_in    => d48_out, 
d49_in    => d49_out, d50_in    => d50_out, d51_in    => d51_out, d52_in    => d52_out, d53_in    => d53_out, d54_in    => d54_out, d55_in    => d55_out, d56_in    => d56_out,
d57_in    => d57_out, d58_in    => d58_out, d59_in    => d59_out, d60_in    => d60_out, d61_in    => d61_out, d62_in    => d62_out, d63_in    => d63_out, d64_in    => d64_out, 
           en_in     => '0',
           sof_in    => '0',

           w01      => x"df", 
           w02      => x"7e", 
           w03      => x"4c", 
           w04      => x"ab", 
           w05      => x"44", 
           w06      => x"e0", 
           w07      => x"e3", 
           w08      => x"f6", 
           w09      => x"95", 
           w10      => x"62", 
           w11      => x"40", 
           w12      => x"9b", 
           w13      => x"aa", 
           w14      => x"e1", 
           w15      => x"eb", 
           w16      => x"75", 
           w17      => x"c9", 
           w18      => x"69", 
           w19      => x"d6", 
           w20      => x"9d", 
           w21      => x"8b", 
           w22      => x"be", 
           w23      => x"bf", 
           w24      => x"cc", 
           w25      => x"36", 
           w26      => x"c5", 
           w27      => x"94", 
           w28      => x"aa", 
           w29      => x"3e", 
           w30      => x"19", 
           w31      => x"e0", 
           w32      => x"8d", 
           w33      => x"1e", 
           w34      => x"fe", 
           w35      => x"31", 
           w36      => x"43", 
           w37      => x"58", 
           w38      => x"56", 
           w39      => x"35", 
           w40      => x"53", 
           w41      => x"18", 
           w42      => x"cb", 
           w43      => x"ac", 
           w44      => x"63", 
           w45      => x"65", 
           w46      => x"2f", 
           w47      => x"bb", 
           w48      => x"f3", 
           w49      => x"0b", 
           w50      => x"29", 
           w51      => x"2e", 
           w52      => x"d3", 
           w53      => x"28", 
           w54      => x"e5", 
           w55      => x"ec", 
           w56      => x"60", 
           w57      => x"e3", 
           w58      => x"46", 
           w59      => x"8d", 
           w60      => x"d6", 
           w61      => x"30", 
           w62      => x"da", 
           w63      => x"59", 
           w64      => x"97", 
           d_out   => pca_d50_out, en_out  => open, sof_out => open );

PCA64_51_inst: PCA_64 
  generic map(
           mult_sum => mult_sum,
           N        => CL_W,
           M        => PCAweightW,
           in_row   => in_row,
           in_col   => in_col
           )
  port map (
           clk       => clk    ,
           rst       => rst    ,
d01_in    => d01_out, d02_in    => d02_out, d03_in    => d03_out, d04_in    => d04_out, d05_in    => d05_out, d06_in    => d06_out, d07_in    => d07_out, d08_in    => d08_out, 
d09_in    => d09_out, d10_in    => d10_out, d11_in    => d11_out, d12_in    => d12_out, d13_in    => d13_out, d14_in    => d14_out, d15_in    => d15_out, d16_in    => d16_out, 
d17_in    => d17_out, d18_in    => d18_out, d19_in    => d19_out, d20_in    => d20_out, d21_in    => d21_out, d22_in    => d22_out, d23_in    => d23_out, d24_in    => d24_out, 
d25_in    => d25_out, d26_in    => d26_out, d27_in    => d27_out, d28_in    => d28_out, d29_in    => d29_out, d30_in    => d30_out, d31_in    => d31_out, d32_in    => d32_out, 
d33_in    => d33_out, d34_in    => d34_out, d35_in    => d35_out, d36_in    => d36_out, d37_in    => d37_out, d38_in    => d38_out, d39_in    => d39_out, d40_in    => d40_out, 
d41_in    => d41_out, d42_in    => d42_out, d43_in    => d43_out, d44_in    => d44_out, d45_in    => d45_out, d46_in    => d46_out, d47_in    => d47_out, d48_in    => d48_out, 
d49_in    => d49_out, d50_in    => d50_out, d51_in    => d51_out, d52_in    => d52_out, d53_in    => d53_out, d54_in    => d54_out, d55_in    => d55_out, d56_in    => d56_out,
d57_in    => d57_out, d58_in    => d58_out, d59_in    => d59_out, d60_in    => d60_out, d61_in    => d61_out, d62_in    => d62_out, d63_in    => d63_out, d64_in    => d64_out, 
           en_in     => '0',
           sof_in    => '0',

           w01      => x"93", 
           w02      => x"17", 
           w03      => x"f9", 
           w04      => x"48", 
           w05      => x"68", 
           w06      => x"f7", 
           w07      => x"b6", 
           w08      => x"42", 
           w09      => x"4f", 
           w10      => x"6e", 
           w11      => x"6d", 
           w12      => x"c1", 
           w13      => x"eb", 
           w14      => x"c8", 
           w15      => x"38", 
           w16      => x"e3", 
           w17      => x"ae", 
           w18      => x"d2", 
           w19      => x"a4", 
           w20      => x"a5", 
           w21      => x"6e", 
           w22      => x"1c", 
           w23      => x"a5", 
           w24      => x"18", 
           w25      => x"a1", 
           w26      => x"5a", 
           w27      => x"e0", 
           w28      => x"6a", 
           w29      => x"4a", 
           w30      => x"a6", 
           w31      => x"61", 
           w32      => x"b6", 
           w33      => x"e8", 
           w34      => x"eb", 
           w35      => x"3a", 
           w36      => x"d0", 
           w37      => x"78", 
           w38      => x"19", 
           w39      => x"1f", 
           w40      => x"dd", 
           w41      => x"82", 
           w42      => x"40", 
           w43      => x"3d", 
           w44      => x"d6", 
           w45      => x"74", 
           w46      => x"f1", 
           w47      => x"e4", 
           w48      => x"d8", 
           w49      => x"49", 
           w50      => x"71", 
           w51      => x"2a", 
           w52      => x"64", 
           w53      => x"37", 
           w54      => x"1e", 
           w55      => x"27", 
           w56      => x"9e", 
           w57      => x"95", 
           w58      => x"09", 
           w59      => x"56", 
           w60      => x"9e", 
           w61      => x"36", 
           w62      => x"cb", 
           w63      => x"d5", 
           w64      => x"b6", 
           d_out   => pca_d51_out, en_out  => open, sof_out => open );

PCA64_52_inst: PCA_64 
  generic map(
           mult_sum => mult_sum,
           N        => CL_W,
           M        => PCAweightW,
           in_row   => in_row,
           in_col   => in_col
           )
  port map (
           clk       => clk    ,
           rst       => rst    ,
d01_in    => d01_out, d02_in    => d02_out, d03_in    => d03_out, d04_in    => d04_out, d05_in    => d05_out, d06_in    => d06_out, d07_in    => d07_out, d08_in    => d08_out, 
d09_in    => d09_out, d10_in    => d10_out, d11_in    => d11_out, d12_in    => d12_out, d13_in    => d13_out, d14_in    => d14_out, d15_in    => d15_out, d16_in    => d16_out, 
d17_in    => d17_out, d18_in    => d18_out, d19_in    => d19_out, d20_in    => d20_out, d21_in    => d21_out, d22_in    => d22_out, d23_in    => d23_out, d24_in    => d24_out, 
d25_in    => d25_out, d26_in    => d26_out, d27_in    => d27_out, d28_in    => d28_out, d29_in    => d29_out, d30_in    => d30_out, d31_in    => d31_out, d32_in    => d32_out, 
d33_in    => d33_out, d34_in    => d34_out, d35_in    => d35_out, d36_in    => d36_out, d37_in    => d37_out, d38_in    => d38_out, d39_in    => d39_out, d40_in    => d40_out, 
d41_in    => d41_out, d42_in    => d42_out, d43_in    => d43_out, d44_in    => d44_out, d45_in    => d45_out, d46_in    => d46_out, d47_in    => d47_out, d48_in    => d48_out, 
d49_in    => d49_out, d50_in    => d50_out, d51_in    => d51_out, d52_in    => d52_out, d53_in    => d53_out, d54_in    => d54_out, d55_in    => d55_out, d56_in    => d56_out,
d57_in    => d57_out, d58_in    => d58_out, d59_in    => d59_out, d60_in    => d60_out, d61_in    => d61_out, d62_in    => d62_out, d63_in    => d63_out, d64_in    => d64_out, 
           en_in     => '0',
           sof_in    => '0',

           w01      => x"1c", 
           w02      => x"18", 
           w03      => x"c6", 
           w04      => x"3c", 
           w05      => x"54", 
           w06      => x"38", 
           w07      => x"5b", 
           w08      => x"b4", 
           w09      => x"9b", 
           w10      => x"92", 
           w11      => x"90", 
           w12      => x"a1", 
           w13      => x"12", 
           w14      => x"69", 
           w15      => x"75", 
           w16      => x"2c", 
           w17      => x"d3", 
           w18      => x"1b", 
           w19      => x"46", 
           w20      => x"71", 
           w21      => x"cc", 
           w22      => x"e1", 
           w23      => x"99", 
           w24      => x"d6", 
           w25      => x"a4", 
           w26      => x"cd", 
           w27      => x"86", 
           w28      => x"3f", 
           w29      => x"6b", 
           w30      => x"c4", 
           w31      => x"6f", 
           w32      => x"9b", 
           w33      => x"79", 
           w34      => x"a0", 
           w35      => x"e2", 
           w36      => x"17", 
           w37      => x"6b", 
           w38      => x"89", 
           w39      => x"23", 
           w40      => x"13", 
           w41      => x"dd", 
           w42      => x"2a", 
           w43      => x"dd", 
           w44      => x"1b", 
           w45      => x"86", 
           w46      => x"61", 
           w47      => x"50", 
           w48      => x"67", 
           w49      => x"14", 
           w50      => x"96", 
           w51      => x"9d", 
           w52      => x"ee", 
           w53      => x"dd", 
           w54      => x"60", 
           w55      => x"f6", 
           w56      => x"ed", 
           w57      => x"b4", 
           w58      => x"7e", 
           w59      => x"de", 
           w60      => x"fb", 
           w61      => x"b0", 
           w62      => x"46", 
           w63      => x"31", 
           w64      => x"0d", 
           d_out   => pca_d52_out, en_out  => open, sof_out => open );


PCA64_53_inst: PCA_64 
  generic map(
           mult_sum => mult_sum,
           N        => CL_W,
           M        => PCAweightW,
           in_row   => in_row,
           in_col   => in_col
           )
  port map (
           clk       => clk    ,
           rst       => rst    ,
d01_in    => d01_out, d02_in    => d02_out, d03_in    => d03_out, d04_in    => d04_out, d05_in    => d05_out, d06_in    => d06_out, d07_in    => d07_out, d08_in    => d08_out, 
d09_in    => d09_out, d10_in    => d10_out, d11_in    => d11_out, d12_in    => d12_out, d13_in    => d13_out, d14_in    => d14_out, d15_in    => d15_out, d16_in    => d16_out, 
d17_in    => d17_out, d18_in    => d18_out, d19_in    => d19_out, d20_in    => d20_out, d21_in    => d21_out, d22_in    => d22_out, d23_in    => d23_out, d24_in    => d24_out, 
d25_in    => d25_out, d26_in    => d26_out, d27_in    => d27_out, d28_in    => d28_out, d29_in    => d29_out, d30_in    => d30_out, d31_in    => d31_out, d32_in    => d32_out, 
d33_in    => d33_out, d34_in    => d34_out, d35_in    => d35_out, d36_in    => d36_out, d37_in    => d37_out, d38_in    => d38_out, d39_in    => d39_out, d40_in    => d40_out, 
d41_in    => d41_out, d42_in    => d42_out, d43_in    => d43_out, d44_in    => d44_out, d45_in    => d45_out, d46_in    => d46_out, d47_in    => d47_out, d48_in    => d48_out, 
d49_in    => d49_out, d50_in    => d50_out, d51_in    => d51_out, d52_in    => d52_out, d53_in    => d53_out, d54_in    => d54_out, d55_in    => d55_out, d56_in    => d56_out,
d57_in    => d57_out, d58_in    => d58_out, d59_in    => d59_out, d60_in    => d60_out, d61_in    => d61_out, d62_in    => d62_out, d63_in    => d63_out, d64_in    => d64_out, 
           en_in     => '0',
           sof_in    => '0',

           w01      => x"f7", 
           w02      => x"d8", 
           w03      => x"73", 
           w04      => x"76", 
           w05      => x"b5", 
           w06      => x"57", 
           w07      => x"5c", 
           w08      => x"51", 
           w09      => x"da", 
           w10      => x"57", 
           w11      => x"86", 
           w12      => x"43", 
           w13      => x"6c", 
           w14      => x"a1", 
           w15      => x"5e", 
           w16      => x"dc", 
           w17      => x"ac", 
           w18      => x"0f", 
           w19      => x"9e", 
           w20      => x"63", 
           w21      => x"10", 
           w22      => x"55", 
           w23      => x"78", 
           w24      => x"c3", 
           w25      => x"85", 
           w26      => x"e1", 
           w27      => x"a3", 
           w28      => x"86", 
           w29      => x"17", 
           w30      => x"e4", 
           w31      => x"6f", 
           w32      => x"8c", 
           w33      => x"60", 
           w34      => x"e1", 
           w35      => x"16", 
           w36      => x"8c", 
           w37      => x"7e", 
           w38      => x"e0", 
           w39      => x"d2", 
           w40      => x"86", 
           w41      => x"9b", 
           w42      => x"8b", 
           w43      => x"bf", 
           w44      => x"ef", 
           w45      => x"89", 
           w46      => x"3a", 
           w47      => x"0b", 
           w48      => x"b4", 
           w49      => x"26", 
           w50      => x"5b", 
           w51      => x"d8", 
           w52      => x"64", 
           w53      => x"d6", 
           w54      => x"ec", 
           w55      => x"39", 
           w56      => x"90", 
           w57      => x"1e", 
           w58      => x"e6", 
           w59      => x"9f", 
           w60      => x"19", 
           w61      => x"32", 
           w62      => x"fd", 
           w63      => x"33", 
           w64      => x"78", 
           d_out   => pca_d53_out, en_out  => open, sof_out => open );

PCA64_54_inst: PCA_64 
  generic map(
           mult_sum => mult_sum,
           N        => CL_W,
           M        => PCAweightW,
           in_row   => in_row,
           in_col   => in_col
           )
  port map (
           clk       => clk    ,
           rst       => rst    ,
d01_in    => d01_out, d02_in    => d02_out, d03_in    => d03_out, d04_in    => d04_out, d05_in    => d05_out, d06_in    => d06_out, d07_in    => d07_out, d08_in    => d08_out, 
d09_in    => d09_out, d10_in    => d10_out, d11_in    => d11_out, d12_in    => d12_out, d13_in    => d13_out, d14_in    => d14_out, d15_in    => d15_out, d16_in    => d16_out, 
d17_in    => d17_out, d18_in    => d18_out, d19_in    => d19_out, d20_in    => d20_out, d21_in    => d21_out, d22_in    => d22_out, d23_in    => d23_out, d24_in    => d24_out, 
d25_in    => d25_out, d26_in    => d26_out, d27_in    => d27_out, d28_in    => d28_out, d29_in    => d29_out, d30_in    => d30_out, d31_in    => d31_out, d32_in    => d32_out, 
d33_in    => d33_out, d34_in    => d34_out, d35_in    => d35_out, d36_in    => d36_out, d37_in    => d37_out, d38_in    => d38_out, d39_in    => d39_out, d40_in    => d40_out, 
d41_in    => d41_out, d42_in    => d42_out, d43_in    => d43_out, d44_in    => d44_out, d45_in    => d45_out, d46_in    => d46_out, d47_in    => d47_out, d48_in    => d48_out, 
d49_in    => d49_out, d50_in    => d50_out, d51_in    => d51_out, d52_in    => d52_out, d53_in    => d53_out, d54_in    => d54_out, d55_in    => d55_out, d56_in    => d56_out,
d57_in    => d57_out, d58_in    => d58_out, d59_in    => d59_out, d60_in    => d60_out, d61_in    => d61_out, d62_in    => d62_out, d63_in    => d63_out, d64_in    => d64_out, 
           en_in     => '0',
           sof_in    => '0',

           w01      => x"c3", 
           w02      => x"b3", 
           w03      => x"2e", 
           w04      => x"0f", 
           w05      => x"4f", 
           w06      => x"4a", 
           w07      => x"7a", 
           w08      => x"12", 
           w09      => x"b2", 
           w10      => x"79", 
           w11      => x"fa", 
           w12      => x"76", 
           w13      => x"49", 
           w14      => x"5b", 
           w15      => x"6f", 
           w16      => x"2f", 
           w17      => x"c2", 
           w18      => x"fb", 
           w19      => x"4e", 
           w20      => x"4c", 
           w21      => x"9b", 
           w22      => x"a7", 
           w23      => x"38", 
           w24      => x"cc", 
           w25      => x"28", 
           w26      => x"78", 
           w27      => x"cb", 
           w28      => x"3a", 
           w29      => x"98", 
           w30      => x"1f", 
           w31      => x"94", 
           w32      => x"9f", 
           w33      => x"80", 
           w34      => x"24", 
           w35      => x"73", 
           w36      => x"1d", 
           w37      => x"2a", 
           w38      => x"52", 
           w39      => x"63", 
           w40      => x"31", 
           w41      => x"12", 
           w42      => x"f1", 
           w43      => x"26", 
           w44      => x"8f", 
           w45      => x"ca", 
           w46      => x"b8", 
           w47      => x"39", 
           w48      => x"0b", 
           w49      => x"8c", 
           w50      => x"da", 
           w51      => x"e1", 
           w52      => x"ce", 
           w53      => x"9c", 
           w54      => x"bd", 
           w55      => x"a1", 
           w56      => x"b5", 
           w57      => x"d9", 
           w58      => x"17", 
           w59      => x"a9", 
           w60      => x"c0", 
           w61      => x"79", 
           w62      => x"37", 
           w63      => x"42", 
           w64      => x"a8", 
           d_out   => pca_d54_out, en_out  => open, sof_out => open );

PCA64_55_inst: PCA_64 
  generic map(
           mult_sum => mult_sum,
           N        => CL_W,
           M        => PCAweightW,
           in_row   => in_row,
           in_col   => in_col
           )
  port map (
           clk       => clk    ,
           rst       => rst    ,
d01_in    => d01_out, d02_in    => d02_out, d03_in    => d03_out, d04_in    => d04_out, d05_in    => d05_out, d06_in    => d06_out, d07_in    => d07_out, d08_in    => d08_out, 
d09_in    => d09_out, d10_in    => d10_out, d11_in    => d11_out, d12_in    => d12_out, d13_in    => d13_out, d14_in    => d14_out, d15_in    => d15_out, d16_in    => d16_out, 
d17_in    => d17_out, d18_in    => d18_out, d19_in    => d19_out, d20_in    => d20_out, d21_in    => d21_out, d22_in    => d22_out, d23_in    => d23_out, d24_in    => d24_out, 
d25_in    => d25_out, d26_in    => d26_out, d27_in    => d27_out, d28_in    => d28_out, d29_in    => d29_out, d30_in    => d30_out, d31_in    => d31_out, d32_in    => d32_out, 
d33_in    => d33_out, d34_in    => d34_out, d35_in    => d35_out, d36_in    => d36_out, d37_in    => d37_out, d38_in    => d38_out, d39_in    => d39_out, d40_in    => d40_out, 
d41_in    => d41_out, d42_in    => d42_out, d43_in    => d43_out, d44_in    => d44_out, d45_in    => d45_out, d46_in    => d46_out, d47_in    => d47_out, d48_in    => d48_out, 
d49_in    => d49_out, d50_in    => d50_out, d51_in    => d51_out, d52_in    => d52_out, d53_in    => d53_out, d54_in    => d54_out, d55_in    => d55_out, d56_in    => d56_out,
d57_in    => d57_out, d58_in    => d58_out, d59_in    => d59_out, d60_in    => d60_out, d61_in    => d61_out, d62_in    => d62_out, d63_in    => d63_out, d64_in    => d64_out, 
           en_in     => '0',
           sof_in    => '0',

           w01      => x"82", 
           w02      => x"94", 
           w03      => x"56", 
           w04      => x"24", 
           w05      => x"b0", 
           w06      => x"8d", 
           w07      => x"bd", 
           w08      => x"b5", 
           w09      => x"72", 
           w10      => x"4b", 
           w11      => x"ae", 
           w12      => x"9a", 
           w13      => x"55", 
           w14      => x"62", 
           w15      => x"cc", 
           w16      => x"84", 
           w17      => x"b3", 
           w18      => x"a2", 
           w19      => x"75", 
           w20      => x"c2", 
           w21      => x"61", 
           w22      => x"67", 
           w23      => x"a3", 
           w24      => x"7d", 
           w25      => x"09", 
           w26      => x"3e", 
           w27      => x"23", 
           w28      => x"cc", 
           w29      => x"dc", 
           w30      => x"4b", 
           w31      => x"b4", 
           w32      => x"2f", 
           w33      => x"91", 
           w34      => x"8f", 
           w35      => x"b1", 
           w36      => x"20", 
           w37      => x"f2", 
           w38      => x"2d", 
           w39      => x"bc", 
           w40      => x"f9", 
           w41      => x"32", 
           w42      => x"41", 
           w43      => x"39", 
           w44      => x"53", 
           w45      => x"6a", 
           w46      => x"3b", 
           w47      => x"c5", 
           w48      => x"ec", 
           w49      => x"66", 
           w50      => x"75", 
           w51      => x"8e", 
           w52      => x"07", 
           w53      => x"10", 
           w54      => x"3b", 
           w55      => x"90", 
           w56      => x"f3", 
           w57      => x"2e", 
           w58      => x"5e", 
           w59      => x"cf", 
           w60      => x"47", 
           w61      => x"83", 
           w62      => x"ff", 
           w63      => x"d0", 
           w64      => x"36", 
           d_out   => pca_d55_out, en_out  => open, sof_out => open );

PCA64_56_inst: PCA_64 
  generic map(
           mult_sum => mult_sum,
           N        => CL_W,
           M        => PCAweightW,
           in_row   => in_row,
           in_col   => in_col
           )
  port map (
           clk       => clk    ,
           rst       => rst    ,
d01_in    => d01_out, d02_in    => d02_out, d03_in    => d03_out, d04_in    => d04_out, d05_in    => d05_out, d06_in    => d06_out, d07_in    => d07_out, d08_in    => d08_out, 
d09_in    => d09_out, d10_in    => d10_out, d11_in    => d11_out, d12_in    => d12_out, d13_in    => d13_out, d14_in    => d14_out, d15_in    => d15_out, d16_in    => d16_out, 
d17_in    => d17_out, d18_in    => d18_out, d19_in    => d19_out, d20_in    => d20_out, d21_in    => d21_out, d22_in    => d22_out, d23_in    => d23_out, d24_in    => d24_out, 
d25_in    => d25_out, d26_in    => d26_out, d27_in    => d27_out, d28_in    => d28_out, d29_in    => d29_out, d30_in    => d30_out, d31_in    => d31_out, d32_in    => d32_out, 
d33_in    => d33_out, d34_in    => d34_out, d35_in    => d35_out, d36_in    => d36_out, d37_in    => d37_out, d38_in    => d38_out, d39_in    => d39_out, d40_in    => d40_out, 
d41_in    => d41_out, d42_in    => d42_out, d43_in    => d43_out, d44_in    => d44_out, d45_in    => d45_out, d46_in    => d46_out, d47_in    => d47_out, d48_in    => d48_out, 
d49_in    => d49_out, d50_in    => d50_out, d51_in    => d51_out, d52_in    => d52_out, d53_in    => d53_out, d54_in    => d54_out, d55_in    => d55_out, d56_in    => d56_out,
d57_in    => d57_out, d58_in    => d58_out, d59_in    => d59_out, d60_in    => d60_out, d61_in    => d61_out, d62_in    => d62_out, d63_in    => d63_out, d64_in    => d64_out, 
           en_in     => '0',
           sof_in    => '0',

           w01      => x"2a", 
           w02      => x"89", 
           w03      => x"72", 
           w04      => x"f9", 
           w05      => x"ac", 
           w06      => x"c1", 
           w07      => x"38", 
           w08      => x"1b", 
           w09      => x"f1", 
           w10      => x"a3", 
           w11      => x"ca", 
           w12      => x"66", 
           w13      => x"9a", 
           w14      => x"33", 
           w15      => x"3c", 
           w16      => x"97", 
           w17      => x"e6", 
           w18      => x"4c", 
           w19      => x"d4", 
           w20      => x"77", 
           w21      => x"25", 
           w22      => x"75", 
           w23      => x"71", 
           w24      => x"11", 
           w25      => x"ce", 
           w26      => x"da", 
           w27      => x"98", 
           w28      => x"c1", 
           w29      => x"e7", 
           w30      => x"6d", 
           w31      => x"1c", 
           w32      => x"e8", 
           w33      => x"d8", 
           w34      => x"7a", 
           w35      => x"7f", 
           w36      => x"56", 
           w37      => x"b4", 
           w38      => x"f7", 
           w39      => x"84", 
           w40      => x"65", 
           w41      => x"50", 
           w42      => x"24", 
           w43      => x"76", 
           w44      => x"25", 
           w45      => x"da", 
           w46      => x"e5", 
           w47      => x"e0", 
           w48      => x"d2", 
           w49      => x"93", 
           w50      => x"95", 
           w51      => x"a6", 
           w52      => x"1f", 
           w53      => x"5f", 
           w54      => x"c8", 
           w55      => x"2d", 
           w56      => x"27", 
           w57      => x"97", 
           w58      => x"fb", 
           w59      => x"f2", 
           w60      => x"8b", 
           w61      => x"6e", 
           w62      => x"52", 
           w63      => x"cf", 
           w64      => x"5f", 
           d_out   => pca_d56_out, en_out  => open, sof_out => open );

PCA64_57_inst: PCA_64 
  generic map(
           mult_sum => mult_sum,
           N        => CL_W,
           M        => PCAweightW,
           in_row   => in_row,
           in_col   => in_col
           )
  port map (
           clk       => clk    ,
           rst       => rst    ,
d01_in    => d01_out, d02_in    => d02_out, d03_in    => d03_out, d04_in    => d04_out, d05_in    => d05_out, d06_in    => d06_out, d07_in    => d07_out, d08_in    => d08_out, 
d09_in    => d09_out, d10_in    => d10_out, d11_in    => d11_out, d12_in    => d12_out, d13_in    => d13_out, d14_in    => d14_out, d15_in    => d15_out, d16_in    => d16_out, 
d17_in    => d17_out, d18_in    => d18_out, d19_in    => d19_out, d20_in    => d20_out, d21_in    => d21_out, d22_in    => d22_out, d23_in    => d23_out, d24_in    => d24_out, 
d25_in    => d25_out, d26_in    => d26_out, d27_in    => d27_out, d28_in    => d28_out, d29_in    => d29_out, d30_in    => d30_out, d31_in    => d31_out, d32_in    => d32_out, 
d33_in    => d33_out, d34_in    => d34_out, d35_in    => d35_out, d36_in    => d36_out, d37_in    => d37_out, d38_in    => d38_out, d39_in    => d39_out, d40_in    => d40_out, 
d41_in    => d41_out, d42_in    => d42_out, d43_in    => d43_out, d44_in    => d44_out, d45_in    => d45_out, d46_in    => d46_out, d47_in    => d47_out, d48_in    => d48_out, 
d49_in    => d49_out, d50_in    => d50_out, d51_in    => d51_out, d52_in    => d52_out, d53_in    => d53_out, d54_in    => d54_out, d55_in    => d55_out, d56_in    => d56_out,
d57_in    => d57_out, d58_in    => d58_out, d59_in    => d59_out, d60_in    => d60_out, d61_in    => d61_out, d62_in    => d62_out, d63_in    => d63_out, d64_in    => d64_out, 
           en_in     => '0',
           sof_in    => '0',

           w01      => x"4d", 
           w02      => x"17", 
           w03      => x"8d", 
           w04      => x"e5", 
           w05      => x"d0", 
           w06      => x"ae", 
           w07      => x"3a", 
           w08      => x"d1", 
           w09      => x"50", 
           w10      => x"19", 
           w11      => x"7c", 
           w12      => x"82", 
           w13      => x"ef", 
           w14      => x"0b", 
           w15      => x"a7", 
           w16      => x"49", 
           w17      => x"95", 
           w18      => x"ad", 
           w19      => x"b0", 
           w20      => x"48", 
           w21      => x"91", 
           w22      => x"45", 
           w23      => x"1f", 
           w24      => x"c0", 
           w25      => x"a2", 
           w26      => x"91", 
           w27      => x"63", 
           w28      => x"40", 
           w29      => x"31", 
           w30      => x"28", 
           w31      => x"d3", 
           w32      => x"26", 
           w33      => x"f0", 
           w34      => x"10", 
           w35      => x"ce", 
           w36      => x"ee", 
           w37      => x"fc", 
           w38      => x"99", 
           w39      => x"fc", 
           w40      => x"69", 
           w41      => x"1f", 
           w42      => x"13", 
           w43      => x"5e", 
           w44      => x"b5", 
           w45      => x"94", 
           w46      => x"2d", 
           w47      => x"44", 
           w48      => x"0f", 
           w49      => x"50", 
           w50      => x"95", 
           w51      => x"3a", 
           w52      => x"c0", 
           w53      => x"6f", 
           w54      => x"c4", 
           w55      => x"7d", 
           w56      => x"18", 
           w57      => x"4d", 
           w58      => x"93", 
           w59      => x"33", 
           w60      => x"90", 
           w61      => x"eb", 
           w62      => x"a3", 
           w63      => x"96", 
           w64      => x"5b", 
           d_out   => pca_d57_out, en_out  => open, sof_out => open );

PCA64_58_inst: PCA_64 
  generic map(
           mult_sum => mult_sum,
           N        => CL_W,
           M        => PCAweightW,
           in_row   => in_row,
           in_col   => in_col
           )
  port map (
           clk       => clk    ,
           rst       => rst    ,
d01_in    => d01_out, d02_in    => d02_out, d03_in    => d03_out, d04_in    => d04_out, d05_in    => d05_out, d06_in    => d06_out, d07_in    => d07_out, d08_in    => d08_out, 
d09_in    => d09_out, d10_in    => d10_out, d11_in    => d11_out, d12_in    => d12_out, d13_in    => d13_out, d14_in    => d14_out, d15_in    => d15_out, d16_in    => d16_out, 
d17_in    => d17_out, d18_in    => d18_out, d19_in    => d19_out, d20_in    => d20_out, d21_in    => d21_out, d22_in    => d22_out, d23_in    => d23_out, d24_in    => d24_out, 
d25_in    => d25_out, d26_in    => d26_out, d27_in    => d27_out, d28_in    => d28_out, d29_in    => d29_out, d30_in    => d30_out, d31_in    => d31_out, d32_in    => d32_out, 
d33_in    => d33_out, d34_in    => d34_out, d35_in    => d35_out, d36_in    => d36_out, d37_in    => d37_out, d38_in    => d38_out, d39_in    => d39_out, d40_in    => d40_out, 
d41_in    => d41_out, d42_in    => d42_out, d43_in    => d43_out, d44_in    => d44_out, d45_in    => d45_out, d46_in    => d46_out, d47_in    => d47_out, d48_in    => d48_out, 
d49_in    => d49_out, d50_in    => d50_out, d51_in    => d51_out, d52_in    => d52_out, d53_in    => d53_out, d54_in    => d54_out, d55_in    => d55_out, d56_in    => d56_out,
d57_in    => d57_out, d58_in    => d58_out, d59_in    => d59_out, d60_in    => d60_out, d61_in    => d61_out, d62_in    => d62_out, d63_in    => d63_out, d64_in    => d64_out, 
           en_in     => '0',
           sof_in    => '0',

           w01      => x"75", 
           w02      => x"99", 
           w03      => x"1e", 
           w04      => x"d3", 
           w05      => x"45", 
           w06      => x"51", 
           w07      => x"82", 
           w08      => x"e5", 
           w09      => x"10", 
           w10      => x"cd", 
           w11      => x"3d", 
           w12      => x"f0", 
           w13      => x"82", 
           w14      => x"74", 
           w15      => x"2e", 
           w16      => x"b3", 
           w17      => x"9b", 
           w18      => x"9e", 
           w19      => x"a1", 
           w20      => x"e2", 
           w21      => x"e5", 
           w22      => x"3f", 
           w23      => x"0e", 
           w24      => x"18", 
           w25      => x"d1", 
           w26      => x"6d", 
           w27      => x"45", 
           w28      => x"f3", 
           w29      => x"3d", 
           w30      => x"aa", 
           w31      => x"d6", 
           w32      => x"f3", 
           w33      => x"ac", 
           w34      => x"ea", 
           w35      => x"ee", 
           w36      => x"85", 
           w37      => x"b8", 
           w38      => x"a4", 
           w39      => x"fa", 
           w40      => x"cf", 
           w41      => x"a2", 
           w42      => x"94", 
           w43      => x"0d", 
           w44      => x"31", 
           w45      => x"5e", 
           w46      => x"78", 
           w47      => x"aa", 
           w48      => x"83", 
           w49      => x"83", 
           w50      => x"33", 
           w51      => x"99", 
           w52      => x"30", 
           w53      => x"dc", 
           w54      => x"df", 
           w55      => x"d0", 
           w56      => x"4d", 
           w57      => x"31", 
           w58      => x"7e", 
           w59      => x"81", 
           w60      => x"8f", 
           w61      => x"64", 
           w62      => x"59", 
           w63      => x"cb", 
           w64      => x"80", 
           d_out   => pca_d58_out, en_out  => open, sof_out => open );

PCA64_59_inst: PCA_64 
  generic map(
           mult_sum => mult_sum,
           N        => CL_W,
           M        => PCAweightW,
           in_row   => in_row,
           in_col   => in_col
           )
  port map (
           clk       => clk    ,
           rst       => rst    ,
d01_in    => d01_out, d02_in    => d02_out, d03_in    => d03_out, d04_in    => d04_out, d05_in    => d05_out, d06_in    => d06_out, d07_in    => d07_out, d08_in    => d08_out, 
d09_in    => d09_out, d10_in    => d10_out, d11_in    => d11_out, d12_in    => d12_out, d13_in    => d13_out, d14_in    => d14_out, d15_in    => d15_out, d16_in    => d16_out, 
d17_in    => d17_out, d18_in    => d18_out, d19_in    => d19_out, d20_in    => d20_out, d21_in    => d21_out, d22_in    => d22_out, d23_in    => d23_out, d24_in    => d24_out, 
d25_in    => d25_out, d26_in    => d26_out, d27_in    => d27_out, d28_in    => d28_out, d29_in    => d29_out, d30_in    => d30_out, d31_in    => d31_out, d32_in    => d32_out, 
d33_in    => d33_out, d34_in    => d34_out, d35_in    => d35_out, d36_in    => d36_out, d37_in    => d37_out, d38_in    => d38_out, d39_in    => d39_out, d40_in    => d40_out, 
d41_in    => d41_out, d42_in    => d42_out, d43_in    => d43_out, d44_in    => d44_out, d45_in    => d45_out, d46_in    => d46_out, d47_in    => d47_out, d48_in    => d48_out, 
d49_in    => d49_out, d50_in    => d50_out, d51_in    => d51_out, d52_in    => d52_out, d53_in    => d53_out, d54_in    => d54_out, d55_in    => d55_out, d56_in    => d56_out,
d57_in    => d57_out, d58_in    => d58_out, d59_in    => d59_out, d60_in    => d60_out, d61_in    => d61_out, d62_in    => d62_out, d63_in    => d63_out, d64_in    => d64_out, 
           en_in     => '0',
           sof_in    => '0',

           w01      => x"99", 
           w02      => x"3a", 
           w03      => x"2c", 
           w04      => x"68", 
           w05      => x"e5", 
           w06      => x"24", 
           w07      => x"24", 
           w08      => x"f5", 
           w09      => x"6b", 
           w10      => x"b6", 
           w11      => x"26", 
           w12      => x"0a", 
           w13      => x"11", 
           w14      => x"df", 
           w15      => x"64", 
           w16      => x"25", 
           w17      => x"95", 
           w18      => x"7d", 
           w19      => x"38", 
           w20      => x"fb", 
           w21      => x"2c", 
           w22      => x"cc", 
           w23      => x"e8", 
           w24      => x"6f", 
           w25      => x"2e", 
           w26      => x"3e", 
           w27      => x"9a", 
           w28      => x"3c", 
           w29      => x"13", 
           w30      => x"7d", 
           w31      => x"80", 
           w32      => x"9a", 
           w33      => x"1e", 
           w34      => x"e7", 
           w35      => x"e8", 
           w36      => x"1e", 
           w37      => x"8c", 
           w38      => x"dd", 
           w39      => x"30", 
           w40      => x"6c", 
           w41      => x"4a", 
           w42      => x"1d", 
           w43      => x"ae", 
           w44      => x"d2", 
           w45      => x"66", 
           w46      => x"a3", 
           w47      => x"e5", 
           w48      => x"c0", 
           w49      => x"20", 
           w50      => x"a8", 
           w51      => x"db", 
           w52      => x"2d", 
           w53      => x"ca", 
           w54      => x"58", 
           w55      => x"8f", 
           w56      => x"23", 
           w57      => x"31", 
           w58      => x"41", 
           w59      => x"dd", 
           w60      => x"bd", 
           w61      => x"4c", 
           w62      => x"2e", 
           w63      => x"08", 
           w64      => x"63", 
           d_out   => pca_d59_out, en_out  => open, sof_out => open );


PCA64_60_inst: PCA_64 
  generic map(
           mult_sum => mult_sum,
           N        => CL_W,
           M        => PCAweightW,
           in_row   => in_row,
           in_col   => in_col
           )
  port map (
           clk       => clk    ,
           rst       => rst    ,
d01_in    => d01_out, d02_in    => d02_out, d03_in    => d03_out, d04_in    => d04_out, d05_in    => d05_out, d06_in    => d06_out, d07_in    => d07_out, d08_in    => d08_out, 
d09_in    => d09_out, d10_in    => d10_out, d11_in    => d11_out, d12_in    => d12_out, d13_in    => d13_out, d14_in    => d14_out, d15_in    => d15_out, d16_in    => d16_out, 
d17_in    => d17_out, d18_in    => d18_out, d19_in    => d19_out, d20_in    => d20_out, d21_in    => d21_out, d22_in    => d22_out, d23_in    => d23_out, d24_in    => d24_out, 
d25_in    => d25_out, d26_in    => d26_out, d27_in    => d27_out, d28_in    => d28_out, d29_in    => d29_out, d30_in    => d30_out, d31_in    => d31_out, d32_in    => d32_out, 
d33_in    => d33_out, d34_in    => d34_out, d35_in    => d35_out, d36_in    => d36_out, d37_in    => d37_out, d38_in    => d38_out, d39_in    => d39_out, d40_in    => d40_out, 
d41_in    => d41_out, d42_in    => d42_out, d43_in    => d43_out, d44_in    => d44_out, d45_in    => d45_out, d46_in    => d46_out, d47_in    => d47_out, d48_in    => d48_out, 
d49_in    => d49_out, d50_in    => d50_out, d51_in    => d51_out, d52_in    => d52_out, d53_in    => d53_out, d54_in    => d54_out, d55_in    => d55_out, d56_in    => d56_out,
d57_in    => d57_out, d58_in    => d58_out, d59_in    => d59_out, d60_in    => d60_out, d61_in    => d61_out, d62_in    => d62_out, d63_in    => d63_out, d64_in    => d64_out, 
           en_in     => '0',
           sof_in    => '0',

           w01      => x"ad", 
           w02      => x"ae", 
           w03      => x"13", 
           w04      => x"6d", 
           w05      => x"1f", 
           w06      => x"0d", 
           w07      => x"30", 
           w08      => x"5a", 
           w09      => x"f0", 
           w10      => x"91", 
           w11      => x"fc", 
           w12      => x"f2", 
           w13      => x"c7", 
           w14      => x"0a", 
           w15      => x"34", 
           w16      => x"3a", 
           w17      => x"aa", 
           w18      => x"31", 
           w19      => x"0a", 
           w20      => x"0a", 
           w21      => x"60", 
           w22      => x"8e", 
           w23      => x"13", 
           w24      => x"2a", 
           w25      => x"0c", 
           w26      => x"7a", 
           w27      => x"20", 
           w28      => x"80", 
           w29      => x"13", 
           w30      => x"46", 
           w31      => x"cd", 
           w32      => x"b4", 
           w33      => x"f2", 
           w34      => x"b1", 
           w35      => x"15", 
           w36      => x"76", 
           w37      => x"43", 
           w38      => x"32", 
           w39      => x"4e", 
           w40      => x"b0", 
           w41      => x"30", 
           w42      => x"3d", 
           w43      => x"df", 
           w44      => x"fe", 
           w45      => x"7b", 
           w46      => x"7e", 
           w47      => x"ee", 
           w48      => x"a7", 
           w49      => x"3d", 
           w50      => x"84", 
           w51      => x"c2", 
           w52      => x"6f", 
           w53      => x"c9", 
           w54      => x"bf", 
           w55      => x"ad", 
           w56      => x"1e", 
           w57      => x"46", 
           w58      => x"a7", 
           w59      => x"20", 
           w60      => x"dd", 
           w61      => x"1d", 
           w62      => x"d6", 
           w63      => x"14", 
           w64      => x"60", 
           d_out   => pca_d60_out, en_out  => open, sof_out => open );

PCA64_61_inst: PCA_64 
  generic map(
           mult_sum => mult_sum,
           N        => CL_W,
           M        => PCAweightW,
           in_row   => in_row,
           in_col   => in_col
           )
  port map (
           clk       => clk    ,
           rst       => rst    ,
d01_in    => d01_out, d02_in    => d02_out, d03_in    => d03_out, d04_in    => d04_out, d05_in    => d05_out, d06_in    => d06_out, d07_in    => d07_out, d08_in    => d08_out, 
d09_in    => d09_out, d10_in    => d10_out, d11_in    => d11_out, d12_in    => d12_out, d13_in    => d13_out, d14_in    => d14_out, d15_in    => d15_out, d16_in    => d16_out, 
d17_in    => d17_out, d18_in    => d18_out, d19_in    => d19_out, d20_in    => d20_out, d21_in    => d21_out, d22_in    => d22_out, d23_in    => d23_out, d24_in    => d24_out, 
d25_in    => d25_out, d26_in    => d26_out, d27_in    => d27_out, d28_in    => d28_out, d29_in    => d29_out, d30_in    => d30_out, d31_in    => d31_out, d32_in    => d32_out, 
d33_in    => d33_out, d34_in    => d34_out, d35_in    => d35_out, d36_in    => d36_out, d37_in    => d37_out, d38_in    => d38_out, d39_in    => d39_out, d40_in    => d40_out, 
d41_in    => d41_out, d42_in    => d42_out, d43_in    => d43_out, d44_in    => d44_out, d45_in    => d45_out, d46_in    => d46_out, d47_in    => d47_out, d48_in    => d48_out, 
d49_in    => d49_out, d50_in    => d50_out, d51_in    => d51_out, d52_in    => d52_out, d53_in    => d53_out, d54_in    => d54_out, d55_in    => d55_out, d56_in    => d56_out,
d57_in    => d57_out, d58_in    => d58_out, d59_in    => d59_out, d60_in    => d60_out, d61_in    => d61_out, d62_in    => d62_out, d63_in    => d63_out, d64_in    => d64_out, 
           en_in     => '0',
           sof_in    => '0',

           w01      => x"b1", 
           w02      => x"7a", 
           w03      => x"14", 
           w04      => x"9e", 
           w05      => x"d6", 
           w06      => x"cc", 
           w07      => x"39", 
           w08      => x"44", 
           w09      => x"cf", 
           w10      => x"fc", 
           w11      => x"f9", 
           w12      => x"ca", 
           w13      => x"60", 
           w14      => x"c5", 
           w15      => x"67", 
           w16      => x"24", 
           w17      => x"3c", 
           w18      => x"5a", 
           w19      => x"33", 
           w20      => x"ec", 
           w21      => x"ce", 
           w22      => x"24", 
           w23      => x"9b", 
           w24      => x"4b", 
           w25      => x"82", 
           w26      => x"9b", 
           w27      => x"97", 
           w28      => x"1e", 
           w29      => x"73", 
           w30      => x"e6", 
           w31      => x"43", 
           w32      => x"8c", 
           w33      => x"ee", 
           w34      => x"2a", 
           w35      => x"e2", 
           w36      => x"11", 
           w37      => x"65", 
           w38      => x"50", 
           w39      => x"fc", 
           w40      => x"bd", 
           w41      => x"0a", 
           w42      => x"f6", 
           w43      => x"7f", 
           w44      => x"3d", 
           w45      => x"1a", 
           w46      => x"10", 
           w47      => x"27", 
           w48      => x"db", 
           w49      => x"89", 
           w50      => x"57", 
           w51      => x"98", 
           w52      => x"75", 
           w53      => x"d8", 
           w54      => x"28", 
           w55      => x"51", 
           w56      => x"e5", 
           w57      => x"c9", 
           w58      => x"59", 
           w59      => x"ae", 
           w60      => x"49", 
           w61      => x"8f", 
           w62      => x"52", 
           w63      => x"ac", 
           w64      => x"d0", 
           d_out   => pca_d61_out, en_out  => open, sof_out => open );

PCA64_62_inst: PCA_64 
  generic map(
           mult_sum => mult_sum,
           N        => CL_W,
           M        => PCAweightW,
           in_row   => in_row,
           in_col   => in_col
           )
  port map (
           clk       => clk    ,
           rst       => rst    ,
d01_in    => d01_out, d02_in    => d02_out, d03_in    => d03_out, d04_in    => d04_out, d05_in    => d05_out, d06_in    => d06_out, d07_in    => d07_out, d08_in    => d08_out, 
d09_in    => d09_out, d10_in    => d10_out, d11_in    => d11_out, d12_in    => d12_out, d13_in    => d13_out, d14_in    => d14_out, d15_in    => d15_out, d16_in    => d16_out, 
d17_in    => d17_out, d18_in    => d18_out, d19_in    => d19_out, d20_in    => d20_out, d21_in    => d21_out, d22_in    => d22_out, d23_in    => d23_out, d24_in    => d24_out, 
d25_in    => d25_out, d26_in    => d26_out, d27_in    => d27_out, d28_in    => d28_out, d29_in    => d29_out, d30_in    => d30_out, d31_in    => d31_out, d32_in    => d32_out, 
d33_in    => d33_out, d34_in    => d34_out, d35_in    => d35_out, d36_in    => d36_out, d37_in    => d37_out, d38_in    => d38_out, d39_in    => d39_out, d40_in    => d40_out, 
d41_in    => d41_out, d42_in    => d42_out, d43_in    => d43_out, d44_in    => d44_out, d45_in    => d45_out, d46_in    => d46_out, d47_in    => d47_out, d48_in    => d48_out, 
d49_in    => d49_out, d50_in    => d50_out, d51_in    => d51_out, d52_in    => d52_out, d53_in    => d53_out, d54_in    => d54_out, d55_in    => d55_out, d56_in    => d56_out,
d57_in    => d57_out, d58_in    => d58_out, d59_in    => d59_out, d60_in    => d60_out, d61_in    => d61_out, d62_in    => d62_out, d63_in    => d63_out, d64_in    => d64_out, 
           en_in     => '0',
           sof_in    => '0',

           w01      => x"f3", 
           w02      => x"f8", 
           w03      => x"a0", 
           w04      => x"fe", 
           w05      => x"d2", 
           w06      => x"22", 
           w07      => x"0e", 
           w08      => x"d2", 
           w09      => x"7e", 
           w10      => x"63", 
           w11      => x"6d", 
           w12      => x"82", 
           w13      => x"4c", 
           w14      => x"24", 
           w15      => x"cf", 
           w16      => x"70", 
           w17      => x"52", 
           w18      => x"1c", 
           w19      => x"27", 
           w20      => x"4a", 
           w21      => x"b0", 
           w22      => x"e9", 
           w23      => x"a0", 
           w24      => x"ff", 
           w25      => x"48", 
           w26      => x"c0", 
           w27      => x"68", 
           w28      => x"b1", 
           w29      => x"7d", 
           w30      => x"d6", 
           w31      => x"70", 
           w32      => x"0b", 
           w33      => x"bb", 
           w34      => x"ce", 
           w35      => x"80", 
           w36      => x"32", 
           w37      => x"cf", 
           w38      => x"3b", 
           w39      => x"ba", 
           w40      => x"26", 
           w41      => x"2e", 
           w42      => x"6d", 
           w43      => x"ae", 
           w44      => x"92", 
           w45      => x"4e", 
           w46      => x"de", 
           w47      => x"0a", 
           w48      => x"4d", 
           w49      => x"8a", 
           w50      => x"eb", 
           w51      => x"df", 
           w52      => x"58", 
           w53      => x"91", 
           w54      => x"fe", 
           w55      => x"82", 
           w56      => x"a5", 
           w57      => x"8f", 
           w58      => x"8e", 
           w59      => x"52", 
           w60      => x"0e", 
           w61      => x"e1", 
           w62      => x"17", 
           w63      => x"c7", 
           w64      => x"72", 
           d_out   => pca_d62_out, en_out  => open, sof_out => open );

PCA64_63_inst: PCA_64 
  generic map(
           mult_sum => mult_sum,
           N        => CL_W,
           M        => PCAweightW,
           in_row   => in_row,
           in_col   => in_col
           )
  port map (
           clk       => clk    ,
           rst       => rst    ,
d01_in    => d01_out, d02_in    => d02_out, d03_in    => d03_out, d04_in    => d04_out, d05_in    => d05_out, d06_in    => d06_out, d07_in    => d07_out, d08_in    => d08_out, 
d09_in    => d09_out, d10_in    => d10_out, d11_in    => d11_out, d12_in    => d12_out, d13_in    => d13_out, d14_in    => d14_out, d15_in    => d15_out, d16_in    => d16_out, 
d17_in    => d17_out, d18_in    => d18_out, d19_in    => d19_out, d20_in    => d20_out, d21_in    => d21_out, d22_in    => d22_out, d23_in    => d23_out, d24_in    => d24_out, 
d25_in    => d25_out, d26_in    => d26_out, d27_in    => d27_out, d28_in    => d28_out, d29_in    => d29_out, d30_in    => d30_out, d31_in    => d31_out, d32_in    => d32_out, 
d33_in    => d33_out, d34_in    => d34_out, d35_in    => d35_out, d36_in    => d36_out, d37_in    => d37_out, d38_in    => d38_out, d39_in    => d39_out, d40_in    => d40_out, 
d41_in    => d41_out, d42_in    => d42_out, d43_in    => d43_out, d44_in    => d44_out, d45_in    => d45_out, d46_in    => d46_out, d47_in    => d47_out, d48_in    => d48_out, 
d49_in    => d49_out, d50_in    => d50_out, d51_in    => d51_out, d52_in    => d52_out, d53_in    => d53_out, d54_in    => d54_out, d55_in    => d55_out, d56_in    => d56_out,
d57_in    => d57_out, d58_in    => d58_out, d59_in    => d59_out, d60_in    => d60_out, d61_in    => d61_out, d62_in    => d62_out, d63_in    => d63_out, d64_in    => d64_out, 
           en_in     => '0',
           sof_in    => '0',

           w01      => x"29", 
           w02      => x"54", 
           w03      => x"d1", 
           w04      => x"53", 
           w05      => x"8a", 
           w06      => x"1d", 
           w07      => x"37", 
           w08      => x"40", 
           w09      => x"23", 
           w10      => x"76", 
           w11      => x"d5", 
           w12      => x"8d", 
           w13      => x"e4", 
           w14      => x"b6", 
           w15      => x"ee", 
           w16      => x"7f", 
           w17      => x"8d", 
           w18      => x"a6", 
           w19      => x"64", 
           w20      => x"16", 
           w21      => x"f8", 
           w22      => x"da", 
           w23      => x"6f", 
           w24      => x"5f", 
           w25      => x"f3", 
           w26      => x"67", 
           w27      => x"51", 
           w28      => x"2e", 
           w29      => x"7a", 
           w30      => x"ee", 
           w31      => x"fb", 
           w32      => x"f2", 
           w33      => x"3c", 
           w34      => x"fe", 
           w35      => x"77", 
           w36      => x"c2", 
           w37      => x"21", 
           w38      => x"45", 
           w39      => x"8c", 
           w40      => x"d0", 
           w41      => x"0e", 
           w42      => x"64", 
           w43      => x"2c", 
           w44      => x"97", 
           w45      => x"a1", 
           w46      => x"3f", 
           w47      => x"93", 
           w48      => x"c4", 
           w49      => x"10", 
           w50      => x"fd", 
           w51      => x"6b", 
           w52      => x"9d", 
           w53      => x"85", 
           w54      => x"ed", 
           w55      => x"5d", 
           w56      => x"4f", 
           w57      => x"52", 
           w58      => x"f7", 
           w59      => x"45", 
           w60      => x"5b", 
           w61      => x"af", 
           w62      => x"3f", 
           w63      => x"79", 
           w64      => x"d2", 
           d_out   => pca_d63_out, en_out  => open, sof_out => open );

PCA64_64_inst: PCA_64 
  generic map(
           mult_sum => mult_sum,
           N        => CL_W,
           M        => PCAweightW,
           in_row   => in_row,
           in_col   => in_col
           )
  port map (
           clk       => clk    ,
           rst       => rst    ,
d01_in    => d01_out, d02_in    => d02_out, d03_in    => d03_out, d04_in    => d04_out, d05_in    => d05_out, d06_in    => d06_out, d07_in    => d07_out, d08_in    => d08_out, 
d09_in    => d09_out, d10_in    => d10_out, d11_in    => d11_out, d12_in    => d12_out, d13_in    => d13_out, d14_in    => d14_out, d15_in    => d15_out, d16_in    => d16_out, 
d17_in    => d17_out, d18_in    => d18_out, d19_in    => d19_out, d20_in    => d20_out, d21_in    => d21_out, d22_in    => d22_out, d23_in    => d23_out, d24_in    => d24_out, 
d25_in    => d25_out, d26_in    => d26_out, d27_in    => d27_out, d28_in    => d28_out, d29_in    => d29_out, d30_in    => d30_out, d31_in    => d31_out, d32_in    => d32_out, 
d33_in    => d33_out, d34_in    => d34_out, d35_in    => d35_out, d36_in    => d36_out, d37_in    => d37_out, d38_in    => d38_out, d39_in    => d39_out, d40_in    => d40_out, 
d41_in    => d41_out, d42_in    => d42_out, d43_in    => d43_out, d44_in    => d44_out, d45_in    => d45_out, d46_in    => d46_out, d47_in    => d47_out, d48_in    => d48_out, 
d49_in    => d49_out, d50_in    => d50_out, d51_in    => d51_out, d52_in    => d52_out, d53_in    => d53_out, d54_in    => d54_out, d55_in    => d55_out, d56_in    => d56_out,
d57_in    => d57_out, d58_in    => d58_out, d59_in    => d59_out, d60_in    => d60_out, d61_in    => d61_out, d62_in    => d62_out, d63_in    => d63_out, d64_in    => d64_out, 
           en_in     => '0',
           sof_in    => '0',

           w01      => x"d3", 
           w02      => x"d9", 
           w03      => x"dd", 
           w04      => x"58", 
           w05      => x"07", 
           w06      => x"58", 
           w07      => x"97", 
           w08      => x"9a", 
           w09      => x"d1", 
           w10      => x"8f", 
           w11      => x"db", 
           w12      => x"7a", 
           w13      => x"80", 
           w14      => x"e3", 
           w15      => x"2d", 
           w16      => x"82", 
           w17      => x"5d", 
           w18      => x"83", 
           w19      => x"37", 
           w20      => x"e6", 
           w21      => x"6f", 
           w22      => x"8c", 
           w23      => x"d0", 
           w24      => x"76", 
           w25      => x"5a", 
           w26      => x"ea", 
           w27      => x"09", 
           w28      => x"2d", 
           w29      => x"9a", 
           w30      => x"1e", 
           w31      => x"22", 
           w32      => x"42", 
           w33      => x"9f", 
           w34      => x"80", 
           w35      => x"39", 
           w36      => x"98", 
           w37      => x"9f", 
           w38      => x"ef", 
           w39      => x"16", 
           w40      => x"0c", 
           w41      => x"98", 
           w42      => x"fa", 
           w43      => x"c6", 
           w44      => x"c4", 
           w45      => x"29", 
           w46      => x"65", 
           w47      => x"b6", 
           w48      => x"91", 
           w49      => x"8a", 
           w50      => x"c4", 
           w51      => x"f0", 
           w52      => x"d3", 
           w53      => x"14", 
           w54      => x"e8", 
           w55      => x"e2", 
           w56      => x"a4", 
           w57      => x"d6", 
           w58      => x"51", 
           w59      => x"5d", 
           w60      => x"a6", 
           w61      => x"4f", 
           w62      => x"45", 
           w63      => x"a6", 
           w64      => x"b5", 
           d_out   => pca_d64_out, en_out  => open, sof_out => open );

end generate g_PCA_en;

g_PCA_bp: if PCA_en = FALSE generate
   pca_en_out                          <=  cl_en_out;
   pca_d01_out(pca_d01_out'left downto pca_d01_out'left - 7)  <=  d01_out(d01_out'left downto d01_out'left - 7); pca_d01_out(pca_d01_out'left - 8 downto 0)  <=  (others => '0');
   pca_d02_out(pca_d02_out'left downto pca_d02_out'left - 7)  <=  d02_out(d02_out'left downto d02_out'left - 7); pca_d02_out(pca_d02_out'left - 8 downto 0)  <=  (others => '0');
   pca_d03_out(pca_d03_out'left downto pca_d03_out'left - 7)  <=  d03_out(d03_out'left downto d03_out'left - 7); pca_d03_out(pca_d03_out'left - 8 downto 0)  <=  (others => '0');
   pca_d04_out(pca_d04_out'left downto pca_d04_out'left - 7)  <=  d04_out(d04_out'left downto d04_out'left - 7); pca_d04_out(pca_d04_out'left - 8 downto 0)  <=  (others => '0');
   pca_d05_out(pca_d05_out'left downto pca_d05_out'left - 7)  <=  d05_out(d05_out'left downto d05_out'left - 7); pca_d05_out(pca_d05_out'left - 8 downto 0)  <=  (others => '0');
   pca_d06_out(pca_d06_out'left downto pca_d06_out'left - 7)  <=  d06_out(d06_out'left downto d06_out'left - 7); pca_d06_out(pca_d06_out'left - 8 downto 0)  <=  (others => '0');
   pca_d07_out(pca_d07_out'left downto pca_d07_out'left - 7)  <=  d07_out(d07_out'left downto d07_out'left - 7); pca_d07_out(pca_d07_out'left - 8 downto 0)  <=  (others => '0');
   pca_d08_out(pca_d08_out'left downto pca_d08_out'left - 7)  <=  d08_out(d08_out'left downto d08_out'left - 7); pca_d08_out(pca_d08_out'left - 8 downto 0)  <=  (others => '0');
   pca_d09_out(pca_d09_out'left downto pca_d09_out'left - 7)  <=  d09_out(d09_out'left downto d09_out'left - 7); pca_d09_out(pca_d09_out'left - 8 downto 0)  <=  (others => '0');
   pca_d10_out(pca_d10_out'left downto pca_d10_out'left - 7)  <=  d10_out(d10_out'left downto d10_out'left - 7); pca_d10_out(pca_d10_out'left - 8 downto 0)  <=  (others => '0');
   pca_d11_out(pca_d11_out'left downto pca_d11_out'left - 7)  <=  d11_out(d11_out'left downto d11_out'left - 7); pca_d11_out(pca_d11_out'left - 8 downto 0)  <=  (others => '0');
   pca_d12_out(pca_d12_out'left downto pca_d12_out'left - 7)  <=  d12_out(d12_out'left downto d12_out'left - 7); pca_d12_out(pca_d12_out'left - 8 downto 0)  <=  (others => '0');
   pca_d13_out(pca_d13_out'left downto pca_d13_out'left - 7)  <=  d13_out(d13_out'left downto d13_out'left - 7); pca_d13_out(pca_d13_out'left - 8 downto 0)  <=  (others => '0');
   pca_d14_out(pca_d14_out'left downto pca_d14_out'left - 7)  <=  d14_out(d14_out'left downto d14_out'left - 7); pca_d14_out(pca_d14_out'left - 8 downto 0)  <=  (others => '0');
   pca_d15_out(pca_d15_out'left downto pca_d15_out'left - 7)  <=  d15_out(d15_out'left downto d15_out'left - 7); pca_d15_out(pca_d15_out'left - 8 downto 0)  <=  (others => '0');
   pca_d16_out(pca_d16_out'left downto pca_d16_out'left - 7)  <=  d16_out(d16_out'left downto d16_out'left - 7); pca_d16_out(pca_d16_out'left - 8 downto 0)  <=  (others => '0');
   pca_d17_out(pca_d17_out'left downto pca_d17_out'left - 7)  <=  d17_out(d17_out'left downto d17_out'left - 7); pca_d17_out(pca_d17_out'left - 8 downto 0)  <=  (others => '0');
   pca_d18_out(pca_d18_out'left downto pca_d18_out'left - 7)  <=  d18_out(d18_out'left downto d18_out'left - 7); pca_d18_out(pca_d18_out'left - 8 downto 0)  <=  (others => '0');
   pca_d19_out(pca_d19_out'left downto pca_d19_out'left - 7)  <=  d19_out(d19_out'left downto d19_out'left - 7); pca_d19_out(pca_d19_out'left - 8 downto 0)  <=  (others => '0');
   pca_d20_out(pca_d20_out'left downto pca_d20_out'left - 7)  <=  d20_out(d20_out'left downto d20_out'left - 7); pca_d20_out(pca_d20_out'left - 8 downto 0)  <=  (others => '0');
   pca_d21_out(pca_d21_out'left downto pca_d21_out'left - 7)  <=  d21_out(d21_out'left downto d21_out'left - 7); pca_d21_out(pca_d21_out'left - 8 downto 0)  <=  (others => '0');
   pca_d22_out(pca_d22_out'left downto pca_d22_out'left - 7)  <=  d22_out(d22_out'left downto d22_out'left - 7); pca_d22_out(pca_d22_out'left - 8 downto 0)  <=  (others => '0');
   pca_d23_out(pca_d23_out'left downto pca_d23_out'left - 7)  <=  d23_out(d23_out'left downto d23_out'left - 7); pca_d23_out(pca_d23_out'left - 8 downto 0)  <=  (others => '0');
   pca_d24_out(pca_d24_out'left downto pca_d24_out'left - 7)  <=  d24_out(d24_out'left downto d24_out'left - 7); pca_d24_out(pca_d24_out'left - 8 downto 0)  <=  (others => '0');
   pca_d25_out(pca_d25_out'left downto pca_d25_out'left - 7)  <=  d25_out(d25_out'left downto d25_out'left - 7); pca_d25_out(pca_d25_out'left - 8 downto 0)  <=  (others => '0');
   pca_d26_out(pca_d26_out'left downto pca_d26_out'left - 7)  <=  d26_out(d26_out'left downto d26_out'left - 7); pca_d26_out(pca_d26_out'left - 8 downto 0)  <=  (others => '0');
   pca_d27_out(pca_d27_out'left downto pca_d27_out'left - 7)  <=  d27_out(d27_out'left downto d27_out'left - 7); pca_d27_out(pca_d27_out'left - 8 downto 0)  <=  (others => '0');
   pca_d28_out(pca_d28_out'left downto pca_d28_out'left - 7)  <=  d28_out(d28_out'left downto d28_out'left - 7); pca_d28_out(pca_d28_out'left - 8 downto 0)  <=  (others => '0');
   pca_d29_out(pca_d29_out'left downto pca_d29_out'left - 7)  <=  d29_out(d29_out'left downto d29_out'left - 7); pca_d29_out(pca_d29_out'left - 8 downto 0)  <=  (others => '0');
   pca_d30_out(pca_d30_out'left downto pca_d30_out'left - 7)  <=  d30_out(d30_out'left downto d30_out'left - 7); pca_d30_out(pca_d30_out'left - 8 downto 0)  <=  (others => '0');
   pca_d31_out(pca_d31_out'left downto pca_d31_out'left - 7)  <=  d31_out(d31_out'left downto d31_out'left - 7); pca_d31_out(pca_d31_out'left - 8 downto 0)  <=  (others => '0');
   pca_d32_out(pca_d32_out'left downto pca_d32_out'left - 7)  <=  d32_out(d32_out'left downto d32_out'left - 7); pca_d32_out(pca_d32_out'left - 8 downto 0)  <=  (others => '0');
   pca_d33_out(pca_d33_out'left downto pca_d33_out'left - 7)  <=  d33_out(d33_out'left downto d33_out'left - 7); pca_d33_out(pca_d33_out'left - 8 downto 0)  <=  (others => '0');
   pca_d34_out(pca_d34_out'left downto pca_d34_out'left - 7)  <=  d34_out(d34_out'left downto d34_out'left - 7); pca_d34_out(pca_d34_out'left - 8 downto 0)  <=  (others => '0');
   pca_d35_out(pca_d35_out'left downto pca_d35_out'left - 7)  <=  d35_out(d35_out'left downto d35_out'left - 7); pca_d35_out(pca_d35_out'left - 8 downto 0)  <=  (others => '0');
   pca_d36_out(pca_d36_out'left downto pca_d36_out'left - 7)  <=  d36_out(d36_out'left downto d36_out'left - 7); pca_d36_out(pca_d36_out'left - 8 downto 0)  <=  (others => '0');
   pca_d37_out(pca_d37_out'left downto pca_d37_out'left - 7)  <=  d37_out(d37_out'left downto d37_out'left - 7); pca_d37_out(pca_d37_out'left - 8 downto 0)  <=  (others => '0');
   pca_d38_out(pca_d38_out'left downto pca_d38_out'left - 7)  <=  d38_out(d38_out'left downto d38_out'left - 7); pca_d38_out(pca_d38_out'left - 8 downto 0)  <=  (others => '0');
   pca_d39_out(pca_d39_out'left downto pca_d39_out'left - 7)  <=  d39_out(d39_out'left downto d39_out'left - 7); pca_d39_out(pca_d39_out'left - 8 downto 0)  <=  (others => '0');
   pca_d40_out(pca_d40_out'left downto pca_d40_out'left - 7)  <=  d40_out(d40_out'left downto d40_out'left - 7); pca_d40_out(pca_d40_out'left - 8 downto 0)  <=  (others => '0');
   pca_d41_out(pca_d41_out'left downto pca_d41_out'left - 7)  <=  d41_out(d41_out'left downto d41_out'left - 7); pca_d41_out(pca_d41_out'left - 8 downto 0)  <=  (others => '0');
   pca_d42_out(pca_d42_out'left downto pca_d42_out'left - 7)  <=  d42_out(d42_out'left downto d42_out'left - 7); pca_d42_out(pca_d42_out'left - 8 downto 0)  <=  (others => '0');
   pca_d43_out(pca_d43_out'left downto pca_d43_out'left - 7)  <=  d43_out(d43_out'left downto d43_out'left - 7); pca_d43_out(pca_d43_out'left - 8 downto 0)  <=  (others => '0');
   pca_d44_out(pca_d44_out'left downto pca_d44_out'left - 7)  <=  d44_out(d44_out'left downto d44_out'left - 7); pca_d44_out(pca_d44_out'left - 8 downto 0)  <=  (others => '0');
   pca_d45_out(pca_d45_out'left downto pca_d45_out'left - 7)  <=  d45_out(d45_out'left downto d45_out'left - 7); pca_d45_out(pca_d45_out'left - 8 downto 0)  <=  (others => '0');
   pca_d46_out(pca_d46_out'left downto pca_d46_out'left - 7)  <=  d46_out(d46_out'left downto d46_out'left - 7); pca_d46_out(pca_d46_out'left - 8 downto 0)  <=  (others => '0');
   pca_d47_out(pca_d47_out'left downto pca_d47_out'left - 7)  <=  d47_out(d47_out'left downto d47_out'left - 7); pca_d47_out(pca_d47_out'left - 8 downto 0)  <=  (others => '0');
   pca_d48_out(pca_d48_out'left downto pca_d48_out'left - 7)  <=  d48_out(d48_out'left downto d48_out'left - 7); pca_d48_out(pca_d48_out'left - 8 downto 0)  <=  (others => '0');
   pca_d49_out(pca_d49_out'left downto pca_d49_out'left - 7)  <=  d49_out(d49_out'left downto d49_out'left - 7); pca_d49_out(pca_d49_out'left - 8 downto 0)  <=  (others => '0');
   pca_d50_out(pca_d50_out'left downto pca_d50_out'left - 7)  <=  d50_out(d50_out'left downto d50_out'left - 7); pca_d50_out(pca_d50_out'left - 8 downto 0)  <=  (others => '0');
   pca_d51_out(pca_d51_out'left downto pca_d51_out'left - 7)  <=  d51_out(d51_out'left downto d51_out'left - 7); pca_d51_out(pca_d51_out'left - 8 downto 0)  <=  (others => '0');
   pca_d52_out(pca_d52_out'left downto pca_d52_out'left - 7)  <=  d52_out(d52_out'left downto d52_out'left - 7); pca_d52_out(pca_d52_out'left - 8 downto 0)  <=  (others => '0');
   pca_d53_out(pca_d53_out'left downto pca_d53_out'left - 7)  <=  d53_out(d53_out'left downto d53_out'left - 7); pca_d53_out(pca_d53_out'left - 8 downto 0)  <=  (others => '0');
   pca_d54_out(pca_d54_out'left downto pca_d54_out'left - 7)  <=  d54_out(d54_out'left downto d54_out'left - 7); pca_d54_out(pca_d54_out'left - 8 downto 0)  <=  (others => '0');
   pca_d55_out(pca_d55_out'left downto pca_d55_out'left - 7)  <=  d55_out(d55_out'left downto d55_out'left - 7); pca_d55_out(pca_d55_out'left - 8 downto 0)  <=  (others => '0');
   pca_d56_out(pca_d56_out'left downto pca_d56_out'left - 7)  <=  d56_out(d56_out'left downto d56_out'left - 7); pca_d56_out(pca_d56_out'left - 8 downto 0)  <=  (others => '0');
   pca_d57_out(pca_d57_out'left downto pca_d57_out'left - 7)  <=  d57_out(d57_out'left downto d57_out'left - 7); pca_d57_out(pca_d57_out'left - 8 downto 0)  <=  (others => '0');
   pca_d58_out(pca_d58_out'left downto pca_d58_out'left - 7)  <=  d58_out(d58_out'left downto d58_out'left - 7); pca_d58_out(pca_d58_out'left - 8 downto 0)  <=  (others => '0');
   pca_d59_out(pca_d59_out'left downto pca_d59_out'left - 7)  <=  d59_out(d59_out'left downto d59_out'left - 7); pca_d59_out(pca_d59_out'left - 8 downto 0)  <=  (others => '0');
   pca_d60_out(pca_d60_out'left downto pca_d60_out'left - 7)  <=  d60_out(d60_out'left downto d60_out'left - 7); pca_d60_out(pca_d60_out'left - 8 downto 0)  <=  (others => '0');
   pca_d61_out(pca_d61_out'left downto pca_d61_out'left - 7)  <=  d61_out(d61_out'left downto d61_out'left - 7); pca_d61_out(pca_d61_out'left - 8 downto 0)  <=  (others => '0');
   pca_d62_out(pca_d62_out'left downto pca_d62_out'left - 7)  <=  d62_out(d62_out'left downto d62_out'left - 7); pca_d62_out(pca_d62_out'left - 8 downto 0)  <=  (others => '0');
   pca_d63_out(pca_d63_out'left downto pca_d63_out'left - 7)  <=  d63_out(d63_out'left downto d63_out'left - 7); pca_d63_out(pca_d63_out'left - 8 downto 0)  <=  (others => '0');
   pca_d64_out(pca_d64_out'left downto pca_d64_out'left - 7)  <=  d64_out(d64_out'left downto d64_out'left - 7); pca_d64_out(pca_d64_out'left - 8 downto 0)  <=  (others => '0');

end generate g_PCA_bp;

--temp connection


-- p_temp: process (clk)
-- begin
--   if  rising_edge(clk) then
--      d_tmp_1_out  <=   pca_d01_out + pca_d09_out + pca_d17_out + pca_d25_out;
--      d_tmp_2_out  <=   pca_d02_out + pca_d10_out + pca_d18_out + pca_d26_out;
--      d_tmp_3_out  <=   pca_d03_out + pca_d11_out + pca_d19_out + pca_d27_out;
--      d_tmp_4_out  <=   pca_d04_out + pca_d12_out + pca_d20_out + pca_d28_out;
--      d_tmp_5_out  <=   pca_d05_out + pca_d13_out + pca_d21_out + pca_d29_out;
--      d_tmp_6_out  <=   pca_d06_out + pca_d14_out + pca_d22_out + pca_d30_out;
--      d_tmp_7_out  <=   pca_d07_out + pca_d15_out + pca_d23_out + pca_d31_out;
--      d_tmp_8_out  <=   pca_d08_out + pca_d16_out + pca_d24_out + pca_d32_out;
--
--      d_tmp_9_out   <=   pca_d33_out + pca_d41_out + pca_d49_out + pca_d57_out;
--      d_tmp_10_out  <=   pca_d34_out + pca_d42_out + pca_d50_out + pca_d58_out;
--      d_tmp_11_out  <=   pca_d35_out + pca_d43_out + pca_d51_out + pca_d59_out;
--      d_tmp_12_out  <=   pca_d36_out + pca_d44_out + pca_d52_out + pca_d60_out;
--      d_tmp_13_out  <=   pca_d37_out + pca_d45_out + pca_d53_out + pca_d61_out;
--      d_tmp_14_out  <=   pca_d38_out + pca_d46_out + pca_d54_out + pca_d62_out;
--      d_tmp_15_out  <=   pca_d39_out + pca_d47_out + pca_d55_out + pca_d63_out;
--      d_tmp_16_out  <=   pca_d40_out + pca_d48_out + pca_d56_out + pca_d64_out;
--
--      d1_out  <=   d_tmp_1_out + d_tmp_9_out   ;
--      d2_out  <=   d_tmp_2_out + d_tmp_10_out  ;
--      d3_out  <=   d_tmp_3_out + d_tmp_11_out  ;
--      d4_out  <=   d_tmp_4_out + d_tmp_12_out  ;
--      d5_out  <=   d_tmp_5_out + d_tmp_13_out  ;
--      d6_out  <=   d_tmp_6_out + d_tmp_14_out  ;
--      d7_out  <=   d_tmp_7_out + d_tmp_15_out  ;
--      d8_out  <=   d_tmp_8_out + d_tmp_16_out  ;
--
--      
--      en_out  <= pca_en_out  ;
--      sof_out <= pca_sof_out ;
--   end if;
-- end process p_temp;

  p_huff1 : process (clk,rst)
  begin
    if rst = '1' then
       h_en        <= '0';
       h_count_en  <= '1';
       h_count_en2 <= '0';
       h_count     <= (others => '0');
    elsif rising_edge(clk) then
       if h_count_en = '1' then
          --h_num   <= h_count;
          h_count <= h_count + 1;
       end if;
       if h_count = 255 then
          h_count_en <= '0';
       end if;
       h_count_en2 <= h_count_en;
       h_en        <= h_count_en2;
    end if;
  end process p_huff1;

  p_huff2 : process (clk)
  begin
    if rising_edge(clk) then
       alpha_data  <=                                h_count  ;
       alpha_code  <=  Huff_code (conv_integer("0" & h_count));
       alpha_width <=  Huff_width(conv_integer("0" & h_count));
    end if;
  end process p_huff2;


Huffman64_inst: Huffman64 
  generic map(
           N           => 8          ,  -- input data width
           M           => Huff_wid   ,  -- max code width
           Wh          => Wh         ,
           Wb          => Wb         ,
           Huff_enc_en => Huff_enc_en,
           depth       => depth      ,
           burst       => burst
           )
  port map (
           clk      => clk  ,
           rst      => rst  , 

           init_en        => h_en       ,
           alpha_data     => alpha_data ,   
           alpha_code     => alpha_code ,    
           alpha_width    => alpha_width,

           d01_in         => pca_d01_out(pca_d01_out'left downto pca_d01_out'left - 7),
           d02_in         => pca_d02_out(pca_d02_out'left downto pca_d02_out'left - 7),
           d03_in         => pca_d03_out(pca_d03_out'left downto pca_d03_out'left - 7),
           d04_in         => pca_d04_out(pca_d04_out'left downto pca_d04_out'left - 7),
           d05_in         => pca_d05_out(pca_d05_out'left downto pca_d05_out'left - 7),
           d06_in         => pca_d06_out(pca_d06_out'left downto pca_d06_out'left - 7),
           d07_in         => pca_d07_out(pca_d07_out'left downto pca_d07_out'left - 7),
           d08_in         => pca_d08_out(pca_d08_out'left downto pca_d08_out'left - 7),
           d09_in         => pca_d09_out(pca_d09_out'left downto pca_d09_out'left - 7),
           d10_in         => pca_d10_out(pca_d10_out'left downto pca_d10_out'left - 7),
           d11_in         => pca_d11_out(pca_d11_out'left downto pca_d11_out'left - 7),
           d12_in         => pca_d12_out(pca_d12_out'left downto pca_d12_out'left - 7),
           d13_in         => pca_d13_out(pca_d13_out'left downto pca_d13_out'left - 7),
           d14_in         => pca_d14_out(pca_d14_out'left downto pca_d14_out'left - 7),
           d15_in         => pca_d15_out(pca_d15_out'left downto pca_d15_out'left - 7),
           d16_in         => pca_d16_out(pca_d16_out'left downto pca_d16_out'left - 7),
           d17_in         => pca_d17_out(pca_d17_out'left downto pca_d17_out'left - 7),
           d18_in         => pca_d18_out(pca_d18_out'left downto pca_d18_out'left - 7),
           d19_in         => pca_d19_out(pca_d19_out'left downto pca_d19_out'left - 7),
           d20_in         => pca_d20_out(pca_d20_out'left downto pca_d20_out'left - 7),
           d21_in         => pca_d21_out(pca_d21_out'left downto pca_d21_out'left - 7),
           d22_in         => pca_d22_out(pca_d22_out'left downto pca_d22_out'left - 7),
           d23_in         => pca_d23_out(pca_d23_out'left downto pca_d23_out'left - 7),
           d24_in         => pca_d24_out(pca_d24_out'left downto pca_d24_out'left - 7),
           d25_in         => pca_d25_out(pca_d25_out'left downto pca_d25_out'left - 7),
           d26_in         => pca_d26_out(pca_d26_out'left downto pca_d26_out'left - 7),
           d27_in         => pca_d27_out(pca_d27_out'left downto pca_d27_out'left - 7),
           d28_in         => pca_d28_out(pca_d28_out'left downto pca_d28_out'left - 7),
           d29_in         => pca_d29_out(pca_d29_out'left downto pca_d29_out'left - 7),
           d30_in         => pca_d30_out(pca_d30_out'left downto pca_d30_out'left - 7),
           d31_in         => pca_d31_out(pca_d31_out'left downto pca_d31_out'left - 7),
           d32_in         => pca_d32_out(pca_d32_out'left downto pca_d32_out'left - 7),
           d33_in         => pca_d33_out(pca_d33_out'left downto pca_d33_out'left - 7),
           d34_in         => pca_d34_out(pca_d34_out'left downto pca_d34_out'left - 7),
           d35_in         => pca_d35_out(pca_d35_out'left downto pca_d35_out'left - 7),
           d36_in         => pca_d36_out(pca_d36_out'left downto pca_d36_out'left - 7),
           d37_in         => pca_d37_out(pca_d37_out'left downto pca_d37_out'left - 7),
           d38_in         => pca_d38_out(pca_d38_out'left downto pca_d38_out'left - 7),
           d39_in         => pca_d39_out(pca_d39_out'left downto pca_d39_out'left - 7),
           d40_in         => pca_d40_out(pca_d40_out'left downto pca_d40_out'left - 7),
           d41_in         => pca_d41_out(pca_d41_out'left downto pca_d41_out'left - 7),
           d42_in         => pca_d42_out(pca_d42_out'left downto pca_d42_out'left - 7),
           d43_in         => pca_d43_out(pca_d43_out'left downto pca_d43_out'left - 7),
           d44_in         => pca_d44_out(pca_d44_out'left downto pca_d44_out'left - 7),
           d45_in         => pca_d45_out(pca_d45_out'left downto pca_d45_out'left - 7),
           d46_in         => pca_d46_out(pca_d46_out'left downto pca_d46_out'left - 7),
           d47_in         => pca_d47_out(pca_d47_out'left downto pca_d47_out'left - 7),
           d48_in         => pca_d48_out(pca_d48_out'left downto pca_d48_out'left - 7),
           d49_in         => pca_d49_out(pca_d49_out'left downto pca_d49_out'left - 7),
           d50_in         => pca_d50_out(pca_d50_out'left downto pca_d50_out'left - 7),
           d51_in         => pca_d51_out(pca_d51_out'left downto pca_d51_out'left - 7),
           d52_in         => pca_d52_out(pca_d52_out'left downto pca_d52_out'left - 7),
           d53_in         => pca_d53_out(pca_d53_out'left downto pca_d53_out'left - 7),
           d54_in         => pca_d54_out(pca_d54_out'left downto pca_d54_out'left - 7),
           d55_in         => pca_d55_out(pca_d55_out'left downto pca_d55_out'left - 7),
           d56_in         => pca_d56_out(pca_d56_out'left downto pca_d56_out'left - 7),
           d57_in         => pca_d57_out(pca_d57_out'left downto pca_d57_out'left - 7),
           d58_in         => pca_d58_out(pca_d58_out'left downto pca_d58_out'left - 7),
           d59_in         => pca_d59_out(pca_d59_out'left downto pca_d59_out'left - 7),
           d60_in         => pca_d60_out(pca_d60_out'left downto pca_d60_out'left - 7),
           d61_in         => pca_d61_out(pca_d61_out'left downto pca_d61_out'left - 7),
           d62_in         => pca_d62_out(pca_d62_out'left downto pca_d62_out'left - 7),
           d63_in         => pca_d63_out(pca_d63_out'left downto pca_d63_out'left - 7),
           d64_in         => pca_d64_out(pca_d64_out'left downto pca_d64_out'left - 7),
           en_in          => pca_en_out,        --
           sof_in         => pca_sof_out,        --                         -- start of frame
           eof_in         => '0',        --                         -- end of frame

           buf_rd        => buf_rd         ,
           buf_num       => buf_num        ,
           d_out         => huff_out       ,
           en_out        => open           ,
           eof_out       => open           );                        -- huffman codde output

    d_out  <=  huff_out;


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