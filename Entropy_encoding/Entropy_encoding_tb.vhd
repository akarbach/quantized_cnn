library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;

entity Entropy_encoding_tb is
    generic (
           mult_sum_CL   : string := "sum";
           mult_sum_PCA  : string := "mult";
           N             : integer :=   8; -- input data width
           Huff_wid      : integer :=  12; -- Huffman weight width                        (after change need nedd to update "Huff_code" matrix)
           Wh            : integer :=  16; -- Huffman unit output data width (Note W>=M)
           Wb            : integer := 128; -- output buffer data width
           depth         : integer :=  64; -- buffer depth
           burst         : integer :=  10;  -- buffer read burst

           PCA_en        : boolean := TRUE; --TRUE; -- PCA Enable/Bypass
           Huff_enc_en   : boolean := TRUE; --TRUE; -- Huffman encoder Enable/Bypass

           in_row        : integer := 20;
           in_col        : integer := 20
           );
end entity Entropy_encoding_tb;

architecture Entropy_encoding_tb of Entropy_encoding_tb is

component Entropy_encoding is
  generic (
           mult_sum_CL   : string := "sum";
           mult_sum_PCA  : string := "mult";
           N             : integer :=   8; -- input data width
           Huff_wid      : integer :=  12; --  Huffman weight width
           Wh            : integer :=  16; -- Huffman unit output data width (Note W>=M)
           Wb            : integer := 128; -- output buffer data width
           depth         : integer :=  64; -- buffer depth
           burst         : integer :=  10; -- buffer read burst

           PCA_en        : boolean := TRUE; -- PCA Enable/Bypass
           Huff_enc_en   : boolean := TRUE; -- Huffman encoder Enable/Bypasss

           in_row        : integer := 256;
           in_col        : integer := 256
           );
  port    (
           clk     : in std_logic;
           rst     : in std_logic;

           pca_w_en  : in  std_logic;
           pca_w_num : in  std_logic_vector (6 downto 0);
           pca_w_in  : in  std_logic_vector (7 downto 0);

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
end component;

signal clk     : std_logic;
signal rst     : std_logic;
signal pca_w_en  : std_logic;
signal pca_w_num : std_logic_vector (6 downto 0);
signal pca_w_in  : std_logic_vector (7 downto 0);
signal d_in    : std_logic_vector (N-1 downto 0);
signal en_in   : std_logic;
signal sof_in  : std_logic; -- start of frame

signal buf_rd  : std_logic;
signal buf_num : std_logic_vector (5      downto 0);

signal d_out   : std_logic_vector (Wb-1 downto 0);
signal en_out  : std_logic_vector (64  -1 downto 0);
signal sof_out : std_logic; -- start of frame

begin

DUT: Entropy_encoding generic map (
      mult_sum_CL  => mult_sum_CL  , 
      mult_sum_PCA => mult_sum_PCA ,
      N        => N       , -- input data width
      Huff_wid => Huff_wid, -- weight width
      Wh       => Wh      , -- Huffman unit output data width (Note W>=M)
      Wb       => Wb      , -- output data width

      depth    => depth   , -- buffer depth
      burst    => burst   , -- buffer read burst


      PCA_en      => PCA_en     ,
      Huff_enc_en => Huff_enc_en,

      in_row   => in_row  ,
      in_col   => in_col
      )
port map (
      clk     => clk      ,
      rst     => rst      ,

      pca_w_en  => pca_w_en   ,
      pca_w_num => pca_w_num  ,
      pca_w_in  => pca_w_in   ,

      d_in    => d_in     ,
      en_in   => en_in    ,
      sof_in  => sof_in   ,

      buf_rd  => buf_rd   ,
      buf_num => buf_num  ,
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
--
--  pca_w_en <= '0';
--  pca_w_num <= (others => '0');
--  pca_w_in <= x"59"; 
--  wait until rst = '0';
--  while true loop
--    pca_w_en <= '1';
--    for i in 0 to 63 loop
--      pca_w_en  <= '1';
--      pca_w_num <= pca_w_num + 1;
--      pca_w_in  <= pca_w_in(6 downto 0) & (pca_w_in(7) xor pca_w_in(6));       
--      wait until rising_edge(clk);
--    end loop;
--     pca_w_en <= '0';
--  end loop;
--end process;
--



process
begin
  en_in <= '0';
  sof_in <= '0';
  d_in <= x"59"; --(others => '0');
  wait until rst = '0';
  while true loop
    for i in 0 to 255 loop
       wait until rising_edge(clk);
    end loop;
    sof_in <= '1';
    for i in 0 to 255 loop
      en_in <= '1';
      d_in <= d_in(d_in'left-1 downto 0) & (d_in(d_in'left) xor d_in(d_in'left-1));    
      --d_in <= conv_std_logic_vector(i - 127, d_in'length);    
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



end Entropy_encoding_tb;