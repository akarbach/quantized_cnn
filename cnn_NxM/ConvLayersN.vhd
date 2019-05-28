library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;

entity ConvLayersN is
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
end ConvLayersN;

architecture a of ConvLayersN is

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
           w1      : in std_logic_vector(M-1 downto 0); -- weight matrix
           w2      : in std_logic_vector(M-1 downto 0); -- weight matrix
           w3      : in std_logic_vector(M-1 downto 0); -- weight matrix
           w4      : in std_logic_vector(M-1 downto 0); -- weight matrix
           w5      : in std_logic_vector(M-1 downto 0); -- weight matrix
           w6      : in std_logic_vector(M-1 downto 0); -- weight matrix
           w7      : in std_logic_vector(M-1 downto 0); -- weight matrix
           w8      : in std_logic_vector(M-1 downto 0); -- weight matrix
           w9      : in std_logic_vector(M-1 downto 0); -- weight matrix
           d_out   : out std_logic_vector (W-1 downto 0);
           en_out  : out std_logic;
           sof_out : out std_logic);
end component;

signal     d0   : std_logic_vector (W-1 downto 0);
signal     d1   : std_logic_vector (W-1 downto 0);
signal     d2   : std_logic_vector (W-1 downto 0);
signal     d3   : std_logic_vector (W-1 downto 0);
signal     d4   : std_logic_vector (W-1 downto 0);
signal     d5   : std_logic_vector (W-1 downto 0);
signal     d6   : std_logic_vector (W-1 downto 0);
signal     d7   : std_logic_vector (W-1 downto 0);
signal     d8   : std_logic_vector (W-1 downto 0);
signal     d9   : std_logic_vector (W-1 downto 0);
signal     en0  : std_logic;
signal     en1  : std_logic;
signal     en2  : std_logic;
signal     en3  : std_logic;
signal     en4  : std_logic;
signal     en5  : std_logic;
signal     en6  : std_logic;
signal     en7  : std_logic;
signal     en8  : std_logic;
signal     en9  : std_logic;
signal     sof0 : std_logic;
signal     sof1 : std_logic;
signal     sof2 : std_logic;
signal     sof3 : std_logic;
signal     sof4 : std_logic;
signal     sof5 : std_logic;
signal     sof6 : std_logic;
signal     sof7 : std_logic;
signal     sof8 : std_logic;
signal     sof9 : std_logic;

signal     pixel_count   : natural range 0 to in_row*in_col -1;
signal     max_val       : std_logic_vector (W-1 downto 0);


begin

inst0: ConvLayer generic map (
      mult_sum => mult_sum,
      N        => N       , -- input data width
      M        => M       , -- input data width
      W        => W       ,-- output data width
      SR       => SR      ,-- output data shift right

      in_row   => in_row  ,
      in_col   => in_col
      )
port map (
      clk     => clk      ,
      rst     => rst      ,
      d_in    => d_in     ,
      en_in   => en_in    ,
      sof_in  => sof_in   ,

      w1      => w01       ,
      w2      => w02       ,
      w3      => w03       ,
      w4      => w04       ,
      w5      => w05       ,
      w6      => w06       ,
      w7      => w07       ,
      w8      => w08       ,
      w9      => w09       ,
      d_out   => d0    ,
      en_out  => en0   ,
      sof_out => sof0             
    );

inst1: ConvLayer generic map (
      mult_sum => mult_sum,
      N        => N       , -- input data width
      M        => M       , -- input data width
      W        => W       ,-- output data width
      SR       => SR      ,-- output data shift right

      in_row   => in_row  ,
      in_col   => in_col
      )
port map (
      clk     => clk      ,
      rst     => rst      ,
      d_in    => d0     ,
      en_in   => en0    ,
      sof_in  => sof0   ,

      w1      => w11       ,
      w2      => w12       ,
      w3      => w13       ,
      w4      => w14       ,
      w5      => w15       ,
      w6      => w16       ,
      w7      => w17       ,
      w8      => w18       ,
      w9      => w19       ,
      d_out   => d1    ,
      en_out  => en1   ,
      sof_out => sof1             
    );

inst2: ConvLayer generic map (
      mult_sum => mult_sum,
      N        => N       , -- input data width
      M        => M       , -- input data width
      W        => W       ,-- output data width
      SR       => SR      ,-- output data shift right

      in_row   => in_row  ,
      in_col   => in_col
      )
port map (
      clk     => clk      ,
      rst     => rst      ,
      d_in    => d1     ,
      en_in   => en1    ,
      sof_in  => sof1   ,

      w1      => w21       ,
      w2      => w22       ,
      w3      => w23       ,
      w4      => w24       ,
      w5      => w25       ,
      w6      => w26       ,
      w7      => w27       ,
      w8      => w28       ,
      w9      => w29       ,
      d_out   => d2    ,
      en_out  => en2   ,
      sof_out => sof2             
    );
inst3: ConvLayer generic map (
      mult_sum => mult_sum,
      N        => N       , -- input data width
      M        => M       , -- input data width
      W        => W       ,-- output data width
      SR       => SR      ,-- output data shift right

      in_row   => in_row  ,
      in_col   => in_col
      )
port map (
      clk     => clk      ,
      rst     => rst      ,
      d_in    => d2     ,
      en_in   => en2    ,
      sof_in  => sof2   ,

      w1      => w31       ,
      w2      => w32       ,
      w3      => w33       ,
      w4      => w34       ,
      w5      => w35       ,
      w6      => w36       ,
      w7      => w37       ,
      w8      => w38       ,
      w9      => w39       ,
      d_out   => d3    ,
      en_out  => en3   ,
      sof_out => sof3             
    );
inst4: ConvLayer generic map (
      mult_sum => mult_sum,
      N        => N       , -- input data width
      M        => M       , -- input data width
      W        => W       ,-- output data width
      SR       => SR      ,-- output data shift right

      in_row   => in_row  ,
      in_col   => in_col
      )
port map (
      clk     => clk      ,
      rst     => rst      ,
      d_in    => d3     ,
      en_in   => en3    ,
      sof_in  => sof3   ,

      w1      => w41       ,
      w2      => w42       ,
      w3      => w43       ,
      w4      => w44       ,
      w5      => w45       ,
      w6      => w46       ,
      w7      => w47       ,
      w8      => w48       ,
      w9      => w49       ,
      d_out   => d4    ,
      en_out  => en4   ,
      sof_out => sof4             
    );
inst5: ConvLayer generic map (
      mult_sum => mult_sum,
      N        => N       , -- input data width
      M        => M       , -- input data width
      W        => W       ,-- output data width
      SR       => SR      ,-- output data shift right

      in_row   => in_row  ,
      in_col   => in_col
      )
port map (
      clk     => clk      ,
      rst     => rst      ,
      d_in    => d4     ,
      en_in   => en4    ,
      sof_in  => sof4   ,

      w1      => w51       ,
      w2      => w52       ,
      w3      => w53       ,
      w4      => w54       ,
      w5      => w55       ,
      w6      => w56       ,
      w7      => w57       ,
      w8      => w58       ,
      w9      => w59       ,
      d_out   => d5    ,
      en_out  => en5   ,
      sof_out => sof5             
    );
inst6: ConvLayer generic map (
      mult_sum => mult_sum,
      N        => N       , -- input data width
      M        => M       , -- input data width
      W        => W       ,-- output data width
      SR       => SR      ,-- output data shift right

      in_row   => in_row  ,
      in_col   => in_col
      )
port map (
      clk     => clk      ,
      rst     => rst      ,
      d_in    => d5     ,
      en_in   => en5    ,
      sof_in  => sof5   ,

      w1      => w61       ,
      w2      => w62       ,
      w3      => w63       ,
      w4      => w64       ,
      w5      => w65       ,
      w6      => w66       ,
      w7      => w67       ,
      w8      => w68       ,
      w9      => w69       ,
      d_out   => d6    ,
      en_out  => en6   ,
      sof_out => sof6             
    );
inst7: ConvLayer generic map (
      mult_sum => mult_sum,
      N        => N       , -- input data width
      M        => M       , -- input data width
      W        => W       ,-- output data width
      SR       => SR      ,-- output data shift right

      in_row   => in_row  ,
      in_col   => in_col
      )
port map (
      clk     => clk      ,
      rst     => rst      ,
      d_in    => d6     ,
      en_in   => en6    ,
      sof_in  => sof6   ,

      w1      => w71       ,
      w2      => w72       ,
      w3      => w73       ,
      w4      => w74       ,
      w5      => w75       ,
      w6      => w76       ,
      w7      => w77       ,
      w8      => w78       ,
      w9      => w79       ,
      d_out   => d7    ,
      en_out  => en7   ,
      sof_out => sof7             
    );
inst8: ConvLayer generic map (
      mult_sum => mult_sum,
      N        => N       , -- input data width
      M        => M       , -- input data width
      W        => W       ,-- output data width
      SR       => SR      ,-- output data shift right

      in_row   => in_row  ,
      in_col   => in_col
      )
port map (
      clk     => clk      ,
      rst     => rst      ,
      d_in    => d7     ,
      en_in   => en7    ,
      sof_in  => sof7   ,

      w1      => w81       ,
      w2      => w82       ,
      w3      => w83       ,
      w4      => w84       ,
      w5      => w85       ,
      w6      => w86       ,
      w7      => w87       ,
      w8      => w88       ,
      w9      => w89       ,
      d_out   => d8    ,
      en_out  => en8   ,
      sof_out => sof8             
    );
inst9: ConvLayer generic map (
      mult_sum => mult_sum,
      N        => N       , -- input data width
      M        => M       , -- input data width
      W        => W       ,-- output data width
      SR       => SR      ,-- output data shift right

      in_row   => in_row  ,
      in_col   => in_col
      )
port map (
      clk     => clk      ,
      rst     => rst      ,
      d_in    => d8     ,
      en_in   => en8    ,
      sof_in  => sof8   ,

      w1      => w91       ,
      w2      => w92       ,
      w3      => w93       ,
      w4      => w94       ,
      w5      => w95       ,
      w6      => w96       ,
      w7      => w97       ,
      w8      => w98       ,
      w9      => w99       ,
      d_out   => d9    ,
      en_out  => en9   ,
      sof_out => sof9             
    );


  max_detect : process (clk,rst)
  begin
    if rst = '1' then
        pixel_count   <= 0;
        max_val       <= (others => '1');
        en_out        <= '0';
        sof_out       <= '0';
        d_out         <= (others => '1');
    elsif rising_edge(clk) then
       if en9 = '1' then
          --if sof9 = '1' then
          --  max_val       <= (others => '1');
          --else
             if pixel_count = in_col * in_row - 1 then
                max_val       <= (others => '1');
                pixel_count   <= 0;

                en_out  <= '1';
                sof_out <= '1';
                if max_val > d9 then
                  d_out   <= max_val;
                else
                  d_out   <= d9;
                end if;
             else
                pixel_count <= pixel_count + 1;
                if d9 > max_val then
                  max_val   <= d9;
                end if;
                en_out  <= '0';
                sof_out <= '0';
             end if;
          --end if;
       end if;
    end if;
  end process max_detect;


end a;