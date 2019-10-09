library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;

entity ConvLayer_calc is
  generic (
           Relu          : std_logic := '0'; --'0'/'1'  -- nonlinear Relu function
           N             : integer := 8; -- input data width
           M             : integer := 8; -- input weight width
           W             : integer := 8; -- output data width      (Note, W+SR <= N+M+4)
           SR            : integer := 2 -- data shift right before output
  	       );
  port    (
           clk         : in std_logic;
           rst         : in std_logic;
           data2conv1  : in std_logic_vector (N-1 downto 0);
           data2conv2  : in std_logic_vector (N-1 downto 0);
           data2conv3  : in std_logic_vector (N-1 downto 0);
           data2conv4  : in std_logic_vector (N-1 downto 0);
           data2conv5  : in std_logic_vector (N-1 downto 0);
           data2conv6  : in std_logic_vector (N-1 downto 0);
           data2conv7  : in std_logic_vector (N-1 downto 0);
           data2conv8  : in std_logic_vector (N-1 downto 0);
           data2conv9  : in std_logic_vector (N-1 downto 0);
  	       en_in       : in std_logic;
  	       sof_in      : in std_logic; -- start of frame
  	       --sol     : in std_logic; -- start of line
  	       --eof     : in std_logic; -- end of frame

          w1           : in std_logic_vector(M-1 downto 0); -- weight matrix
          w2           : in std_logic_vector(M-1 downto 0); -- weight matrix
          w3           : in std_logic_vector(M-1 downto 0); -- weight matrix
          w4           : in std_logic_vector(M-1 downto 0); -- weight matrix
          w5           : in std_logic_vector(M-1 downto 0); -- weight matrix
          w6           : in std_logic_vector(M-1 downto 0); -- weight matrix
          w7           : in std_logic_vector(M-1 downto 0); -- weight matrix
          w8           : in std_logic_vector(M-1 downto 0); -- weight matrix
          w9           : in std_logic_vector(M-1 downto 0); -- weight matrix

           d_out       : out std_logic_vector (W-1 downto 0);
           en_out      : out std_logic;
           sof_out     : out std_logic);
end ConvLayer_calc;

architecture a of ConvLayer_calc is

constant EN_BIT  : integer range 0 to 1 := 0;
constant SOF_BIT : integer range 0 to 1 := 1;

component Binary_adder8 is
  generic (
           N             : integer := 8;                  -- input #1 data width, positive
           M             : integer := 8
           );
  port    (
           clk           : in  std_logic;
           rst           : in  std_logic; 

           en_in         : in  std_logic;                         
           Multiplier    : in  std_logic_vector(N-1 downto 0);    -- positive
           Multiplicand  : in  std_logic_vector(8-1 downto 0);    -- signed

           d_out         : out std_logic_vector (N + M - 1 downto 0);
           en_out        : out std_logic);                        
end component;


signal     en_in1, en_end2, en_end3 : std_logic_vector(1 downto 0) ;
--signal en_in1v,  en_in2v,  en_in3v  : std_logic_vector (N-1 downto 0);
--signal en_mid1v, en_mid2v, en_mid3v : std_logic_vector (N-1 downto 0);
--signal en_end1v, en_end2v, en_end3v : std_logic_vector (N-1 downto 0);

--constant fifo_depth : integer := in_col * N / bpp - 3;
--constant fifo_depth : integer := in_col  - 3;
--type t_Memory is array (0 to fifo_depth) of std_logic_vector(N-1 downto 0);
--signal mem_line1_01, mem_line2_01 : t_Memory;



--type t_datacontrol is array (0 to fifo_depth) of std_logic_vector(1 downto 0);
--signal en_line1 : t_datacontrol;
--signal en_line2 : t_datacontrol;

----signal head : std_logic_vector 
--signal Head : natural range 0 to fifo_depth ;
--signal Tail : natural range 0 to fifo_depth ;




signal en2conv     : std_logic_vector(1 downto 0);
signal en_count    : std_logic_vector(1 downto 0);



signal c01         : std_logic_vector (N + M -1 downto 0);
signal c02         : std_logic_vector (N + M -1 downto 0);
signal c03         : std_logic_vector (N + M -1 downto 0);
signal c04         : std_logic_vector (N + M -1 downto 0);
signal c05         : std_logic_vector (N + M -1 downto 0);
signal c06         : std_logic_vector (N + M -1 downto 0);
signal c07         : std_logic_vector (N + M -1 downto 0);
signal c08         : std_logic_vector (N + M -1 downto 0);
signal c09         : std_logic_vector (N + M -1 downto 0);

signal c10         : std_logic_vector (N + M +1 downto 0);
signal c11         : std_logic_vector (N + M +1 downto 0);
signal c12         : std_logic_vector (N + M +1 downto 0);

signal c13         : std_logic_vector (N + M +3 downto 0);



signal d_relu      : std_logic_vector (N + M +3 downto 0);
signal d_ovf       : std_logic_vector (N + M +3 downto 0);

--signal en_conv1, en_conv2, en_conv3, en_conv4, en_conv5, en_conv6    : std_logic_vector(1 downto 0);
signal en_relu, en_ovf     : std_logic_vector(1 downto 0);
signal d_tp        : std_logic_vector (W-1 downto 0);

begin

  insamp2 : process (clk,rst)
  begin
    if rst = '1' then
       en_in1  <= (others => '0');
       en_end2 <= (others => '0');
       en_end3 <= (others => '0');
    elsif rising_edge(clk) then
       if en_in = '1' then
          en_in1(EN_BIT)  <= en_in;
          en_in1(SOF_BIT) <= sof_in;


          en_end2 <= en_in1;
          --en_end3 <= en_end2;
          en_end3 <= en_end2;
       end if;
    end if;
  end process insamp2;

-- convolution
  p_conv_oper : process (clk)
  begin
    if rising_edge(clk) then
      c01 <= w1 * data2conv1;
      c02 <= w2 * data2conv2;
      c03 <= w3 * data2conv3;
      c04 <= w4 * data2conv4;
      c05 <= w5 * data2conv5;
      c06 <= w6 * data2conv6;
      c07 <= w7 * data2conv7;
      c08 <= w8 * data2conv8;
      c09 <= w9 * data2conv9;
 
    end if;
  end process p_conv_oper;


  p_conv_oper : process (clk)
  begin
    if rising_edge(clk) then

      c10 <= (c01(c01'left) & c01(c01'left) & c01) + (c02(c02'left) & c02(c02'left) & c02) + (c03(c03'left) & c03(c03'left) & c03);
      c11 <= (c04(c04'left) & c04(c04'left) & c04) + (c05(c05'left) & c05(c05'left) & c05) + (c06(c06'left) & c06(c06'left) & c06);
      c12 <= (c07(c07'left) & c07(c07'left) & c07) + (c08(c08'left) & c08(c08'left) & c08) + (c09(c09'left) & c09(c09'left) & c09);

      c13 <= (c10(c10'left) & c10(c10'left) & c10) + (c11(c11'left) & c11(c11'left) & c11) + (c12(c12'left) & c12(c12'left) & c12);

    end if;
  end process p_conv_oper;


  p_relu : process (clk)
  begin
    if rising_edge(clk) then
      if Relu = '1' then
         relu_for: for i in 0 to c13'length-1  loop
           d_relu(i) <= c13(i) and not c13(c13'left);
         end loop relu_for;
      else
         d_relu <= c13;
      end if;
    end if;
  end process p_relu;

  p_relu_samp : process (clk,rst)
  begin
    if rst = '1' then
       en_relu <= (others => '0');
    elsif rising_edge(clk) then
       en_relu <= en_end3;
    end if;
  end process p_relu_samp;

 -- check overflow before shift and change value to maximum if overflow occurs
   p_ovf : process (clk)
  begin
    if rising_edge(clk) then
       if d_relu(d_relu'left downto W + SR ) = 0  then
          d_ovf <= d_relu;
       else
          d_ovf <= (others => '1');
       end if;
    end if;
  end process p_ovf;

 p_ovf_samp : process (clk,rst)
  begin
    if rst = '1' then
       en_ovf <= (others => '0');
    elsif rising_edge(clk) then
       en_ovf <= en_relu;
    end if;
  end process p_ovf_samp;

en_out  <= en_ovf(EN_BIT);
sof_out <= en_ovf(SOF_BIT);
d_out   <= d_ovf (W + SR - 1 downto SR);


end a;