library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;
library work;
use work.ConvLayer_types_package.all;

entity Entropy_encoding_tb is
    generic (
           mult_sum_CL   : string := "mult"; -- "sum";
           mult_sum_PCA  : string := "sum";
           Kernel_size   : integer := 3; -- 3/5
           zero_padding  : string := "yes";  --"no"/"yes"
           stride        : integer := 1;
           CL_inputs     : integer := 6; -- number of inputs features
           CL_outs       : integer := 6; -- number of output features

           N             : integer :=   8; -- input data width
           M             : integer :=   8; -- data weight width
           SR_CL         : integer :=   1; -- data shift right before output (deleted LSBs)
           SR_PCA        : integer :=   6; -- data shift right before output (deleted LSBs)
           Huff_wid      : integer :=  12; -- Huffman weight maximum width                   (after change need nedd to update "Huff_code" matrix)
           Wh            : integer :=  16; -- Huffman unit output data width (Note W>=M)
           Wb            : integer := 128; -- output buffer data width
           depth         : integer :=  64; -- buffer depth
           burst         : integer :=  10; -- buffer read burst

           PCA_en        : boolean := TRUE; --TRUE; -- PCA Enable/Bypass
           Huff_enc_en   : boolean := TRUE;--FALSE; -- Huffman encoder Enable/Bypass

           in_row        : integer := 10;
           in_col        : integer := 10
           );
end entity Entropy_encoding_tb;

architecture Entropy_encoding_tb of Entropy_encoding_tb is

component Entropy_encoding is
  generic (
           mult_sum_CL   : string := "mult"; -- "sum";
           mult_sum_PCA  : string := "sum";
           Kernel_size   : integer := 5; -- 3/5
           zero_padding  : string := "yes";  --"no"/"yes"
           stride        : integer := 1;
           CL_inputs     : integer := 3; -- number of inputs features
           CL_outs       : integer := 4; -- number of output features

           N             : integer :=   8; -- input data width
           M             : integer :=   8; -- data weight width
           SR_CL         : integer :=   1; -- data shift right before output (deleted LSBs)
           SR_PCA        : integer :=   6; -- data shift right before output (deleted LSBs)
           Huff_wid      : integer :=  12; -- Huffman weight maximum width                   (after change need nedd to update "Huff_code" matrix)
           Wh            : integer :=  16; -- Huffman unit output data width (Note W>=M)
           Wb            : integer := 128; -- output buffer data width
           depth         : integer :=  64; -- buffer depth
           burst         : integer :=  10; -- buffer read burst

           PCA_en        : boolean := TRUE; --TRUE; -- PCA Enable/Bypass
           Huff_enc_en   : boolean := TRUE;--FALSE; -- Huffman encoder Enable/Bypass

           in_row        : integer := 3;
           in_col        : integer := 36
           );
  port    (
           clk       : in  std_logic;
           rst       : in  std_logic;
           d_in      : in  vec(0 to CL_inputs -1)(N-1 downto 0); --invec;                                      --std_logic_vector (N-1 downto 0);
           en_in     : in  std_logic;
           sof_in    : in  std_logic; -- start of frame
           eof       : in  std_logic; -- end of frame

           w_CLout_n : in  std_logic_vector( 7 downto 0);  -- address weight generators
           w_CLin_n  : in  std_logic_vector( 7 downto 0);  -- address weight generators
           --w_in      : in  std_logic_vector(M-1 downto 0);  -- value
           w_in      : in  std_logic_vector(M-1 downto 0); --vec(0 to CL_inputs -1)(M-1 downto 0);  -- value
           --w_num     : in  std_logic_vector(  4 downto 0);  -- number of weight
           w_en      : in  std_logic;
           w_inputN  : in std_logic_vector( 7 downto 0);         -- number of input that w_in is associated with
           w_lin_rdy : in std_logic;                             -- "ready" signal to load line to weight memory

           pca_w_en  : in  std_logic;
           pca_w_num : in  std_logic_vector (5 downto 0);
           pca_w_in  : in  std_logic_vector (7 downto 0);

           --sol     : in  std_logic; -- start of line
           --eof     : in  std_logic; -- end of frame

           buf_rd    : in  std_logic;
           buf_num   : in  std_logic_vector (5      downto 0);
           d_out     : out vec(0 to CL_outs -1)(Wh-1 downto 0); --std_logic_vector (Wb  -1 downto 0);
           en_out    : out std_logic_vector (CL_outs  -1 downto 0);
           sof_out   : out std_logic);
end component;

signal clk     : std_logic;
signal rst     : std_logic;
signal pca_w_en  : std_logic;
signal pca_w_num : std_logic_vector (5 downto 0);
signal pca_w_in  : std_logic_vector (7 downto 0);
signal d_in      : vec(0 to CL_inputs -1)(N-1 downto 0);
signal en_in   : std_logic;
signal sof_in  : std_logic; -- start of frame

signal buf_rd  : std_logic;
signal buf_num : std_logic_vector (5      downto 0);

signal eof       : std_logic; -- end of frame
signal w_CLout_n : std_logic_vector( 7 downto 0);  -- address weight generators
signal w_CLin_n  : std_logic_vector( 7 downto 0);  -- address weight generators
signal w_in      : std_logic_vector(M-1 downto 0); --vec(0 to CL_inputs -1)(M-1 downto 0);  -- value
signal w_en      : std_logic;
signal w_inputN  : std_logic_vector( 7 downto 0);         -- number of input that w_in is associated with
signal w_lin_rdy : std_logic;                             -- "ready" signal to load line to weight memory

signal d_out   : vec(0 to CL_outs -1)(Wh-1 downto 0);
signal en_out  : std_logic_vector (CL_outs  -1 downto 0);
signal sof_out : std_logic; -- start of frame

begin

process
begin
  en_in     <= '0';
  sof_in    <= '0';
  w_en      <= '0';
  w_lin_rdy <= '0'; 
  w_CLout_n(w_CLout_n'left downto 1) <= (others => '0');
  w_CLout_n(0) <= '1';
  --d_in <= x"59"; --(others => '0');
  wait until rst = '0';

  wait until rising_edge(clk);
  wait until rising_edge(clk);

     for j in 0 to CL_outs-1 loop
        for i in 0 to Kernel_size*Kernel_size-1 loop
           wait until rising_edge(clk); w_en <= '1'; w_lin_rdy <= '0';  w_in <= conv_std_logic_vector(i+j+1, w_in'length); w_inputN <= conv_std_logic_vector(i, w_inputN'length);
        end loop;
        wait until rising_edge(clk);    w_en <= '0'; w_lin_rdy <= '1';  w_CLin_n <= conv_std_logic_vector(j, w_CLin_n'length);
     end loop;

  wait until rising_edge(clk); w_lin_rdy <= '0'; 
  wait until rising_edge(clk);


--  while true loop

    sof_in <= '1';
    for j in 0 to 255 loop
       for i in 0 to CL_inputs-1 loop
          wait until rising_edge(clk); en_in <= '1'; d_in(i) <= conv_std_logic_vector(i+j+1, N);
       end loop;    
       wait until rising_edge(clk); en_in <= '0';
       sof_in <= '0';
    end loop;
--  end loop;
end process;


DUT: Entropy_encoding generic map (
      mult_sum_CL  => mult_sum_CL  , 
      mult_sum_PCA => mult_sum_PCA ,
      Kernel_size  =>  Kernel_size ,
      zero_padding =>  zero_padding,
      stride       =>  stride      ,
      CL_inputs    =>  CL_inputs   ,
      CL_outs      => CL_outs      ,
      N            => N            ,
      M            =>  M           ,
      SR_CL        =>  SR_CL       ,
      SR_PCA       =>  SR_PCA      ,


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

      d_in    => d_in     ,
      en_in   => en_in    ,
      sof_in  => sof_in   ,
      eof     => eof      ,

      w_CLout_n  => w_CLout_n ,
      w_CLin_n   => w_CLin_n  ,
      w_in       => w_in      ,
      w_en       => w_en      ,
      w_inputN   => w_inputN  ,
      w_lin_rdy  => w_lin_rdy ,

      pca_w_en  => pca_w_en   ,
      pca_w_num => pca_w_num  ,
      pca_w_in  => pca_w_in   ,

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




end Entropy_encoding_tb;