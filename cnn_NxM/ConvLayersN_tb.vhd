library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;

entity ConvLayersN_tb is
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
end entity ConvLayersN_tb;

architecture ConvLayersN_tb of ConvLayersN_tb is

component ConvLayersN is
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

           w01      : in std_logic_vector(M-1 downto 0); -- weight matrix
           w02      : in std_logic_vector(M-1 downto 0); -- weight matrix
           w03      : in std_logic_vector(M-1 downto 0); -- weight matrix
           w04      : in std_logic_vector(M-1 downto 0); -- weight matrix
           w05      : in std_logic_vector(M-1 downto 0); -- weight matrix
           w06      : in std_logic_vector(M-1 downto 0); -- weight matrix
           w07      : in std_logic_vector(M-1 downto 0); -- weight matrix
           w08      : in std_logic_vector(M-1 downto 0); -- weight matrix
           w09      : in std_logic_vector(M-1 downto 0); -- weight matrix

           w11      : in std_logic_vector(M-1 downto 0); -- weight matrix
           w12      : in std_logic_vector(M-1 downto 0); -- weight matrix
           w13      : in std_logic_vector(M-1 downto 0); -- weight matrix
           w14      : in std_logic_vector(M-1 downto 0); -- weight matrix
           w15      : in std_logic_vector(M-1 downto 0); -- weight matrix
           w16      : in std_logic_vector(M-1 downto 0); -- weight matrix
           w17      : in std_logic_vector(M-1 downto 0); -- weight matrix
           w18      : in std_logic_vector(M-1 downto 0); -- weight matrix
           w19      : in std_logic_vector(M-1 downto 0); -- weight matrix


           w21      : in std_logic_vector(M-1 downto 0); -- weight matrix
           w22      : in std_logic_vector(M-1 downto 0); -- weight matrix
           w23      : in std_logic_vector(M-1 downto 0); -- weight matrix
           w24      : in std_logic_vector(M-1 downto 0); -- weight matrix
           w25      : in std_logic_vector(M-1 downto 0); -- weight matrix
           w26      : in std_logic_vector(M-1 downto 0); -- weight matrix
           w27      : in std_logic_vector(M-1 downto 0); -- weight matrix
           w28      : in std_logic_vector(M-1 downto 0); -- weight matrix
           w29      : in std_logic_vector(M-1 downto 0); -- weight matrix

           w31      : in std_logic_vector(M-1 downto 0); -- weight matrix
           w32      : in std_logic_vector(M-1 downto 0); -- weight matrix
           w33      : in std_logic_vector(M-1 downto 0); -- weight matrix
           w34      : in std_logic_vector(M-1 downto 0); -- weight matrix
           w35      : in std_logic_vector(M-1 downto 0); -- weight matrix
           w36      : in std_logic_vector(M-1 downto 0); -- weight matrix
           w37      : in std_logic_vector(M-1 downto 0); -- weight matrix
           w38      : in std_logic_vector(M-1 downto 0); -- weight matrix
           w39      : in std_logic_vector(M-1 downto 0); -- weight matrix

           w41      : in std_logic_vector(M-1 downto 0); -- weight matrix
           w42      : in std_logic_vector(M-1 downto 0); -- weight matrix
           w43      : in std_logic_vector(M-1 downto 0); -- weight matrix
           w44      : in std_logic_vector(M-1 downto 0); -- weight matrix
           w45      : in std_logic_vector(M-1 downto 0); -- weight matrix
           w46      : in std_logic_vector(M-1 downto 0); -- weight matrix
           w47      : in std_logic_vector(M-1 downto 0); -- weight matrix
           w48      : in std_logic_vector(M-1 downto 0); -- weight matrix
           w49      : in std_logic_vector(M-1 downto 0); -- weight matrix

           w51      : in std_logic_vector(M-1 downto 0); -- weight matrix
           w52      : in std_logic_vector(M-1 downto 0); -- weight matrix
           w53      : in std_logic_vector(M-1 downto 0); -- weight matrix
           w54      : in std_logic_vector(M-1 downto 0); -- weight matrix
           w55      : in std_logic_vector(M-1 downto 0); -- weight matrix
           w56      : in std_logic_vector(M-1 downto 0); -- weight matrix
           w57      : in std_logic_vector(M-1 downto 0); -- weight matrix
           w58      : in std_logic_vector(M-1 downto 0); -- weight matrix
           w59      : in std_logic_vector(M-1 downto 0); -- weight matrix

           w61      : in std_logic_vector(M-1 downto 0); -- weight matrix
           w62      : in std_logic_vector(M-1 downto 0); -- weight matrix
           w63      : in std_logic_vector(M-1 downto 0); -- weight matrix
           w64      : in std_logic_vector(M-1 downto 0); -- weight matrix
           w65      : in std_logic_vector(M-1 downto 0); -- weight matrix
           w66      : in std_logic_vector(M-1 downto 0); -- weight matrix
           w67      : in std_logic_vector(M-1 downto 0); -- weight matrix
           w68      : in std_logic_vector(M-1 downto 0); -- weight matrix
           w69      : in std_logic_vector(M-1 downto 0); -- weight matrix

           w71      : in std_logic_vector(M-1 downto 0); -- weight matrix
           w72      : in std_logic_vector(M-1 downto 0); -- weight matrix
           w73      : in std_logic_vector(M-1 downto 0); -- weight matrix
           w74      : in std_logic_vector(M-1 downto 0); -- weight matrix
           w75      : in std_logic_vector(M-1 downto 0); -- weight matrix
           w76      : in std_logic_vector(M-1 downto 0); -- weight matrix
           w77      : in std_logic_vector(M-1 downto 0); -- weight matrix
           w78      : in std_logic_vector(M-1 downto 0); -- weight matrix
           w79      : in std_logic_vector(M-1 downto 0); -- weight matrix

           w81      : in std_logic_vector(M-1 downto 0); -- weight matrix
           w82      : in std_logic_vector(M-1 downto 0); -- weight matrix
           w83      : in std_logic_vector(M-1 downto 0); -- weight matrix
           w84      : in std_logic_vector(M-1 downto 0); -- weight matrix
           w85      : in std_logic_vector(M-1 downto 0); -- weight matrix
           w86      : in std_logic_vector(M-1 downto 0); -- weight matrix
           w87      : in std_logic_vector(M-1 downto 0); -- weight matrix
           w88      : in std_logic_vector(M-1 downto 0); -- weight matrix
           w89      : in std_logic_vector(M-1 downto 0); -- weight matrix

           w91      : in std_logic_vector(M-1 downto 0); -- weight matrix
           w92      : in std_logic_vector(M-1 downto 0); -- weight matrix
           w93      : in std_logic_vector(M-1 downto 0); -- weight matrix
           w94      : in std_logic_vector(M-1 downto 0); -- weight matrix
           w95      : in std_logic_vector(M-1 downto 0); -- weight matrix
           w96      : in std_logic_vector(M-1 downto 0); -- weight matrix
           w97      : in std_logic_vector(M-1 downto 0); -- weight matrix
           w98      : in std_logic_vector(M-1 downto 0); -- weight matrix
           w99      : in std_logic_vector(M-1 downto 0); -- weight matrix
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
signal           w01      :  std_logic_vector(M-1 downto 0); -- weight matrix
signal           w02      :  std_logic_vector(M-1 downto 0); -- weight matrix
signal           w03      :  std_logic_vector(M-1 downto 0); -- weight matrix
signal           w04      :  std_logic_vector(M-1 downto 0); -- weight matrix
signal           w05      :  std_logic_vector(M-1 downto 0); -- weight matrix
signal           w06      :  std_logic_vector(M-1 downto 0); -- weight matrix
signal           w07      :  std_logic_vector(M-1 downto 0); -- weight matrix
signal           w08      :  std_logic_vector(M-1 downto 0); -- weight matrix
signal           w09      :  std_logic_vector(M-1 downto 0); -- weight matrix
signal           w11      :  std_logic_vector(M-1 downto 0); -- weight matrix
signal           w12      :  std_logic_vector(M-1 downto 0); -- weight matrix
signal           w13      :  std_logic_vector(M-1 downto 0); -- weight matrix
signal           w14      :  std_logic_vector(M-1 downto 0); -- weight matrix
signal           w15      :  std_logic_vector(M-1 downto 0); -- weight matrix
signal           w16      :  std_logic_vector(M-1 downto 0); -- weight matrix
signal           w17      :  std_logic_vector(M-1 downto 0); -- weight matrix
signal           w18      :  std_logic_vector(M-1 downto 0); -- weight matrix
signal           w19      :  std_logic_vector(M-1 downto 0); -- weight matrix
signal           w21      :  std_logic_vector(M-1 downto 0); -- weight matrix
signal           w22      :  std_logic_vector(M-1 downto 0); -- weight matrix
signal           w23      :  std_logic_vector(M-1 downto 0); -- weight matrix
signal           w24      :  std_logic_vector(M-1 downto 0); -- weight matrix
signal           w25      :  std_logic_vector(M-1 downto 0); -- weight matrix
signal           w26      :  std_logic_vector(M-1 downto 0); -- weight matrix
signal           w27      :  std_logic_vector(M-1 downto 0); -- weight matrix
signal           w28      :  std_logic_vector(M-1 downto 0); -- weight matrix
signal           w29      :  std_logic_vector(M-1 downto 0); -- weight matrix
signal           w31      :  std_logic_vector(M-1 downto 0); -- weight matrix
signal           w32      :  std_logic_vector(M-1 downto 0); -- weight matrix
signal           w33      :  std_logic_vector(M-1 downto 0); -- weight matrix
signal           w34      :  std_logic_vector(M-1 downto 0); -- weight matrix
signal           w35      :  std_logic_vector(M-1 downto 0); -- weight matrix
signal           w36      :  std_logic_vector(M-1 downto 0); -- weight matrix
signal           w37      :  std_logic_vector(M-1 downto 0); -- weight matrix
signal           w38      :  std_logic_vector(M-1 downto 0); -- weight matrix
signal           w39      :  std_logic_vector(M-1 downto 0); -- weight matrix
signal           w41      :  std_logic_vector(M-1 downto 0); -- weight matrix
signal           w42      :  std_logic_vector(M-1 downto 0); -- weight matrix
signal           w43      :  std_logic_vector(M-1 downto 0); -- weight matrix
signal           w44      :  std_logic_vector(M-1 downto 0); -- weight matrix
signal           w45      :  std_logic_vector(M-1 downto 0); -- weight matrix
signal           w46      :  std_logic_vector(M-1 downto 0); -- weight matrix
signal           w47      :  std_logic_vector(M-1 downto 0); -- weight matrix
signal           w48      :  std_logic_vector(M-1 downto 0); -- weight matrix
signal           w49      :  std_logic_vector(M-1 downto 0); -- weight matrix
signal           w51      :  std_logic_vector(M-1 downto 0); -- weight matrix
signal           w52      :  std_logic_vector(M-1 downto 0); -- weight matrix
signal           w53      :  std_logic_vector(M-1 downto 0); -- weight matrix
signal           w54      :  std_logic_vector(M-1 downto 0); -- weight matrix
signal           w55      :  std_logic_vector(M-1 downto 0); -- weight matrix
signal           w56      :  std_logic_vector(M-1 downto 0); -- weight matrix
signal           w57      :  std_logic_vector(M-1 downto 0); -- weight matrix
signal           w58      :  std_logic_vector(M-1 downto 0); -- weight matrix
signal           w59      :  std_logic_vector(M-1 downto 0); -- weight matrix
signal           w61      :  std_logic_vector(M-1 downto 0); -- weight matrix
signal           w62      :  std_logic_vector(M-1 downto 0); -- weight matrix
signal           w63      :  std_logic_vector(M-1 downto 0); -- weight matrix
signal           w64      :  std_logic_vector(M-1 downto 0); -- weight matrix
signal           w65      :  std_logic_vector(M-1 downto 0); -- weight matrix
signal           w66      :  std_logic_vector(M-1 downto 0); -- weight matrix
signal           w67      :  std_logic_vector(M-1 downto 0); -- weight matrix
signal           w68      :  std_logic_vector(M-1 downto 0); -- weight matrix
signal           w69      :  std_logic_vector(M-1 downto 0); -- weight matrix
signal           w71      :  std_logic_vector(M-1 downto 0); -- weight matrix
signal           w72      :  std_logic_vector(M-1 downto 0); -- weight matrix
signal           w73      :  std_logic_vector(M-1 downto 0); -- weight matrix
signal           w74      :  std_logic_vector(M-1 downto 0); -- weight matrix
signal           w75      :  std_logic_vector(M-1 downto 0); -- weight matrix
signal           w76      :  std_logic_vector(M-1 downto 0); -- weight matrix
signal           w77      :  std_logic_vector(M-1 downto 0); -- weight matrix
signal           w78      :  std_logic_vector(M-1 downto 0); -- weight matrix
signal           w79      :  std_logic_vector(M-1 downto 0); -- weight matrix
signal           w81      :  std_logic_vector(M-1 downto 0); -- weight matrix
signal           w82      :  std_logic_vector(M-1 downto 0); -- weight matrix
signal           w83      :  std_logic_vector(M-1 downto 0); -- weight matrix
signal           w84      :  std_logic_vector(M-1 downto 0); -- weight matrix
signal           w85      :  std_logic_vector(M-1 downto 0); -- weight matrix
signal           w86      :  std_logic_vector(M-1 downto 0); -- weight matrix
signal           w87      :  std_logic_vector(M-1 downto 0); -- weight matrix
signal           w88      :  std_logic_vector(M-1 downto 0); -- weight matrix
signal           w89      :  std_logic_vector(M-1 downto 0); -- weight matrix
signal           w91      :  std_logic_vector(M-1 downto 0); -- weight matrix
signal           w92      :  std_logic_vector(M-1 downto 0); -- weight matrix
signal           w93      :  std_logic_vector(M-1 downto 0); -- weight matrix
signal           w94      :  std_logic_vector(M-1 downto 0); -- weight matrix
signal           w95      :  std_logic_vector(M-1 downto 0); -- weight matrix
signal           w96      :  std_logic_vector(M-1 downto 0); -- weight matrix
signal           w97      :  std_logic_vector(M-1 downto 0); -- weight matrix
signal           w98      :  std_logic_vector(M-1 downto 0); -- weight matrix
signal           w99      :  std_logic_vector(M-1 downto 0); -- weight matrix
signal d_out   : std_logic_vector (W-1 downto 0);
signal en_out  : std_logic;
signal sof_out : std_logic; -- start of frame

begin




DUT: ConvLayersN generic map (
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
      w01      => w01       ,
      w02      => w02       ,
      w03      => w03       ,
      w04      => w04       ,
      w05      => w05       ,
      w06      => w06       ,
      w07      => w07       ,
      w08      => w08       ,
      w09      => w09       ,
      w11      => w11       ,
      w12      => w12       ,
      w13      => w13       ,
      w14      => w14       ,
      w15      => w15       ,
      w16      => w16       ,
      w17      => w17       ,
      w18      => w18       ,
      w19      => w19       ,
      w21      => w21       ,
      w22      => w22       ,
      w23      => w23       ,
      w24      => w24       ,
      w25      => w25       ,
      w26      => w26       ,
      w27      => w27       ,
      w28      => w28       ,
      w29      => w29       ,
      w31      => w31       ,
      w32      => w32       ,
      w33      => w33       ,
      w34      => w34       ,
      w35      => w35       ,
      w36      => w36       ,
      w37      => w37       ,
      w38      => w38       ,
      w39      => w39       ,
      w41      => w41       ,
      w42      => w42       ,
      w43      => w43       ,
      w44      => w44       ,
      w45      => w45       ,
      w46      => w46       ,
      w47      => w47       ,
      w48      => w48       ,
      w49      => w49       ,
      w51      => w51       ,
      w52      => w52       ,
      w53      => w53       ,
      w54      => w54       ,
      w55      => w55       ,
      w56      => w56       ,
      w57      => w57       ,
      w58      => w58       ,
      w59      => w59       ,
      w61      => w61       ,
      w62      => w62       ,
      w63      => w63       ,
      w64      => w64       ,
      w65      => w65       ,
      w66      => w66       ,
      w67      => w67       ,
      w68      => w68       ,
      w69      => w69       ,
      w71      => w71       ,
      w72      => w72       ,
      w73      => w73       ,
      w74      => w74       ,
      w75      => w75       ,
      w76      => w76       ,
      w77      => w77       ,
      w78      => w78       ,
      w79      => w79       ,
      w81      => w81       ,
      w82      => w82       ,
      w83      => w83       ,
      w84      => w84       ,
      w85      => w85       ,
      w86      => w86       ,
      w87      => w87       ,
      w88      => w88       ,
      w89      => w89       ,
      w91      => w91       ,
      w92      => w92       ,
      w93      => w93       ,
      w94      => w94       ,
      w95      => w95       ,
      w96      => w96       ,
      w97      => w97       ,
      w98      => w98       ,
      w99      => w99       ,
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

w01  <= conv_std_logic_vector( 1, w01'length);
w02  <= conv_std_logic_vector( 1, w02'length);
w03  <= conv_std_logic_vector( 1, w03'length);
w04  <= conv_std_logic_vector( 1, w04'length);
w05  <= conv_std_logic_vector( 1, w05'length);
w06  <= conv_std_logic_vector( 1, w06'length);
w07  <= conv_std_logic_vector(-1, w07'length);
w08  <= conv_std_logic_vector(-1, w08'length);
w09  <= conv_std_logic_vector(-1, w09'length);
w11  <= conv_std_logic_vector( 1, w11'length);
w12  <= conv_std_logic_vector( 1, w12'length);
w13  <= conv_std_logic_vector( 1, w13'length);
w14  <= conv_std_logic_vector( 1, w14'length);
w15  <= conv_std_logic_vector( 1, w15'length);
w16  <= conv_std_logic_vector( 1, w16'length);
w17  <= conv_std_logic_vector(-1, w17'length);
w18  <= conv_std_logic_vector(-1, w18'length);
w19  <= conv_std_logic_vector(-1, w19'length);
w21  <= conv_std_logic_vector( 1, w21'length);
w22  <= conv_std_logic_vector( 1, w22'length);
w23  <= conv_std_logic_vector( 1, w23'length);
w24  <= conv_std_logic_vector( 1, w24'length);
w25  <= conv_std_logic_vector( 1, w25'length);
w26  <= conv_std_logic_vector( 1, w26'length);
w27  <= conv_std_logic_vector(-1, w27'length);
w28  <= conv_std_logic_vector(-1, w28'length);
w29  <= conv_std_logic_vector(-1, w29'length);
w31  <= conv_std_logic_vector( 1, w31'length);
w32  <= conv_std_logic_vector( 1, w32'length);
w33  <= conv_std_logic_vector( 1, w33'length);
w34  <= conv_std_logic_vector( 1, w34'length);
w35  <= conv_std_logic_vector( 1, w35'length);
w36  <= conv_std_logic_vector( 1, w36'length);
w37  <= conv_std_logic_vector(-1, w37'length);
w38  <= conv_std_logic_vector(-1, w38'length);
w39  <= conv_std_logic_vector(-1, w39'length);
w41  <= conv_std_logic_vector( 1, w41'length);
w42  <= conv_std_logic_vector( 1, w42'length);
w43  <= conv_std_logic_vector( 1, w43'length);
w44  <= conv_std_logic_vector( 1, w44'length);
w45  <= conv_std_logic_vector( 1, w45'length);
w46  <= conv_std_logic_vector( 1, w46'length);
w47  <= conv_std_logic_vector(-1, w47'length);
w48  <= conv_std_logic_vector(-1, w48'length);
w49  <= conv_std_logic_vector(-1, w49'length);
w51  <= conv_std_logic_vector( 1, w51'length);
w52  <= conv_std_logic_vector( 1, w52'length);
w53  <= conv_std_logic_vector( 1, w53'length);
w54  <= conv_std_logic_vector( 1, w54'length);
w55  <= conv_std_logic_vector( 1, w55'length);
w56  <= conv_std_logic_vector( 1, w56'length);
w57  <= conv_std_logic_vector(-1, w57'length);
w58  <= conv_std_logic_vector(-1, w58'length);
w59  <= conv_std_logic_vector(-1, w59'length);
w61  <= conv_std_logic_vector( 1, w61'length);
w62  <= conv_std_logic_vector( 1, w62'length);
w63  <= conv_std_logic_vector( 1, w63'length);
w64  <= conv_std_logic_vector( 1, w64'length);
w65  <= conv_std_logic_vector( 1, w65'length);
w66  <= conv_std_logic_vector( 1, w66'length);
w67  <= conv_std_logic_vector(-1, w67'length);
w68  <= conv_std_logic_vector(-1, w68'length);
w69  <= conv_std_logic_vector(-1, w69'length);
w71  <= conv_std_logic_vector( 1, w71'length);
w72  <= conv_std_logic_vector( 1, w72'length);
w73  <= conv_std_logic_vector( 1, w73'length);
w74  <= conv_std_logic_vector( 1, w74'length);
w75  <= conv_std_logic_vector( 1, w75'length);
w76  <= conv_std_logic_vector( 1, w76'length);
w77  <= conv_std_logic_vector(-1, w77'length);
w78  <= conv_std_logic_vector(-1, w78'length);
w79  <= conv_std_logic_vector(-1, w79'length);
w81  <= conv_std_logic_vector( 1, w81'length);
w82  <= conv_std_logic_vector( 1, w82'length);
w83  <= conv_std_logic_vector( 1, w83'length);
w84  <= conv_std_logic_vector( 1, w84'length);
w85  <= conv_std_logic_vector( 1, w85'length);
w86  <= conv_std_logic_vector( 1, w86'length);
w87  <= conv_std_logic_vector(-1, w87'length);
w88  <= conv_std_logic_vector(-1, w88'length);
w89  <= conv_std_logic_vector(-1, w89'length);
w91  <= conv_std_logic_vector( 1, w91'length);
w92  <= conv_std_logic_vector( 1, w92'length);
w93  <= conv_std_logic_vector( 1, w93'length);
w94  <= conv_std_logic_vector( 1, w94'length);
w95  <= conv_std_logic_vector( 1, w95'length);
w96  <= conv_std_logic_vector( 1, w96'length);
w97  <= conv_std_logic_vector(-1, w97'length);
w98  <= conv_std_logic_vector(-1, w98'length);
w99  <= conv_std_logic_vector(-1, w99'length);



process
begin
  en_in <= '0';
  sof_in <= '0';
  d_in <= (others => '0');
  wait until rst = '0';
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



end ConvLayersN_tb;