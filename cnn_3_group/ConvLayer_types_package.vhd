library ieee;
use ieee.std_logic_1164.all;

package ConvLayer_types_package is

constant           addr_w        : integer := 6;
constant           in_row        : integer := 10;
constant           in_col        : integer := 10;
--constant           Kernel_size   : integer := 3; -- 3/5/7
constant           N             : integer := 4;  -- input data/weigth width
--type data_mem_type is array ( 0 to 2**addr_w-1 ) of std_logic_vector(Kernel_size*Kernel_size*N-1 downto 0);

--type int_array is array (0 to 3) of integer range 0 to 15;
--type vec is array (natural range <>) of std_logic_vector;
--constant  Relu          : string := "yes";  --"no"/"yes"  -- nonlinear Relu function
--constant  BP            : string := "no";   --"no"/"yes"  -- Bypass
--constant  TP            : string := "no";   --"no"/"yes"  -- Test pattern output
--constant  mult_sum      : string := "sum"; --"mult"/"sum";
--constant  CL_inputs     : integer := 16; --160; -- number of inputs features
--constant  CL_outs       : integer := 96; --960; -- number of output features
--constant  N             : integer := 8; --W; -- input data width
--constant  M             : integer := 8; --W; -- input weight width
--constant  W             : integer := 8; -- output data width      (Note, W+SR <= N+M+4)
--constant  SR            : integer := 1; -- data shift right before output (deleted LSBs)
--constant  Huff_enc_en   : boolean := TRUE;--FALSE TRUE; -- Huffman encoder Enable/Bypass
--constant  Wh            : integer := 12; -- weight after huffman
--
--
type vec_in     is array (natural range <>) of std_logic_vector(N-1 downto 0);
type vec_out    is array (natural range <>) of std_logic_vector(N-1 downto 0);       -- (W-1 downto 0);
type vec_mavin  is array (natural range <>) of std_logic_vector(N + N + 5 downto 0);  -- (N + M +4 downto 0);
--type vec_h_out  is array (natural range <>) of std_logic_vector(Wh-1 downto 0);

end ConvLayer_types_package;	
