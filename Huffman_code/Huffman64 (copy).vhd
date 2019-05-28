library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;

entity Huffman64 is
  generic (
           N             : integer := 4; -- input data width
           M             : integer := 8;  -- max code width
           W             : integer := 10 -- output data width (Note W>=M)
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

           d_out         : out std_logic_vector (64*M-1 downto 0);
           en_out        : out std_logic;
           eof_out       : out std_logic);                        -- huffman codde output
end Huffman64;

architecture a of Huffman64 is


component Huffman is
  generic (
           N             : integer := 4; -- input data width
           M             : integer := 8; -- max code width
           W             : integer := 10 -- output data width (Note W>=M)
           );
  port    (
           clk           : in  std_logic;
           rst           : in  std_logic; 

           init_en       : in  std_logic;                         -- initialising convert table
           alpha_data    : in  std_logic_vector(N-1 downto 0);    
           alpha_code    : in  std_logic_vector(M-1 downto 0);    
           alpha_width   : in  std_logic_vector(  3 downto 0);

           d_in          : in  std_logic_vector (N-1 downto 0);   -- data to convert
           en_in         : in  std_logic;
           sof_in        : in  std_logic;                         -- start of frame
           eof_in        : in  std_logic;                         -- end of frame

           d_out         : out std_logic_vector (W-1 downto 0);
           en_out        : out std_logic;
           eof_out       : out std_logic);                        -- huffman codde output
end component;

constant alphabet_depth : integer := 2**N - 1;
type t_Huf_code  is array (0 to alphabet_depth) of std_logic_vector(M-1 downto 0);
type t_Huf_width is array (0 to alphabet_depth) of std_logic_vector(  3 downto 0);
signal Huf_code_m    : t_Huf_code;
signal Huf_width_m   : t_Huf_width;


signal Huf01_coded     : std_logic_vector(M-1 downto 0);
signal Huf02_coded     : std_logic_vector(M-1 downto 0);
signal Huf03_coded     : std_logic_vector(M-1 downto 0);
signal Huf04_coded     : std_logic_vector(M-1 downto 0);
signal Huf05_coded     : std_logic_vector(M-1 downto 0);
signal Huf06_coded     : std_logic_vector(M-1 downto 0);
signal Huf07_coded     : std_logic_vector(M-1 downto 0);
signal Huf08_coded     : std_logic_vector(M-1 downto 0);
signal Huf09_coded     : std_logic_vector(M-1 downto 0);
signal Huf10_coded     : std_logic_vector(M-1 downto 0);
signal Huf11_coded     : std_logic_vector(M-1 downto 0);
signal Huf12_coded     : std_logic_vector(M-1 downto 0);
signal Huf13_coded     : std_logic_vector(M-1 downto 0);
signal Huf14_coded     : std_logic_vector(M-1 downto 0);
signal Huf15_coded     : std_logic_vector(M-1 downto 0);
signal Huf16_coded     : std_logic_vector(M-1 downto 0);
signal Huf17_coded     : std_logic_vector(M-1 downto 0);
signal Huf18_coded     : std_logic_vector(M-1 downto 0);
signal Huf19_coded     : std_logic_vector(M-1 downto 0);
signal Huf20_coded     : std_logic_vector(M-1 downto 0);
signal Huf21_coded     : std_logic_vector(M-1 downto 0);
signal Huf22_coded     : std_logic_vector(M-1 downto 0);
signal Huf23_coded     : std_logic_vector(M-1 downto 0);
signal Huf24_coded     : std_logic_vector(M-1 downto 0);
signal Huf25_coded     : std_logic_vector(M-1 downto 0);
signal Huf26_coded     : std_logic_vector(M-1 downto 0);
signal Huf27_coded     : std_logic_vector(M-1 downto 0);
signal Huf28_coded     : std_logic_vector(M-1 downto 0);
signal Huf29_coded     : std_logic_vector(M-1 downto 0);
signal Huf30_coded     : std_logic_vector(M-1 downto 0);
signal Huf31_coded     : std_logic_vector(M-1 downto 0);
signal Huf32_coded     : std_logic_vector(M-1 downto 0);
signal Huf33_coded     : std_logic_vector(M-1 downto 0);
signal Huf34_coded     : std_logic_vector(M-1 downto 0);
signal Huf35_coded     : std_logic_vector(M-1 downto 0);
signal Huf36_coded     : std_logic_vector(M-1 downto 0);
signal Huf37_coded     : std_logic_vector(M-1 downto 0);
signal Huf38_coded     : std_logic_vector(M-1 downto 0);
signal Huf39_coded     : std_logic_vector(M-1 downto 0);
signal Huf40_coded     : std_logic_vector(M-1 downto 0);
signal Huf41_coded     : std_logic_vector(M-1 downto 0);
signal Huf42_coded     : std_logic_vector(M-1 downto 0);
signal Huf43_coded     : std_logic_vector(M-1 downto 0);
signal Huf44_coded     : std_logic_vector(M-1 downto 0);
signal Huf45_coded     : std_logic_vector(M-1 downto 0);
signal Huf46_coded     : std_logic_vector(M-1 downto 0);
signal Huf47_coded     : std_logic_vector(M-1 downto 0);
signal Huf48_coded     : std_logic_vector(M-1 downto 0);
signal Huf49_coded     : std_logic_vector(M-1 downto 0);
signal Huf50_coded     : std_logic_vector(M-1 downto 0);
signal Huf51_coded     : std_logic_vector(M-1 downto 0);
signal Huf52_coded     : std_logic_vector(M-1 downto 0);
signal Huf53_coded     : std_logic_vector(M-1 downto 0);
signal Huf54_coded     : std_logic_vector(M-1 downto 0);
signal Huf55_coded     : std_logic_vector(M-1 downto 0);
signal Huf56_coded     : std_logic_vector(M-1 downto 0);
signal Huf57_coded     : std_logic_vector(M-1 downto 0);
signal Huf58_coded     : std_logic_vector(M-1 downto 0);
signal Huf59_coded     : std_logic_vector(M-1 downto 0);
signal Huf60_coded     : std_logic_vector(M-1 downto 0);
signal Huf61_coded     : std_logic_vector(M-1 downto 0);
signal Huf62_coded     : std_logic_vector(M-1 downto 0);
signal Huf63_coded     : std_logic_vector(M-1 downto 0);
signal Huf64_coded     : std_logic_vector(M-1 downto 0);

signal Huf01_width     : std_logic_vector(  3 downto 0);
signal Huf02_width     : std_logic_vector(  3 downto 0);
signal Huf03_width     : std_logic_vector(  3 downto 0);
signal Huf04_width     : std_logic_vector(  3 downto 0);
signal Huf05_width     : std_logic_vector(  3 downto 0);
signal Huf06_width     : std_logic_vector(  3 downto 0);
signal Huf07_width     : std_logic_vector(  3 downto 0);
signal Huf08_width     : std_logic_vector(  3 downto 0);
signal Huf09_width     : std_logic_vector(  3 downto 0);
signal Huf10_width     : std_logic_vector(  3 downto 0);
signal Huf11_width     : std_logic_vector(  3 downto 0);
signal Huf12_width     : std_logic_vector(  3 downto 0);
signal Huf13_width     : std_logic_vector(  3 downto 0);
signal Huf14_width     : std_logic_vector(  3 downto 0);
signal Huf15_width     : std_logic_vector(  3 downto 0);
signal Huf16_width     : std_logic_vector(  3 downto 0);
signal Huf17_width     : std_logic_vector(  3 downto 0);
signal Huf18_width     : std_logic_vector(  3 downto 0);
signal Huf19_width     : std_logic_vector(  3 downto 0);
signal Huf20_width     : std_logic_vector(  3 downto 0);
signal Huf21_width     : std_logic_vector(  3 downto 0);
signal Huf22_width     : std_logic_vector(  3 downto 0);
signal Huf23_width     : std_logic_vector(  3 downto 0);
signal Huf24_width     : std_logic_vector(  3 downto 0);
signal Huf25_width     : std_logic_vector(  3 downto 0);
signal Huf26_width     : std_logic_vector(  3 downto 0);
signal Huf27_width     : std_logic_vector(  3 downto 0);
signal Huf28_width     : std_logic_vector(  3 downto 0);
signal Huf29_width     : std_logic_vector(  3 downto 0);
signal Huf30_width     : std_logic_vector(  3 downto 0);
signal Huf31_width     : std_logic_vector(  3 downto 0);
signal Huf32_width     : std_logic_vector(  3 downto 0);
signal Huf33_width     : std_logic_vector(  3 downto 0);
signal Huf34_width     : std_logic_vector(  3 downto 0);
signal Huf35_width     : std_logic_vector(  3 downto 0);
signal Huf36_width     : std_logic_vector(  3 downto 0);
signal Huf37_width     : std_logic_vector(  3 downto 0);
signal Huf38_width     : std_logic_vector(  3 downto 0);
signal Huf39_width     : std_logic_vector(  3 downto 0);
signal Huf40_width     : std_logic_vector(  3 downto 0);
signal Huf41_width     : std_logic_vector(  3 downto 0);
signal Huf42_width     : std_logic_vector(  3 downto 0);
signal Huf43_width     : std_logic_vector(  3 downto 0);
signal Huf44_width     : std_logic_vector(  3 downto 0);
signal Huf45_width     : std_logic_vector(  3 downto 0);
signal Huf46_width     : std_logic_vector(  3 downto 0);
signal Huf47_width     : std_logic_vector(  3 downto 0);
signal Huf48_width     : std_logic_vector(  3 downto 0);
signal Huf49_width     : std_logic_vector(  3 downto 0);
signal Huf50_width     : std_logic_vector(  3 downto 0);
signal Huf51_width     : std_logic_vector(  3 downto 0);
signal Huf52_width     : std_logic_vector(  3 downto 0);
signal Huf53_width     : std_logic_vector(  3 downto 0);
signal Huf54_width     : std_logic_vector(  3 downto 0);
signal Huf55_width     : std_logic_vector(  3 downto 0);
signal Huf56_width     : std_logic_vector(  3 downto 0);
signal Huf57_width     : std_logic_vector(  3 downto 0);
signal Huf58_width     : std_logic_vector(  3 downto 0);
signal Huf59_width     : std_logic_vector(  3 downto 0);
signal Huf60_width     : std_logic_vector(  3 downto 0);
signal Huf61_width     : std_logic_vector(  3 downto 0);
signal Huf62_width     : std_logic_vector(  3 downto 0);
signal Huf63_width     : std_logic_vector(  3 downto 0);
signal Huf64_width     : std_logic_vector(  3 downto 0);

signal Huf01_width_i, Huf02_width_i, Huf03_width_i, Huf04_width_i, Huf05_width_i, Huf06_width_i, Huf07_width_i, Huf08_width_i, Huf09_width_i, Huf10_width_i, Huf11_width_i, Huf12_width_i, Huf13_width_i, Huf14_width_i, Huf15_width_i, Huf16_width_i : integer; 
signal Huf17_width_i, Huf18_width_i, Huf19_width_i, Huf20_width_i, Huf21_width_i, Huf22_width_i, Huf23_width_i, Huf24_width_i, Huf25_width_i, Huf26_width_i, Huf27_width_i, Huf28_width_i, Huf29_width_i, Huf30_width_i, Huf31_width_i, Huf32_width_i : integer;  
signal Huf33_width_i, Huf34_width_i, Huf35_width_i, Huf36_width_i, Huf37_width_i, Huf38_width_i, Huf39_width_i, Huf40_width_i, Huf41_width_i, Huf42_width_i, Huf43_width_i, Huf44_width_i, Huf45_width_i, Huf46_width_i, Huf47_width_i, Huf48_width_i : integer;  
signal Huf49_width_i, Huf50_width_i, Huf51_width_i, Huf52_width_i, Huf53_width_i, Huf54_width_i, Huf55_width_i, Huf56_width_i, Huf57_width_i, Huf58_width_i, Huf59_width_i, Huf60_width_i, Huf61_width_i, Huf62_width_i, Huf63_width_i, Huf64_width_i : integer;

signal Huf01_04_coded  : std_logic_vector(4*M-1 downto 0);
signal Huf05_08_coded  : std_logic_vector(4*M-1 downto 0);
signal Huf09_12_coded  : std_logic_vector(4*M-1 downto 0);
signal Huf13_16_coded  : std_logic_vector(4*M-1 downto 0);
signal Huf17_20_coded  : std_logic_vector(4*M-1 downto 0);
signal Huf21_24_coded  : std_logic_vector(4*M-1 downto 0);
signal Huf25_28_coded  : std_logic_vector(4*M-1 downto 0);
signal Huf28_32_coded  : std_logic_vector(4*M-1 downto 0);
signal Huf33_36_coded  : std_logic_vector(4*M-1 downto 0);
signal Huf37_40_coded  : std_logic_vector(4*M-1 downto 0);
signal Huf41_44_coded  : std_logic_vector(4*M-1 downto 0);
signal Huf45_48_coded  : std_logic_vector(4*M-1 downto 0);
signal Huf49_52_coded  : std_logic_vector(4*M-1 downto 0);
signal Huf53_56_coded  : std_logic_vector(4*M-1 downto 0);
signal Huf57_60_coded  : std_logic_vector(4*M-1 downto 0);
signal Huf61_64_coded  : std_logic_vector(4*M-1 downto 0);

signal Huf01_04_width  : integer;
signal Huf05_08_width  : integer;
signal Huf09_12_width  : integer;
signal Huf13_16_width  : integer;
signal Huf17_20_width  : integer;
signal Huf21_24_width  : integer;
signal Huf25_28_width  : integer;
signal Huf28_32_width  : integer;
signal Huf33_36_width  : integer;
signal Huf37_40_width  : integer;
signal Huf41_44_width  : integer;
signal Huf45_48_width  : integer;
signal Huf49_52_width  : integer;
signal Huf53_56_width  : integer;
signal Huf57_60_width  : integer;
signal Huf61_64_width  : integer;

signal Huf01_16_coded  : std_logic_vector(16*M-1 downto 0);
signal Huf17_32_coded  : std_logic_vector(16*M-1 downto 0);
signal Huf33_48_coded  : std_logic_vector(16*M-1 downto 0);
signal Huf49_64_coded  : std_logic_vector(16*M-1 downto 0);

signal Huf01_16_width  : integer;
signal Huf17_32_width  : integer;
signal Huf33_48_width  : integer;
signal Huf49_64_width  : integer;

signal Huf01_64_coded  : std_logic_vector(64*M-1 downto 0);

signal Huf01_64_width  : integer;

--signal pointer       : integer; -- range 0 to (2**(pointer'left+1) - 1);
--signal out_buff      : std_logic_vector( W + M - 1 downto 0);
--signal Huf_en        : std_logic;
--signal Huf_eof       : std_logic;
--signal Huf_eof2      : std_logic;
--
--signal Huf_width_i   : integer range 0 to 15;
--signal pointer_i     : integer; -- range 0 to (2**(pointer'left+1) - 1);
--
--signal old_tail_M    : integer ;
--signal new_val_L     : integer ;
--signal new_val_M     : integer ;

begin

-- Huffman table initialisation
  init : process (clk)
  begin
    if rising_edge(clk) then
       if init_en = '1' then
           Huf_code_m (conv_integer('0' & alpha_data)) <= alpha_code ;
           Huf_width_m(conv_integer('0' & alpha_data)) <= alpha_width; 
       end if;
    end if;
  end process init;

-- conversion
  conv : process (clk)
  begin
    if rising_edge(clk) then
       --if en_in = '1' then
          Huf01_coded  <= Huf_code_m (conv_integer('0' & d01_in));
          Huf02_coded  <= Huf_code_m (conv_integer('0' & d02_in));
          Huf03_coded  <= Huf_code_m (conv_integer('0' & d03_in));
          Huf04_coded  <= Huf_code_m (conv_integer('0' & d04_in));
          Huf05_coded  <= Huf_code_m (conv_integer('0' & d05_in));
          Huf06_coded  <= Huf_code_m (conv_integer('0' & d06_in));
          Huf07_coded  <= Huf_code_m (conv_integer('0' & d07_in));
          Huf08_coded  <= Huf_code_m (conv_integer('0' & d08_in));
          Huf09_coded  <= Huf_code_m (conv_integer('0' & d09_in));
          Huf10_coded  <= Huf_code_m (conv_integer('0' & d10_in));
          Huf11_coded  <= Huf_code_m (conv_integer('0' & d11_in));
          Huf12_coded  <= Huf_code_m (conv_integer('0' & d12_in));
          Huf13_coded  <= Huf_code_m (conv_integer('0' & d13_in));
          Huf14_coded  <= Huf_code_m (conv_integer('0' & d14_in));
          Huf15_coded  <= Huf_code_m (conv_integer('0' & d15_in));
          Huf16_coded  <= Huf_code_m (conv_integer('0' & d16_in));
          Huf17_coded  <= Huf_code_m (conv_integer('0' & d17_in));
          Huf18_coded  <= Huf_code_m (conv_integer('0' & d18_in));
          Huf19_coded  <= Huf_code_m (conv_integer('0' & d19_in));
          Huf20_coded  <= Huf_code_m (conv_integer('0' & d20_in));
          Huf21_coded  <= Huf_code_m (conv_integer('0' & d21_in));
          Huf22_coded  <= Huf_code_m (conv_integer('0' & d22_in));
          Huf23_coded  <= Huf_code_m (conv_integer('0' & d23_in));
          Huf24_coded  <= Huf_code_m (conv_integer('0' & d24_in));
          Huf25_coded  <= Huf_code_m (conv_integer('0' & d25_in));
          Huf26_coded  <= Huf_code_m (conv_integer('0' & d26_in));
          Huf27_coded  <= Huf_code_m (conv_integer('0' & d27_in));
          Huf28_coded  <= Huf_code_m (conv_integer('0' & d28_in));
          Huf29_coded  <= Huf_code_m (conv_integer('0' & d29_in));
          Huf30_coded  <= Huf_code_m (conv_integer('0' & d30_in));
          Huf31_coded  <= Huf_code_m (conv_integer('0' & d31_in));
          Huf32_coded  <= Huf_code_m (conv_integer('0' & d32_in));
          Huf33_coded  <= Huf_code_m (conv_integer('0' & d33_in));
          Huf34_coded  <= Huf_code_m (conv_integer('0' & d34_in));
          Huf35_coded  <= Huf_code_m (conv_integer('0' & d35_in));
          Huf36_coded  <= Huf_code_m (conv_integer('0' & d36_in));
          Huf37_coded  <= Huf_code_m (conv_integer('0' & d37_in));
          Huf38_coded  <= Huf_code_m (conv_integer('0' & d38_in));
          Huf39_coded  <= Huf_code_m (conv_integer('0' & d39_in));
          Huf40_coded  <= Huf_code_m (conv_integer('0' & d40_in));
          Huf41_coded  <= Huf_code_m (conv_integer('0' & d41_in));
          Huf42_coded  <= Huf_code_m (conv_integer('0' & d42_in));
          Huf43_coded  <= Huf_code_m (conv_integer('0' & d43_in));
          Huf44_coded  <= Huf_code_m (conv_integer('0' & d44_in));
          Huf45_coded  <= Huf_code_m (conv_integer('0' & d45_in));
          Huf46_coded  <= Huf_code_m (conv_integer('0' & d46_in));
          Huf47_coded  <= Huf_code_m (conv_integer('0' & d47_in));
          Huf48_coded  <= Huf_code_m (conv_integer('0' & d48_in));
          Huf49_coded  <= Huf_code_m (conv_integer('0' & d49_in));
          Huf50_coded  <= Huf_code_m (conv_integer('0' & d50_in));
          Huf51_coded  <= Huf_code_m (conv_integer('0' & d51_in));
          Huf52_coded  <= Huf_code_m (conv_integer('0' & d52_in));
          Huf53_coded  <= Huf_code_m (conv_integer('0' & d53_in));
          Huf54_coded  <= Huf_code_m (conv_integer('0' & d54_in));
          Huf55_coded  <= Huf_code_m (conv_integer('0' & d55_in));
          Huf56_coded  <= Huf_code_m (conv_integer('0' & d56_in));
          Huf57_coded  <= Huf_code_m (conv_integer('0' & d57_in));
          Huf58_coded  <= Huf_code_m (conv_integer('0' & d58_in));
          Huf59_coded  <= Huf_code_m (conv_integer('0' & d59_in));
          Huf60_coded  <= Huf_code_m (conv_integer('0' & d60_in));
          Huf61_coded  <= Huf_code_m (conv_integer('0' & d61_in));
          Huf62_coded  <= Huf_code_m (conv_integer('0' & d62_in));
          Huf63_coded  <= Huf_code_m (conv_integer('0' & d63_in));
          Huf64_coded  <= Huf_code_m (conv_integer('0' & d64_in));

          Huf01_width  <= Huf_width_m(conv_integer('0' & d01_in));
          Huf02_width  <= Huf_width_m(conv_integer('0' & d02_in));
          Huf03_width  <= Huf_width_m(conv_integer('0' & d03_in));
          Huf04_width  <= Huf_width_m(conv_integer('0' & d04_in));
          Huf05_width  <= Huf_width_m(conv_integer('0' & d05_in));
          Huf06_width  <= Huf_width_m(conv_integer('0' & d06_in));
          Huf07_width  <= Huf_width_m(conv_integer('0' & d07_in));
          Huf08_width  <= Huf_width_m(conv_integer('0' & d08_in));
          Huf09_width  <= Huf_width_m(conv_integer('0' & d09_in));
          Huf10_width  <= Huf_width_m(conv_integer('0' & d10_in));
          Huf11_width  <= Huf_width_m(conv_integer('0' & d11_in));
          Huf12_width  <= Huf_width_m(conv_integer('0' & d12_in));
          Huf13_width  <= Huf_width_m(conv_integer('0' & d13_in));
          Huf14_width  <= Huf_width_m(conv_integer('0' & d14_in));
          Huf15_width  <= Huf_width_m(conv_integer('0' & d15_in));
          Huf16_width  <= Huf_width_m(conv_integer('0' & d16_in));
          Huf17_width  <= Huf_width_m(conv_integer('0' & d17_in));
          Huf18_width  <= Huf_width_m(conv_integer('0' & d18_in));
          Huf19_width  <= Huf_width_m(conv_integer('0' & d19_in));
          Huf20_width  <= Huf_width_m(conv_integer('0' & d20_in));
          Huf21_width  <= Huf_width_m(conv_integer('0' & d21_in));
          Huf22_width  <= Huf_width_m(conv_integer('0' & d22_in));
          Huf23_width  <= Huf_width_m(conv_integer('0' & d23_in));
          Huf24_width  <= Huf_width_m(conv_integer('0' & d24_in));
          Huf25_width  <= Huf_width_m(conv_integer('0' & d25_in));
          Huf26_width  <= Huf_width_m(conv_integer('0' & d26_in));
          Huf27_width  <= Huf_width_m(conv_integer('0' & d27_in));
          Huf28_width  <= Huf_width_m(conv_integer('0' & d28_in));
          Huf29_width  <= Huf_width_m(conv_integer('0' & d29_in));
          Huf30_width  <= Huf_width_m(conv_integer('0' & d30_in));
          Huf31_width  <= Huf_width_m(conv_integer('0' & d31_in));
          Huf32_width  <= Huf_width_m(conv_integer('0' & d32_in));
          Huf33_width  <= Huf_width_m(conv_integer('0' & d33_in));
          Huf34_width  <= Huf_width_m(conv_integer('0' & d34_in));
          Huf35_width  <= Huf_width_m(conv_integer('0' & d35_in));
          Huf36_width  <= Huf_width_m(conv_integer('0' & d36_in));
          Huf37_width  <= Huf_width_m(conv_integer('0' & d37_in));
          Huf38_width  <= Huf_width_m(conv_integer('0' & d38_in));
          Huf39_width  <= Huf_width_m(conv_integer('0' & d39_in));
          Huf40_width  <= Huf_width_m(conv_integer('0' & d40_in));
          Huf41_width  <= Huf_width_m(conv_integer('0' & d41_in));
          Huf42_width  <= Huf_width_m(conv_integer('0' & d42_in));
          Huf43_width  <= Huf_width_m(conv_integer('0' & d43_in));
          Huf44_width  <= Huf_width_m(conv_integer('0' & d44_in));
          Huf45_width  <= Huf_width_m(conv_integer('0' & d45_in));
          Huf46_width  <= Huf_width_m(conv_integer('0' & d46_in));
          Huf47_width  <= Huf_width_m(conv_integer('0' & d47_in));
          Huf48_width  <= Huf_width_m(conv_integer('0' & d48_in));
          Huf49_width  <= Huf_width_m(conv_integer('0' & d49_in));
          Huf50_width  <= Huf_width_m(conv_integer('0' & d50_in));
          Huf51_width  <= Huf_width_m(conv_integer('0' & d51_in));
          Huf52_width  <= Huf_width_m(conv_integer('0' & d52_in));
          Huf53_width  <= Huf_width_m(conv_integer('0' & d53_in));
          Huf54_width  <= Huf_width_m(conv_integer('0' & d54_in));
          Huf55_width  <= Huf_width_m(conv_integer('0' & d55_in));
          Huf56_width  <= Huf_width_m(conv_integer('0' & d56_in));
          Huf57_width  <= Huf_width_m(conv_integer('0' & d57_in));
          Huf58_width  <= Huf_width_m(conv_integer('0' & d58_in));
          Huf59_width  <= Huf_width_m(conv_integer('0' & d59_in));
          Huf60_width  <= Huf_width_m(conv_integer('0' & d60_in));
          Huf61_width  <= Huf_width_m(conv_integer('0' & d61_in));
          Huf62_width  <= Huf_width_m(conv_integer('0' & d62_in));
          Huf63_width  <= Huf_width_m(conv_integer('0' & d63_in));
          Huf64_width  <= Huf_width_m(conv_integer('0' & d64_in));
       --end if;
    end if;
  end process conv;

Huf01_width_i <= conv_integer('0' & Huf01_width);
Huf02_width_i <= conv_integer('0' & Huf02_width);
Huf03_width_i <= conv_integer('0' & Huf03_width);
Huf04_width_i <= conv_integer('0' & Huf04_width);
Huf05_width_i <= conv_integer('0' & Huf05_width);
Huf06_width_i <= conv_integer('0' & Huf06_width);
Huf07_width_i <= conv_integer('0' & Huf07_width);
Huf08_width_i <= conv_integer('0' & Huf08_width);
Huf09_width_i <= conv_integer('0' & Huf09_width);
Huf10_width_i <= conv_integer('0' & Huf10_width);
Huf11_width_i <= conv_integer('0' & Huf11_width);
Huf12_width_i <= conv_integer('0' & Huf12_width);
Huf13_width_i <= conv_integer('0' & Huf13_width);
Huf14_width_i <= conv_integer('0' & Huf14_width);
Huf15_width_i <= conv_integer('0' & Huf15_width);
Huf16_width_i <= conv_integer('0' & Huf16_width);
Huf17_width_i <= conv_integer('0' & Huf17_width);
Huf18_width_i <= conv_integer('0' & Huf18_width);
Huf19_width_i <= conv_integer('0' & Huf19_width);
Huf20_width_i <= conv_integer('0' & Huf20_width);
Huf21_width_i <= conv_integer('0' & Huf21_width);
Huf22_width_i <= conv_integer('0' & Huf22_width);
Huf23_width_i <= conv_integer('0' & Huf23_width);
Huf24_width_i <= conv_integer('0' & Huf24_width);
Huf25_width_i <= conv_integer('0' & Huf25_width);
Huf26_width_i <= conv_integer('0' & Huf26_width);
Huf27_width_i <= conv_integer('0' & Huf27_width);
Huf28_width_i <= conv_integer('0' & Huf28_width);
Huf29_width_i <= conv_integer('0' & Huf29_width);
Huf30_width_i <= conv_integer('0' & Huf30_width);
Huf31_width_i <= conv_integer('0' & Huf31_width);
Huf32_width_i <= conv_integer('0' & Huf32_width);
Huf33_width_i <= conv_integer('0' & Huf33_width);
Huf34_width_i <= conv_integer('0' & Huf34_width);
Huf35_width_i <= conv_integer('0' & Huf35_width);
Huf36_width_i <= conv_integer('0' & Huf36_width);
Huf37_width_i <= conv_integer('0' & Huf37_width);
Huf38_width_i <= conv_integer('0' & Huf38_width);
Huf39_width_i <= conv_integer('0' & Huf39_width);
Huf40_width_i <= conv_integer('0' & Huf40_width);
Huf41_width_i <= conv_integer('0' & Huf41_width);
Huf42_width_i <= conv_integer('0' & Huf42_width);
Huf43_width_i <= conv_integer('0' & Huf43_width);
Huf44_width_i <= conv_integer('0' & Huf44_width);
Huf45_width_i <= conv_integer('0' & Huf45_width);
Huf46_width_i <= conv_integer('0' & Huf46_width);
Huf47_width_i <= conv_integer('0' & Huf47_width);
Huf48_width_i <= conv_integer('0' & Huf48_width);
Huf49_width_i <= conv_integer('0' & Huf49_width);
Huf50_width_i <= conv_integer('0' & Huf50_width);
Huf51_width_i <= conv_integer('0' & Huf51_width);
Huf52_width_i <= conv_integer('0' & Huf52_width);
Huf53_width_i <= conv_integer('0' & Huf53_width);
Huf54_width_i <= conv_integer('0' & Huf54_width);
Huf55_width_i <= conv_integer('0' & Huf55_width);
Huf56_width_i <= conv_integer('0' & Huf56_width);
Huf57_width_i <= conv_integer('0' & Huf57_width);
Huf58_width_i <= conv_integer('0' & Huf58_width);
Huf59_width_i <= conv_integer('0' & Huf59_width);
Huf60_width_i <= conv_integer('0' & Huf60_width);
Huf61_width_i <= conv_integer('0' & Huf61_width);
Huf62_width_i <= conv_integer('0' & Huf62_width);
Huf63_width_i <= conv_integer('0' & Huf63_width);
Huf64_width_i <= conv_integer('0' & Huf64_width);

  p_shifts : process (clk, rst)
  begin
    if rst = '1' then
       Huf01_04_coded <= (others => '0'); Huf05_08_coded <= (others => '0'); Huf09_12_coded <= (others => '0'); Huf13_16_coded <= (others => '0');
       Huf17_20_coded <= (others => '0'); Huf21_24_coded <= (others => '0'); Huf25_28_coded <= (others => '0'); Huf28_32_coded <= (others => '0');
       Huf33_36_coded <= (others => '0'); Huf37_40_coded <= (others => '0'); Huf41_44_coded <= (others => '0'); Huf45_48_coded <= (others => '0');
       Huf49_52_coded <= (others => '0'); Huf53_56_coded <= (others => '0'); Huf57_60_coded <= (others => '0'); Huf61_64_coded <= (others => '0');
       Huf01_04_width <= 0; Huf05_08_width <= 0; Huf09_12_width <= 0; Huf13_16_width <= 0;
       Huf17_20_width <= 0; Huf21_24_width <= 0; Huf25_28_width <= 0; Huf28_32_width <= 0;
       Huf33_36_width <= 0; Huf37_40_width <= 0; Huf41_44_width <= 0; Huf45_48_width <= 0;
       Huf49_52_width <= 0; Huf53_56_width <= 0; Huf57_60_width <= 0; Huf61_64_width <= 0;
       Huf01_16_coded <= (others => '0'); Huf17_32_coded <= (others => '0');  Huf33_48_coded <= (others => '0'); Huf49_64_coded <= (others => '0');
       Huf01_16_width <= 0; Huf17_32_width <= 0; Huf33_48_width <= 0; Huf49_64_width <= 0;
       Huf01_64_coded <= (others => '0');
       Huf01_64_width <= 0;     
    elsif rising_edge(clk) then
       Huf01_04_coded(Huf04_width_i+Huf03_width_i+Huf02_width_i+Huf01_width_i-1 downto 0) <= Huf04_coded(Huf04_width_i-1 downto 0) & Huf03_coded(Huf03_width_i-1 downto 0) & Huf02_coded(Huf02_width_i-1 downto 0) & Huf01_coded(Huf01_width_i-1 downto 0) ;
       Huf05_08_coded(Huf08_width_i+Huf07_width_i+Huf06_width_i+Huf05_width_i-1 downto 0) <= Huf08_coded(Huf08_width_i-1 downto 0) & Huf07_coded(Huf07_width_i-1 downto 0) & Huf06_coded(Huf06_width_i-1 downto 0) & Huf05_coded(Huf05_width_i-1 downto 0) ;
       Huf09_12_coded(Huf12_width_i+Huf11_width_i+Huf10_width_i+Huf09_width_i-1 downto 0) <= Huf12_coded(Huf12_width_i-1 downto 0) & Huf11_coded(Huf11_width_i-1 downto 0) & Huf10_coded(Huf10_width_i-1 downto 0) & Huf09_coded(Huf09_width_i-1 downto 0) ;
       Huf13_16_coded(Huf16_width_i+Huf15_width_i+Huf14_width_i+Huf13_width_i-1 downto 0) <= Huf16_coded(Huf16_width_i-1 downto 0) & Huf15_coded(Huf15_width_i-1 downto 0) & Huf14_coded(Huf14_width_i-1 downto 0) & Huf13_coded(Huf13_width_i-1 downto 0) ;
       Huf17_20_coded(Huf20_width_i+Huf19_width_i+Huf18_width_i+Huf17_width_i-1 downto 0) <= Huf20_coded(Huf20_width_i-1 downto 0) & Huf19_coded(Huf19_width_i-1 downto 0) & Huf18_coded(Huf18_width_i-1 downto 0) & Huf17_coded(Huf17_width_i-1 downto 0) ;
       Huf21_24_coded(Huf24_width_i+Huf23_width_i+Huf22_width_i+Huf21_width_i-1 downto 0) <= Huf24_coded(Huf24_width_i-1 downto 0) & Huf23_coded(Huf23_width_i-1 downto 0) & Huf22_coded(Huf22_width_i-1 downto 0) & Huf21_coded(Huf21_width_i-1 downto 0) ;
       Huf25_28_coded(Huf28_width_i+Huf27_width_i+Huf26_width_i+Huf25_width_i-1 downto 0) <= Huf28_coded(Huf28_width_i-1 downto 0) & Huf27_coded(Huf27_width_i-1 downto 0) & Huf26_coded(Huf26_width_i-1 downto 0) & Huf25_coded(Huf25_width_i-1 downto 0) ;
       Huf28_32_coded(Huf32_width_i+Huf31_width_i+Huf30_width_i+Huf29_width_i-1 downto 0) <= Huf32_coded(Huf32_width_i-1 downto 0) & Huf31_coded(Huf31_width_i-1 downto 0) & Huf30_coded(Huf30_width_i-1 downto 0) & Huf29_coded(Huf29_width_i-1 downto 0) ;
       Huf33_36_coded(Huf36_width_i+Huf35_width_i+Huf34_width_i+Huf33_width_i-1 downto 0) <= Huf36_coded(Huf36_width_i-1 downto 0) & Huf35_coded(Huf35_width_i-1 downto 0) & Huf34_coded(Huf34_width_i-1 downto 0) & Huf33_coded(Huf33_width_i-1 downto 0) ;
       Huf37_40_coded(Huf40_width_i+Huf39_width_i+Huf38_width_i+Huf37_width_i-1 downto 0) <= Huf40_coded(Huf40_width_i-1 downto 0) & Huf39_coded(Huf39_width_i-1 downto 0) & Huf38_coded(Huf38_width_i-1 downto 0) & Huf37_coded(Huf37_width_i-1 downto 0) ;
       Huf41_44_coded(Huf44_width_i+Huf43_width_i+Huf42_width_i+Huf41_width_i-1 downto 0) <= Huf44_coded(Huf44_width_i-1 downto 0) & Huf43_coded(Huf43_width_i-1 downto 0) & Huf42_coded(Huf42_width_i-1 downto 0) & Huf41_coded(Huf41_width_i-1 downto 0) ;
       Huf45_48_coded(Huf48_width_i+Huf47_width_i+Huf46_width_i+Huf45_width_i-1 downto 0) <= Huf48_coded(Huf48_width_i-1 downto 0) & Huf47_coded(Huf47_width_i-1 downto 0) & Huf46_coded(Huf46_width_i-1 downto 0) & Huf45_coded(Huf45_width_i-1 downto 0) ;
       Huf49_52_coded(Huf52_width_i+Huf51_width_i+Huf50_width_i+Huf49_width_i-1 downto 0) <= Huf52_coded(Huf52_width_i-1 downto 0) & Huf51_coded(Huf51_width_i-1 downto 0) & Huf50_coded(Huf50_width_i-1 downto 0) & Huf49_coded(Huf49_width_i-1 downto 0) ;
       Huf53_56_coded(Huf56_width_i+Huf55_width_i+Huf54_width_i+Huf53_width_i-1 downto 0) <= Huf56_coded(Huf56_width_i-1 downto 0) & Huf55_coded(Huf55_width_i-1 downto 0) & Huf54_coded(Huf54_width_i-1 downto 0) & Huf53_coded(Huf53_width_i-1 downto 0) ;
       Huf57_60_coded(Huf60_width_i+Huf59_width_i+Huf58_width_i+Huf57_width_i-1 downto 0) <= Huf60_coded(Huf60_width_i-1 downto 0) & Huf59_coded(Huf59_width_i-1 downto 0) & Huf58_coded(Huf58_width_i-1 downto 0) & Huf57_coded(Huf57_width_i-1 downto 0) ;
       Huf61_64_coded(Huf64_width_i+Huf63_width_i+Huf62_width_i+Huf61_width_i-1 downto 0) <= Huf64_coded(Huf64_width_i-1 downto 0) & Huf63_coded(Huf63_width_i-1 downto 0) & Huf62_coded(Huf62_width_i-1 downto 0) & Huf61_coded(Huf61_width_i-1 downto 0) ;
       Huf01_04_coded(Huf01_04_coded'left downto Huf04_width_i+Huf03_width_i+Huf02_width_i+Huf01_width_i) <= (others => '0');
       Huf05_08_coded(Huf05_08_coded'left downto Huf08_width_i+Huf07_width_i+Huf06_width_i+Huf05_width_i) <= (others => '0');
       Huf09_12_coded(Huf09_12_coded'left downto Huf12_width_i+Huf11_width_i+Huf10_width_i+Huf09_width_i) <= (others => '0');
       Huf13_16_coded(Huf13_16_coded'left downto Huf16_width_i+Huf15_width_i+Huf14_width_i+Huf13_width_i) <= (others => '0');
       Huf17_20_coded(Huf17_20_coded'left downto Huf20_width_i+Huf19_width_i+Huf18_width_i+Huf17_width_i) <= (others => '0');
       Huf21_24_coded(Huf21_24_coded'left downto Huf24_width_i+Huf23_width_i+Huf22_width_i+Huf21_width_i) <= (others => '0');
       Huf25_28_coded(Huf25_28_coded'left downto Huf28_width_i+Huf27_width_i+Huf26_width_i+Huf25_width_i) <= (others => '0');
       Huf28_32_coded(Huf28_32_coded'left downto Huf32_width_i+Huf31_width_i+Huf30_width_i+Huf29_width_i) <= (others => '0');
       Huf33_36_coded(Huf33_36_coded'left downto Huf36_width_i+Huf35_width_i+Huf34_width_i+Huf33_width_i) <= (others => '0');
       Huf37_40_coded(Huf37_40_coded'left downto Huf40_width_i+Huf39_width_i+Huf38_width_i+Huf37_width_i) <= (others => '0');
       Huf41_44_coded(Huf41_44_coded'left downto Huf44_width_i+Huf43_width_i+Huf42_width_i+Huf41_width_i) <= (others => '0');
       Huf45_48_coded(Huf45_48_coded'left downto Huf48_width_i+Huf47_width_i+Huf46_width_i+Huf45_width_i) <= (others => '0');
       Huf49_52_coded(Huf49_52_coded'left downto Huf52_width_i+Huf51_width_i+Huf50_width_i+Huf49_width_i) <= (others => '0');
       Huf53_56_coded(Huf53_56_coded'left downto Huf56_width_i+Huf55_width_i+Huf54_width_i+Huf53_width_i) <= (others => '0');
       Huf57_60_coded(Huf57_60_coded'left downto Huf60_width_i+Huf59_width_i+Huf58_width_i+Huf57_width_i) <= (others => '0');
       Huf61_64_coded(Huf61_64_coded'left downto Huf64_width_i+Huf63_width_i+Huf62_width_i+Huf61_width_i) <= (others => '0');

       Huf01_04_width <= Huf04_width_i + Huf03_width_i + Huf02_width_i + Huf01_width_i ;
       Huf05_08_width <= Huf08_width_i + Huf07_width_i + Huf06_width_i + Huf05_width_i ;
       Huf09_12_width <= Huf12_width_i + Huf11_width_i + Huf10_width_i + Huf09_width_i ;
       Huf13_16_width <= Huf16_width_i + Huf15_width_i + Huf14_width_i + Huf13_width_i ;
       Huf17_20_width <= Huf20_width_i + Huf19_width_i + Huf18_width_i + Huf17_width_i ;
       Huf21_24_width <= Huf24_width_i + Huf23_width_i + Huf22_width_i + Huf21_width_i ;
       Huf25_28_width <= Huf28_width_i + Huf27_width_i + Huf26_width_i + Huf25_width_i ;
       Huf28_32_width <= Huf32_width_i + Huf31_width_i + Huf30_width_i + Huf29_width_i ;
       Huf33_36_width <= Huf36_width_i + Huf35_width_i + Huf34_width_i + Huf33_width_i ;
       Huf37_40_width <= Huf40_width_i + Huf39_width_i + Huf38_width_i + Huf37_width_i ;
       Huf41_44_width <= Huf44_width_i + Huf43_width_i + Huf42_width_i + Huf41_width_i ;
       Huf45_48_width <= Huf48_width_i + Huf47_width_i + Huf46_width_i + Huf45_width_i ;
       Huf49_52_width <= Huf52_width_i + Huf51_width_i + Huf50_width_i + Huf49_width_i ;
       Huf53_56_width <= Huf56_width_i + Huf55_width_i + Huf54_width_i + Huf53_width_i ;
       Huf57_60_width <= Huf60_width_i + Huf59_width_i + Huf58_width_i + Huf57_width_i ;
       Huf61_64_width <= Huf64_width_i + Huf63_width_i + Huf62_width_i + Huf61_width_i ;

       Huf01_16_coded(Huf13_16_width + Huf09_12_width + Huf05_08_width + Huf01_04_width-1 downto 0) <= Huf13_16_coded(Huf13_16_width-1 downto 0) & Huf09_12_coded(Huf09_12_width-1 downto 0) & Huf05_08_coded(Huf05_08_width-1 downto 0) & Huf01_04_coded(Huf01_04_width-1 downto 0);
       Huf17_32_coded(Huf28_32_width + Huf25_28_width + Huf21_24_width + Huf17_20_width-1 downto 0) <= Huf28_32_coded(Huf28_32_width-1 downto 0) & Huf25_28_coded(Huf25_28_width-1 downto 0) & Huf21_24_coded(Huf21_24_width-1 downto 0) & Huf17_20_coded(Huf17_20_width-1 downto 0);
       Huf33_48_coded(Huf45_48_width + Huf41_44_width + Huf37_40_width + Huf33_36_width-1 downto 0) <= Huf45_48_coded(Huf45_48_width-1 downto 0) & Huf41_44_coded(Huf41_44_width-1 downto 0) & Huf37_40_coded(Huf37_40_width-1 downto 0) & Huf33_36_coded(Huf33_36_width-1 downto 0);
       Huf49_64_coded(Huf61_64_width + Huf57_60_width + Huf53_56_width + Huf49_52_width-1 downto 0) <= Huf61_64_coded(Huf61_64_width-1 downto 0) & Huf57_60_coded(Huf57_60_width-1 downto 0) & Huf53_56_coded(Huf53_56_width-1 downto 0) & Huf49_52_coded(Huf49_52_width-1 downto 0);
       Huf01_16_coded(Huf01_16_coded'left downto Huf13_16_width + Huf09_12_width + Huf05_08_width + Huf01_04_width) <= (others => '0');
       Huf17_32_coded(Huf17_32_coded'left downto Huf28_32_width + Huf25_28_width + Huf21_24_width + Huf17_20_width) <= (others => '0');
       Huf33_48_coded(Huf33_48_coded'left downto Huf45_48_width + Huf41_44_width + Huf37_40_width + Huf33_36_width) <= (others => '0');
       Huf49_64_coded(Huf49_64_coded'left downto Huf61_64_width + Huf57_60_width + Huf53_56_width + Huf49_52_width) <= (others => '0');

       Huf01_16_width <= Huf13_16_width + Huf09_12_width + Huf05_08_width + Huf01_04_width;
       Huf17_32_width <= Huf28_32_width + Huf25_28_width + Huf21_24_width + Huf17_20_width;
       Huf33_48_width <= Huf45_48_width + Huf41_44_width + Huf37_40_width + Huf33_36_width;
       Huf49_64_width <= Huf61_64_width + Huf57_60_width + Huf53_56_width + Huf49_52_width;

       Huf01_64_coded(Huf49_64_width + Huf33_48_width + Huf17_32_width + Huf01_16_width-1 downto 0) <= Huf49_64_coded(Huf49_64_width-1 downto 0) & Huf33_48_coded(Huf33_48_width-1 downto 0) & Huf17_32_coded(Huf17_32_width-1 downto 0) & Huf01_16_coded(Huf01_16_width-1 downto 0) ;
       Huf01_64_coded(Huf01_64_coded'left downto Huf49_64_width + Huf33_48_width + Huf17_32_width + Huf01_16_width) <= (others => '0');

       Huf01_64_width <= Huf49_64_width + Huf33_48_width + Huf17_32_width + Huf01_16_width;
    end if;
  end process p_shifts;

d_out <= Huf01_64_coded;

end a;