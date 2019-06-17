library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;

entity ConvLayer_calc is
  generic (
           Relu          : string := "yes"; --"no"/"yes"  -- nonlinear Relu function
           BP            : string := "no";  --"no"/"yes"  -- Bypass
           TP            : string := "no";  --"no"/"yes"  -- Test pattern output
           mult_sum      : string := "sum"; --"mult"/"sum"
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

component generic_mult is
generic (N: integer; 
         M: integer
         );
port ( 
       clk    :  in  std_logic;
       rst    :  in  std_logic; 
       a      :  in  std_logic_vector(N-1 downto 0);
       b      :  in  std_logic_vector(M-1 downto 0);
       prod   :  out std_logic_vector(M+N-1 downto 0) );
end component;

signal     en_in1, en_end2, en_end3, en_sum : std_logic_vector(1 downto 0) ;
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

gen_no_BP: if BP = "no" and TP = "no" generate 

--  insamp2 : process (clk,rst)
--  begin
--    if rst = '1' then
--       en_in1  <= (others => '0');
--       en_end2 <= (others => '0');
--       en_end3 <= (others => '0');
--    elsif rising_edge(clk) then
--       --if en_in = '1' then
--          en_in1(EN_BIT)  <= en_in;
--          en_in1(SOF_BIT) <= sof_in;
--
--
--          en_end2 <= en_in1;
--          --en_end3 <= en_end2;
--          en_end3 <= en_end2;
--       --end if;
--    end if;
--  end process insamp2;

gen_Mults: if mult_sum = "mult" generate 
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

  p_mult : process (clk,rst)
  begin
    if rst = '1' then
       en_in1  <= (others => '0');
    elsif rising_edge(clk) then
       en_in1(EN_BIT)  <= en_in;
       en_in1(SOF_BIT) <= sof_in;
    end if;
  end process p_mult;

end generate;  -- mult

gen_Adds: if mult_sum = "sum" generate 

  --A01: Binary_adder generic map (N => N,M => M) port map (clk => clk,rst => rst,en_in => '0', Multiplier => data2conv1, Multiplicand => w1,d_out => c01, en_out => open);
  --A02: Binary_adder generic map (N => N,M => M) port map (clk => clk,rst => rst,en_in => '0', Multiplier => data2conv2, Multiplicand => w4,d_out => c02, en_out => open);
  --A03: Binary_adder generic map (N => N,M => M) port map (clk => clk,rst => rst,en_in => '0', Multiplier => data2conv3, Multiplicand => w7,d_out => c03, en_out => open);
  --A04: Binary_adder generic map (N => N,M => M) port map (clk => clk,rst => rst,en_in => '0', Multiplier => data2conv1, Multiplicand => w2,d_out => c04, en_out => open);
  --A05: Binary_adder generic map (N => N,M => M) port map (clk => clk,rst => rst,en_in => '0', Multiplier => data2conv2, Multiplicand => w5,d_out => c05, en_out => open);
  --A06: Binary_adder generic map (N => N,M => M) port map (clk => clk,rst => rst,en_in => '0', Multiplier => data2conv3, Multiplicand => w8,d_out => c06, en_out => open);
  --A07: Binary_adder generic map (N => N,M => M) port map (clk => clk,rst => rst,en_in => '0', Multiplier => data2conv1, Multiplicand => w3,d_out => c07, en_out => open);
  --A08: Binary_adder generic map (N => N,M => M) port map (clk => clk,rst => rst,en_in => '0', Multiplier => data2conv2, Multiplicand => w6,d_out => c08, en_out => open);
  --A09: Binary_adder generic map (N => N,M => M) port map (clk => clk,rst => rst,en_in => '0', Multiplier => data2conv3, Multiplicand => w9,d_out => c09, en_out => open);

  A1: generic_mult generic map (N => N,M => M) port map ( clk => clk,rst => rst, a => data2conv1,  b  => w1,  prod => c01);
  A2: generic_mult generic map (N => N,M => M) port map ( clk => clk,rst => rst, a => data2conv2,  b  => w2,  prod => c02);
  A3: generic_mult generic map (N => N,M => M) port map ( clk => clk,rst => rst, a => data2conv3,  b  => w3,  prod => c03);
  A4: generic_mult generic map (N => N,M => M) port map ( clk => clk,rst => rst, a => data2conv4,  b  => w4,  prod => c04);
  A5: generic_mult generic map (N => N,M => M) port map ( clk => clk,rst => rst, a => data2conv5,  b  => w5,  prod => c05);
  A6: generic_mult generic map (N => N,M => M) port map ( clk => clk,rst => rst, a => data2conv6,  b  => w6,  prod => c06);
  A7: generic_mult generic map (N => N,M => M) port map ( clk => clk,rst => rst, a => data2conv7,  b  => w7,  prod => c07);
  A8: generic_mult generic map (N => N,M => M) port map ( clk => clk,rst => rst, a => data2conv8,  b  => w8,  prod => c08);
  A9: generic_mult generic map (N => N,M => M) port map ( clk => clk,rst => rst, a => data2conv9,  b  => w9,  prod => c09);

  p_mult : process (clk,rst)
  begin
    if rst = '1' then
       en_sum  <= (others => '0');
       en_in1  <= (others => '0');
    elsif rising_edge(clk) then
       en_sum(EN_BIT)  <= en_in;
       en_sum(SOF_BIT) <= sof_in;
       en_in1          <= en_sum;
    end if;
  end process p_mult;

end generate; -- sum

  p_conv_oper : process (clk)
  begin
    if rising_edge(clk) then

      c10 <= (c01(c01'left) & c01(c01'left) & c01) + (c02(c02'left) & c02(c02'left) & c02) + (c03(c03'left) & c03(c03'left) & c03);
      c11 <= (c04(c04'left) & c04(c04'left) & c04) + (c05(c05'left) & c05(c05'left) & c05) + (c06(c06'left) & c06(c06'left) & c06);
      c12 <= (c07(c07'left) & c07(c07'left) & c07) + (c08(c08'left) & c08(c08'left) & c08) + (c09(c09'left) & c09(c09'left) & c09);

      c13 <= (c10(c10'left) & c10(c10'left) & c10) + (c11(c11'left) & c11(c11'left) & c11) + (c12(c12'left) & c12(c12'left) & c12);

    end if;
  end process p_conv_oper;

  insamp2 : process (clk,rst)
  begin
    if rst = '1' then
       en_end2 <= (others => '0');
       en_end3 <= (others => '0');
    elsif rising_edge(clk) then
       en_end2 <= en_in1;
       en_end3 <= en_end2;
    end if;
  end process insamp2;

  p_relu : process (clk)
  begin
    if rising_edge(clk) then
      if Relu = "yes" then
         relu_for: for i in 0 to c13'length-1  loop
           d_relu(i) <= c13(i) and not c13(c13'left);    -- if MSB=1 (negative) thwen all bits are 0
         end loop relu_for;
      else
         d_relu <= c13;
      end if;
    end if;
  end process p_relu;

--  p_relu : process (clk,rst)
--  begin
--     if rst = '1' then
--       d_relu <= (others => '0');
--    elsif rising_edge(clk) then
--       d_relu <= d_relu + 1;
--    end if;
--  end process p_relu;

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
       --if SR = 0 then
       --   d_ovf <= d_relu;
       --else
          --if d_relu(d_relu'left  downto d_relu'left - SR ) = 0  then
          if d_relu(d_relu'left  downto W + SR -2) = 0  then
             d_ovf <= d_relu;
          else
             d_ovf( d_relu'left  downto W + SR -2 ) <= (others => '0'); 
             d_ovf( W + SR - 3   downto         0 ) <= (others => '1'); 
          end if;
       --end if;
    end if;
  end process p_ovf;

--  p_ovf : process (clk,rst)
--  begin
--     if rst = '1' then
--       d_ovf <= (others => '0');
--    elsif rising_edge(clk) then
--       d_ovf <= d_ovf + 1;
--    end if;
--  end process p_ovf;

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
d_out   <= d_ovf (W + SR -1  downto SR); --(5 downto 1); --(W + SR -1  downto SR );

end generate; -- BP = "no" and TP = "no"

gen_TP_out: if BP = "no" and TP = "yes" generate 
   p_tg_gen : process (clk,rst)
  begin
    if rst = '1' then
       d_tp <= (others => '0');
    elsif rising_edge(clk) then
       if en_in = '1' then
          d_tp <= d_tp + 1;
       end if;
       en_out  <= en_in;
       sof_out <= sof_in;
    end if;
  end process p_tg_gen;
  d_out   <= d_tp;
  
end generate; -- TP = "yes"

gen_BP: if BP = "yes" generate 
 --process (data2conv1, en_in, sof_in)
 --begin
 --   --if d_out'left > data2conv1'left then
 --   ----if W > N then
 --   --   d_out(data2conv1'left downto 0)   <= data2conv1(data2conv1'left downto 0);
 --   --   d_out(d_out'left downto data2conv1'left + 1) <= (others => '0');
 --   --elsif d_out'left = data2conv1'left then
 --   --   d_out <= data2conv1;
 --   --else
 --   --   d_out <= data2conv1(d_out'left downto 0);
 --   --end if;
 --end process ;
    Out_w: if d_out'left > data2conv1'left generate
       d_out(data2conv1'left downto 0)   <= data2conv1(data2conv1'left downto 0);
       d_out(d_out'left downto data2conv1'left + 1) <= (others => '0');
    end generate Out_w;

    InOut_e: if d_out'left = data2conv1'left generate
       d_out <= data2conv1;
    end generate InOut_e;

    In_w: if d_out'left < data2conv1'left generate
       d_out <= data2conv1(d_out'left downto 0);
    end generate In_w;

    en_out  <= en_in;
    sof_out <= sof_in;
 --end process ;

end generate; --  BP = "yes"

end a;