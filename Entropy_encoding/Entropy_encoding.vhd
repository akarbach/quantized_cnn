library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;
use ieee.numeric_std.all;    
--USE ieee.std_logic_arith.all;
library work;
--use work.types_packege.all;
use work.ConvLayer_types_package.all;

entity Entropy_encoding is
  generic (
  	       mult_sum_CL   : string := "mult"; -- "sum";
           mult_sum_PCA  : string := "sum";
           Kernel_size   : integer := 5; -- 3/5
           zero_padding  : string := "yes";  --"no"/"yes"
           stride        : integer := 1;
           CL_inputs     : integer := 3; -- number of inputs features
           number_output_features_g : integer := 4; -- number of output features

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

  	       in_row        : integer := 114;
  	       in_col        : integer := 114
  	       );
  port    (
           clk       : in  std_logic;
           rst       : in  std_logic;
           d_in      : in  vec(0 to CL_inputs -1)(N-1 downto 0); --invec;                                      --std_logic_vector (N-1 downto 0);
           en_in     : in  std_logic;
           sof_in    : in  std_logic; -- start of frame
           eof       : in  std_logic; -- end of frame

           w_unit_n  : in  std_logic_vector( 7 downto 0);  -- address weight generators,  8MSB - CL inputs, 8LSB - CL outputs
           --w_in      : in  std_logic_vector(M-1 downto 0);  -- value
           w_in      : in  vec(0 to CL_inputs -1)(M-1 downto 0);  -- value
           w_num     : in  std_logic_vector      (  4 downto 0);  -- number of weight
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
           d_out     : out vec(0 to number_output_features_g -1)(Wh-1 downto 0); --std_logic_vector (Wb  -1 downto 0);
           en_out    : out std_logic_vector (64  -1 downto 0);
           sof_out   : out std_logic);
end Entropy_encoding;

architecture a of Entropy_encoding is

constant PCAweightW   : integer := 8;

component ConvLayer_paralel_w is
  generic (
           Relu          : string := "yes";  --"no"/"yes"  -- nonlinear Relu function
           BP            : string := "no";   --"no"/"yes"  -- Bypass
           TP            : string := "no";   --"no"/"yes"  -- Test pattern output
           mult_sum      : string := "sum"; --"mult"/"sum";
           Kernel_size   : integer := 5; -- 3/5
           zero_padding  : string := "yes";  --"no"/"yes"
           stride        : integer := 1;
           CL_inputs     : integer := 3; -- number of inputs features
           CL_outs       : integer := 4; -- number of output features

           N             : integer := 8; --W; -- input data width
           M             : integer := 8; --W; -- input weight width
           W             : integer := 8; -- output data width      (Note, W+SR <= N+M+4)
           SR            : integer := 1; -- data shift right before output (deleted LSBs)
           in_row        : integer := 114;
           in_col        : integer := 114
           );
  port    (
           clk     : in std_logic;
           rst     : in std_logic;
           d_in    : in vec(0 to CL_inputs -1)(N-1 downto 0); --invec;                                      --std_logic_vector (N-1 downto 0);
           en_in   : in std_logic;
           sof_in  : in std_logic; -- start of frame

           w_unit_n: in std_logic_vector( 7 downto 0);         -- address weight generators -> CL outputs
           w_in    : in vec(0 to CL_inputs -1)(M-1 downto 0);  -- value
           w_num   : in std_logic_vector(  4 downto 0);        -- number of weight
           w_en    : in std_logic;

           d_out   : out vec(0 to CL_outs -1)(W-1 downto 0); --std_logic_vector (W-1 downto 0); --vec;
           en_out  : out std_logic;
           sof_out : out std_logic);
end component;

component PCA_pixel is
    generic (
        number_output_features_g : positive := 64;
        N                        : integer  :=  8; -- input/output data width
        M                        : integer  :=  8; -- input weight width
        SR                       : integer  :=  1  -- data shift right before output (deleted LSBs)
        );
    port (
        reset          : in  std_logic;
        clock          : in  std_logic;
        sof            : in  std_logic;
        eof            : in  std_logic;
        data_in        : in  std_logic_vector(N-1 downto 0);
        data_in_valid  : in  std_logic;
        weight_in      : in  vec(0 to number_output_features_g - 1)(M-1 downto 0);
        data_out       : out vec(0 to number_output_features_g - 1)(N-1 downto 0);
        data_out_valid : out std_logic
    ) ;
end component;

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

constant  Relu    : string := "yes";  --"no"/"yes"  -- nonlinear Relu function
constant  BP      : string := "no";   --"no"/"yes"  -- Bypass
constant  TP      : string := "no";   --"no"/"yes"  -- Test pattern output
 
constant CL_w_width : integer := 8;

type     W_mem_type  is array ( 0 to CL_output*Kernel_size*Kernel_size) of std_logic_vector(CL_inputs*M-1 downto 0);
signal   W_mem       : W_mem_type ;

signal   w_inputN_i   : integer range 0 to 2**16-1;
signal   weight_lin  : std_logic_vector         (CL_inputs * M - 1 downto 0);


--signal  w_num       : std_logic_vector(  3 downto 0);
--signal  w_en        : std_logic;
signal  w_count     : std_logic_vector(  3 downto 0);
signal  w_count_en  : std_logic;
signal  w_count_en2 : std_logic;

-- conv layer
constant CL_W       : integer := N+CL_w_width+4; -- output data width
constant CL_SR      : integer := 0; -- data shift right before output
signal  cl_en_out, cl_sof_out: std_logic;
--signal  d01_out1       : std_logic_vector (CL_W-1 downto 0);
signal  d01_out1    :vec(0 to 0)(N-1 downto 0);

signal weight_pca_in  : vec(0 to number_output_features_g - 1)(M-1 downto 0);
signal data_pca_out   : vec(0 to number_output_features_g - 1)(N-1 downto 0);
signal data_pca_out1  : vec(0 to number_output_features_g - 1)(N-1 downto 0);

signal pca_en_out  : std_logic;
signal pca_sof_out : std_logic;

constant PCA_data_w   : integer := 8; -- PCA data width
signal  d01_out       : std_logic_vector (CL_W-1 downto 0);

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

-- PCA disable signals
signal PCA_dis1      : std_logic_vector(7 downto 0);
signal PCA_dis2      : std_logic_vector(7 downto 0);
signal PCA_dis3      : std_logic_vector(7 downto 0);
signal PCA_dis4      : std_logic_vector(7 downto 0);
signal PCA_dis5      : std_logic_vector(7 downto 0);
signal PCA_dis6      : std_logic_vector(7 downto 0);
signal PCA_dis7      : std_logic_vector(7 downto 0);
signal PCA_dis8      : std_logic_vector(7 downto 0);

signal count , pca_count        : integer;

begin

-- Weight memory organisation (Kernel_size=3)
--                                            CL_input
--                      1     2     3     4   ...   X
-- CL_output 1, w1,     w     w     w     w         w
--              w2,     w     w     w     w         w
--              w3,     w     w     w     w         w
--               .      .     .     .     .         .
--              w9,     w     w     w     w         w
-- CL_output 2, w1,     w     w     w     w         w
--              w2,     w     w     w     w         w
--              w3,     w     w     w     w         w
--               .      .     .     .     .         .
--              w9,     w     w     w     w         w
--               .
--               .
-- CL_output Y, w1,     w     w     w     w         w
--              w2,     w     w     w     w         w
--              w3,     w     w     w     w         w
--              . ,     .     .     .     .         .
--              w9,     w     w     w     w         w

------------------------------------------------------------------
--                  line 1 values      load line 1     line 2 values  load line 2   ...
--                                      of pixel 1                     of pixel 1

-- w_en      ____  1   1   1   ... 1  ______________1   1   1   ... 1  ___________  ...
-- w_inputN  ----  V1  V2  V3  ... Vn ______________V1  V2  V3  ... Vn ___________  ...
-- w_lin_rdy _____________________________   1     ______________________   1       ...
-- w_unit_n    -----------------------------   A1    ----------------------   A2
-- w_num     ----  V1  V2  V3  ... Vn ______________V1  V2  V3  ... Vn ___________  ...
-- w_in      ----  V1  V2  V3  ... Vn ______________V1  V2  V3  ... Vn ___________  ...

w_inputN_i <= conv_integer(unsigned('0' & w_inputN));

w_en_p : process (clk)
begin
   if rising_edge(clk) then
      if w_en = '1' then
         if w_lin_rdy = '1' then
            weight_lin <=  (others => '0');
         else
            weight_lin(w_inputN_i * M + M - 1 downto w_inputN_i * M ) <=  w_in;
         end if;
      end if;
   end if;
end process w_en_p;


addr_wr <= conv_integer(unsigned('0' & w_pixel_N))*w_pixel_L_max + conv_integer(unsigned('0' & w_pixel_L));
w_lin_p : process (clk)
begin
   if rising_edge(clk) then
         if w_lin_rdy = '1' then
            weight_mat(addr_wr) <=  weight_lin;
         end if;
   end if;
end process w_lin_p;


CL: ConvLayer_paralel_w
  generic map(
           Relu          => Relu        ,
           BP            => BP          ,
           TP            => TP          ,
           mult_sum      => mult_sum_CL ,
           Kernel_size   => Kernel_size ,
           zero_padding  => zero_padding,
           CL_inputs     => CL_inputs   ,
           CL_outs       => 1           ,
           N             => N           ,
           M             => M           ,
           W             => N           ,
           SR            => SR_CL       ,
           in_row        => in_row      ,
           in_col        => in_col      
           )
  port map (
           clk           => clk      ,
           rst           => rst      ,
           d_in          => d_in     ,
           en_in         => en_in    ,
           sof_in        => sof_in   ,
           w_unit_n      => w_unit_n ,
           w_in          => w_in     ,
           w_num         => w_num    ,
           w_en          => w_en     ,
           d_out         => d01_out1  ,
           en_out        => cl_en_out ,
           sof_out       => cl_sof_out  
           );

d01_out(           7 downto 0) <= d01_out1(0)(N-1 downto N - 1 -7); 
d01_out(d01_out'left downto 8) <= (others => '0');

--  p_pca_weight1 : process (clk,rst)
--  begin
--    if rst = '1' then
--       pca_count <= 0;
--    elsif rising_edge(clk) then
--       if pca_w_en = '1' then
--          pca_count <= pca_count + 1;
--       end if;
--    end if;
--  end process p_pca_weight1;

  p_pca_weight : process (clk)
  begin
    if rising_edge(clk) then
       if pca_w_en = '1' then
          weight_pca_in(conv_integer('0' & pca_w_num)) <= pca_w_in;
       end if;
    end if;
  end process p_pca_weight;

g_PCA_en: if PCA_en = TRUE generate

PCA64_inst: PCA_pixel 
  generic map (
        number_output_features_g => number_output_features_g,
        N                        => N,
        M                        => M,
        SR                       => SR_PCA 
        )
    port map(
        reset          => clk,
        clock          => rst,
        sof            => cl_en_out, -- fix it, add start of frame
        eof            => '1',
        data_in        => d01_out1(0)(N-1 downto N - 1 -7), -- d01_out1(0)(d01_out1'left downto d01_out1'left -7),
        data_in_valid  => cl_en_out,
        weight_in      => weight_pca_in,
        data_out       => data_pca_out,
        data_out_valid => pca_en_out
    ) ;

end generate g_PCA_en;

g_PCA_bp: if PCA_en = FALSE generate
   pca_en_out                          <=  cl_en_out;

--p_PCA_dis: process (clk)
-- begin
--    if  rising_edge(clk) then
--
--
--    end if;
-- end process p_PCA_dis;

end generate g_PCA_bp;


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

g_Huff_enc_en: if Huff_enc_en = TRUE generate
   gen_Huf: for i in 0 to number_output_features_g-1 generate
      Huffman_inst: Huffman
      generic map(
               N           => 8          ,  -- input data width
               M           => Huff_wid   ,  -- max code width
               W           => Wh         
               )
      port map   (
               clk      => clk  ,
               rst      => rst  , 
      
               init_en        => h_en       ,
               alpha_data     => alpha_data ,   
               alpha_code     => alpha_code ,    
               alpha_width    => alpha_width,
      
               d_in           => data_pca_out(i), 
               en_in          => pca_en_out     ,        --
               sof_in         => pca_sof_out    ,        --                         -- start of frame
               eof_in         => '0'            ,        --                         -- end of frame
       
               d_out          => d_out(i)       ,
               en_out         => en_out(i)      ,
               eof_out        => open
               );                        -- huffman codde output
   end generate gen_Huf;
end generate g_Huff_enc_en;

 --g_Huff_enc_dis: if Huff_enc_en = FALSE generate
 -- d_out(7 downto 0) <= d01_out1(0)(N-1 downto N - 1 -7); --  d01_out1(0)(d01_out1'left downto d01_out1'left -7);
 --end generate g_Huff_enc_dis;  


end a;