library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;

entity ConvLayer_calc is
  generic (
           BP            : string := "no";  --"no"/"yes"  -- Bypass
           TP            : string := "no";  --"no"/"yes"  -- Test pattern output
           mult_sum      : string := "mult"; --"mult"/"sum"
           Kernel_size   : integer := 7; -- 3/5/7
           N             : integer := 8; -- input data width
           M             : integer := 8  -- input weight width
  	       );
  port    (
           clk         : in std_logic;
           rst         : in std_logic;
           data2conv   : in std_logic_vector (Kernel_size*Kernel_size*N-1 downto 0);
  	       en_in       : in std_logic;
  	       sof_in      : in std_logic; -- start of frame
           w           : in std_logic_vector(Kernel_size*Kernel_size*M-1 downto 0); -- weight matrix

           d_out       : out std_logic_vector (N + M +5 downto 0);
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

signal     en_in1, en_end2, en_end3, en_end4, en_sum : std_logic_vector(1 downto 0) ;


signal en2conv     : std_logic_vector(1 downto 0);
signal en_count    : std_logic_vector(1 downto 0);


signal prod         : std_logic_vector ((Kernel_size*Kernel_size)*(N + M) -1 downto 0);

signal d20         : std_logic_vector (N + M +1 downto 0);
signal d21         : std_logic_vector (N + M +1 downto 0);
signal d22         : std_logic_vector (N + M +1 downto 0);
signal d23         : std_logic_vector (N + M +1 downto 0);
signal d24         : std_logic_vector (N + M +3 downto 0);

-- kernel 7x7
signal f01        : std_logic_vector (N + M +1 downto 0);
signal f02        : std_logic_vector (N + M +1 downto 0);
signal f03        : std_logic_vector (N + M +1 downto 0);
signal f04        : std_logic_vector (N + M +1 downto 0);
signal f05        : std_logic_vector (N + M +1 downto 0);
signal f06        : std_logic_vector (N + M +1 downto 0);
signal f07        : std_logic_vector (N + M +1 downto 0);
signal f08        : std_logic_vector (N + M +1 downto 0);
signal f09        : std_logic_vector (N + M +1 downto 0);
signal f10        : std_logic_vector (N + M +1 downto 0);
signal f11        : std_logic_vector (N + M +1 downto 0);
signal f12        : std_logic_vector (N + M +1 downto 0);
signal f13        : std_logic_vector (N + M +1 downto 0);

signal f21        : std_logic_vector (N + M +3 downto 0);
signal f22        : std_logic_vector (N + M +3 downto 0);
signal f23        : std_logic_vector (N + M +3 downto 0);
signal f24        : std_logic_vector (N + M +3 downto 0);

signal f25        : std_logic_vector (N + M +5 downto 0);


signal d_ker       : std_logic_vector (N + M +5 downto 0);

signal d_relu      : std_logic_vector (N + M +5 downto 0);
--signal d_ovf       : std_logic_vector (N + M +5 downto 0);

--signal en_conv1, en_conv2, en_conv3, en_conv4, en_conv5, en_conv6    : std_logic_vector(1 downto 0);
signal en_relu, en_ovf     : std_logic_vector(1 downto 0);
signal d_tp        : std_logic_vector (N + M +5 downto 0);
------------- DEBUG START
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

-- kernel 5
signal d01         : std_logic_vector (N + M -1 downto 0);
signal d02         : std_logic_vector (N + M -1 downto 0);
signal d03         : std_logic_vector (N + M -1 downto 0);
signal d04         : std_logic_vector (N + M -1 downto 0);
signal d05         : std_logic_vector (N + M -1 downto 0);
signal d06         : std_logic_vector (N + M -1 downto 0);
signal d07         : std_logic_vector (N + M -1 downto 0);
signal d08         : std_logic_vector (N + M -1 downto 0);
signal d09         : std_logic_vector (N + M -1 downto 0);
signal d10         : std_logic_vector (N + M -1 downto 0);
signal d11         : std_logic_vector (N + M -1 downto 0);
signal d12         : std_logic_vector (N + M -1 downto 0);
signal d13         : std_logic_vector (N + M -1 downto 0);
signal d14         : std_logic_vector (N + M -1 downto 0);
signal d15         : std_logic_vector (N + M -1 downto 0);
signal d16         : std_logic_vector (N + M -1 downto 0);
-------------- DEBUG END

begin

gen_no_BP: if BP = "no" and TP = "no" generate 



gen_Mults: if mult_sum = "mult" generate 
-- convolution
  p_conv_oper : process (clk)
  begin
    if rising_edge(clk) then
      for i in 0 to Kernel_size*Kernel_size-1 loop
        prod((i+1)*(N + M) -1 downto i*(N + M)) <= w((i+1)*M-1 downto i*M) * data2conv((i+1)*N-1 downto i*N);
      end loop;
      --c01 <= w1 * data2conv1;
      --c02 <= w2 * data2conv2;
      --c03 <= w3 * data2conv3;
      --c04 <= w4 * data2conv4;
      --c05 <= w5 * data2conv5;
      --c06 <= w6 * data2conv6;
      --c07 <= w7 * data2conv7;
      --c08 <= w8 * data2conv8;
      --c09 <= w9 * data2conv9;
      c01 <= w(1*M-1 downto 0*M) * data2conv(1*N-1 downto 0*N);
      c02 <= w(2*M-1 downto 1*M) * data2conv(2*N-1 downto 1*N);
      c03 <= w(3*M-1 downto 2*M) * data2conv(3*N-1 downto 2*N);
      c04 <= w(4*M-1 downto 3*M) * data2conv(4*N-1 downto 3*N);
      c05 <= w(5*M-1 downto 4*M) * data2conv(5*N-1 downto 4*N);
      c06 <= w(6*M-1 downto 5*M) * data2conv(6*N-1 downto 5*N);
      c07 <= w(7*M-1 downto 6*M) * data2conv(7*N-1 downto 6*N);
      c08 <= w(8*M-1 downto 7*M) * data2conv(8*N-1 downto 7*N);
      c09 <= w(9*M-1 downto 8*M) * data2conv(9*N-1 downto 8*N);

      if Kernel_size = 5 then
         --d01 <= w10 * data2conv10 ;
         --d02 <= w11 * data2conv11 ;
         --d03 <= w12 * data2conv12 ;
         --d04 <= w13 * data2conv13 ;
         --d05 <= w14 * data2conv14 ;
         --d06 <= w15 * data2conv15 ;
         --d07 <= w16 * data2conv16 ;
         --d08 <= w17 * data2conv17 ;
         --d09 <= w18 * data2conv18 ;
         --d10 <= w19 * data2conv19 ;
         --d11 <= w20 * data2conv20 ;
         --d12 <= w21 * data2conv21 ;
         --d13 <= w22 * data2conv22 ;
         --d14 <= w23 * data2conv23 ;
         --d15 <= w24 * data2conv24 ;
         --d16 <= w25 * data2conv25 ;
         d01 <= w(10*M-1 downto  9*M) * data2conv(10*N-1 downto  9*N) ;
         d02 <= w(11*M-1 downto 10*M) * data2conv(11*N-1 downto 10*N) ;
         d03 <= w(12*M-1 downto 11*M) * data2conv(12*N-1 downto 11*N) ;
         d04 <= w(13*M-1 downto 12*M) * data2conv(13*N-1 downto 12*N) ;
         d05 <= w(14*M-1 downto 13*M) * data2conv(14*N-1 downto 13*N) ;
         d06 <= w(15*M-1 downto 14*M) * data2conv(15*N-1 downto 14*N) ;
         d07 <= w(16*M-1 downto 15*M) * data2conv(16*N-1 downto 15*N) ;
         d08 <= w(17*M-1 downto 16*M) * data2conv(17*N-1 downto 16*N) ;
         d09 <= w(18*M-1 downto 17*M) * data2conv(18*N-1 downto 17*N) ;
         d10 <= w(19*M-1 downto 18*M) * data2conv(19*N-1 downto 18*N) ;
         d11 <= w(20*M-1 downto 19*M) * data2conv(20*N-1 downto 19*N) ;
         d12 <= w(21*M-1 downto 20*M) * data2conv(21*N-1 downto 20*N) ;
         d13 <= w(22*M-1 downto 21*M) * data2conv(22*N-1 downto 21*N) ;
         d14 <= w(23*M-1 downto 22*M) * data2conv(23*N-1 downto 22*N) ;
         d15 <= w(24*M-1 downto 23*M) * data2conv(24*N-1 downto 23*N) ;
         d16 <= w(25*M-1 downto 24*M) * data2conv(25*N-1 downto 24*N) ;
      end if;

    end if;
  end process p_conv_oper;



  p_mult : process (clk,rst)
  begin
    if rst = '1' then
       en_in1  <= (others => '0');
    elsif rising_edge(clk) then
       en_in1(EN_BIT)  <= en_in;     -- c01-c09/d01-d16 out  
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
  gen_mults: for i in 0 to Kernel_size*Kernel_size-1 generate
    A: generic_mult generic map (N => N,M => M) port map ( clk => clk,rst => rst, 
                    a    => data2conv((i+1)*     N  -1 downto i*     N ),  
                    b    => w        ((i+1)*     M  -1 downto i*     M ),  
                    prod => prod     ((i+1)*(N + M) -1 downto i*(N + M))  );
  end generate gen_mults;

  A1: generic_mult generic map (N => N,M => M) port map ( clk => clk,rst => rst, a => data2conv(1*N-1 downto 0*N),  b  => w(1*N-1 downto 0*N),  prod => c01);
  A2: generic_mult generic map (N => N,M => M) port map ( clk => clk,rst => rst, a => data2conv(2*N-1 downto 1*N),  b  => w(2*N-1 downto 1*N),  prod => c02);
  A3: generic_mult generic map (N => N,M => M) port map ( clk => clk,rst => rst, a => data2conv(3*N-1 downto 2*N),  b  => w(3*N-1 downto 2*N),  prod => c03);
  A4: generic_mult generic map (N => N,M => M) port map ( clk => clk,rst => rst, a => data2conv(4*N-1 downto 3*N),  b  => w(4*N-1 downto 3*N),  prod => c04);
  A5: generic_mult generic map (N => N,M => M) port map ( clk => clk,rst => rst, a => data2conv(5*N-1 downto 4*N),  b  => w(5*N-1 downto 4*N),  prod => c05);
  A6: generic_mult generic map (N => N,M => M) port map ( clk => clk,rst => rst, a => data2conv(6*N-1 downto 5*N),  b  => w(6*N-1 downto 5*N),  prod => c06);
  A7: generic_mult generic map (N => N,M => M) port map ( clk => clk,rst => rst, a => data2conv(7*N-1 downto 6*N),  b  => w(7*N-1 downto 6*N),  prod => c07);
  A8: generic_mult generic map (N => N,M => M) port map ( clk => clk,rst => rst, a => data2conv(8*N-1 downto 7*N),  b  => w(8*N-1 downto 7*N),  prod => c08);
  A9: generic_mult generic map (N => N,M => M) port map ( clk => clk,rst => rst, a => data2conv(9*N-1 downto 8*N),  b  => w(9*N-1 downto 8*N),  prod => c09);

sum_kernel5: if Kernel_size = 5 generate
  A10: generic_mult generic map (N => N,M => M) port map ( clk => clk,rst => rst, a => data2conv(10*N-1 downto  9*N),b  => w(10*N-1 downto  9*N),  prod => d01);
  A11: generic_mult generic map (N => N,M => M) port map ( clk => clk,rst => rst, a => data2conv(11*N-1 downto 10*N),b  => w(11*N-1 downto 10*N),  prod => d02);
  A12: generic_mult generic map (N => N,M => M) port map ( clk => clk,rst => rst, a => data2conv(12*N-1 downto 11*N),b  => w(12*N-1 downto 11*N),  prod => d03);
  A13: generic_mult generic map (N => N,M => M) port map ( clk => clk,rst => rst, a => data2conv(13*N-1 downto 12*N),b  => w(13*N-1 downto 12*N),  prod => d04);
  A14: generic_mult generic map (N => N,M => M) port map ( clk => clk,rst => rst, a => data2conv(14*N-1 downto 13*N),b  => w(14*N-1 downto 13*N),  prod => d05);
  A15: generic_mult generic map (N => N,M => M) port map ( clk => clk,rst => rst, a => data2conv(15*N-1 downto 14*N),b  => w(15*N-1 downto 14*N),  prod => d06);
  A16: generic_mult generic map (N => N,M => M) port map ( clk => clk,rst => rst, a => data2conv(16*N-1 downto 15*N),b  => w(16*N-1 downto 15*N),  prod => d07);
  A17: generic_mult generic map (N => N,M => M) port map ( clk => clk,rst => rst, a => data2conv(17*N-1 downto 16*N),b  => w(17*N-1 downto 16*N),  prod => d08);
  A18: generic_mult generic map (N => N,M => M) port map ( clk => clk,rst => rst, a => data2conv(18*N-1 downto 17*N),b  => w(18*N-1 downto 17*N),  prod => d09);
  A19: generic_mult generic map (N => N,M => M) port map ( clk => clk,rst => rst, a => data2conv(19*N-1 downto 18*N),b  => w(19*N-1 downto 18*N),  prod => d10);
  A20: generic_mult generic map (N => N,M => M) port map ( clk => clk,rst => rst, a => data2conv(20*N-1 downto 19*N),b  => w(20*N-1 downto 19*N),  prod => d11);
  A21: generic_mult generic map (N => N,M => M) port map ( clk => clk,rst => rst, a => data2conv(21*N-1 downto 20*N),b  => w(21*N-1 downto 20*N),  prod => d12);
  A22: generic_mult generic map (N => N,M => M) port map ( clk => clk,rst => rst, a => data2conv(22*N-1 downto 21*N),b  => w(22*N-1 downto 21*N),  prod => d13);
  A23: generic_mult generic map (N => N,M => M) port map ( clk => clk,rst => rst, a => data2conv(23*N-1 downto 22*N),b  => w(23*N-1 downto 22*N),  prod => d14);
  A24: generic_mult generic map (N => N,M => M) port map ( clk => clk,rst => rst, a => data2conv(24*N-1 downto 23*N),b  => w(24*N-1 downto 23*N),  prod => d15);
  A25: generic_mult generic map (N => N,M => M) port map ( clk => clk,rst => rst, a => data2conv(25*N-1 downto 24*N),b  => w(25*N-1 downto 24*N),  prod => d16);
end generate;

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
      if Kernel_size = 5 then
         d20 <= (d01(d01'left) & d01(d01'left) & d01) + (d02(d02'left) & d02(d02'left) & d02) + (d03(d03'left) & d03(d03'left) & d03) + (d04(d04'left) & d04(d04'left) & d04);
         d21 <= (d05(d05'left) & d05(d05'left) & d05) + (d06(d06'left) & d06(d06'left) & d06) + (d07(d07'left) & d07(d07'left) & d07) + (d08(d08'left) & d08(d08'left) & d08);
         d22 <= (d09(d09'left) & d09(d09'left) & d09) + (d10(d10'left) & d10(d10'left) & d10) + (d11(d11'left) & d11(d11'left) & d11) + (d12(d12'left) & d12(d12'left) & d12);
         d23 <= (d13(d13'left) & d13(d13'left) & d13) + (d14(d14'left) & d14(d14'left) & d14) + (d15(d15'left) & d15(d15'left) & d15) + (d16(d16'left) & d16(d16'left) & d16);

         d24 <= (d20(d20'left) & d20(d20'left) & d20) + (d21(d21'left) & d21(d21'left) & d21) + (d22(d22'left) & d22(d22'left) & d22) + (d23(d23'left) & d23(d23'left) & d23);

      end if;

      if Kernel_size = 7 then
        f01 <= ( prod(( 0+1)*(N + M) -1) & prod(( 0+1)*(N + M) -1) & prod(( 0+1)*(N + M) -1 downto  0*(N + M)) ) +
               ( prod(( 1+1)*(N + M) -1) & prod(( 1+1)*(N + M) -1) & prod(( 1+1)*(N + M) -1 downto  1*(N + M)) ) +
               ( prod(( 2+1)*(N + M) -1) & prod(( 2+1)*(N + M) -1) & prod(( 2+1)*(N + M) -1 downto  2*(N + M)) ) +
               ( prod(( 3+1)*(N + M) -1) & prod(( 3+1)*(N + M) -1) & prod(( 3+1)*(N + M) -1 downto  3*(N + M)) ) ;
        f02 <= ( prod(( 4+1)*(N + M) -1) & prod(( 4+1)*(N + M) -1) & prod(( 4+1)*(N + M) -1 downto  4*(N + M)) ) +
               ( prod(( 5+1)*(N + M) -1) & prod(( 5+1)*(N + M) -1) & prod(( 5+1)*(N + M) -1 downto  5*(N + M)) ) +
               ( prod(( 6+1)*(N + M) -1) & prod(( 6+1)*(N + M) -1) & prod(( 6+1)*(N + M) -1 downto  6*(N + M)) ) +
               ( prod(( 7+1)*(N + M) -1) & prod(( 7+1)*(N + M) -1) & prod(( 7+1)*(N + M) -1 downto  7*(N + M)) ) ;
        f03 <= ( prod(( 8+1)*(N + M) -1) & prod(( 8+1)*(N + M) -1) & prod(( 8+1)*(N + M) -1 downto  8*(N + M)) ) +
               ( prod(( 9+1)*(N + M) -1) & prod(( 9+1)*(N + M) -1) & prod(( 9+1)*(N + M) -1 downto  9*(N + M)) ) +
               ( prod((10+1)*(N + M) -1) & prod((10+1)*(N + M) -1) & prod((10+1)*(N + M) -1 downto 10*(N + M)) ) +
               ( prod((11+1)*(N + M) -1) & prod((11+1)*(N + M) -1) & prod((11+1)*(N + M) -1 downto 11*(N + M)) ) ;
        f04 <= ( prod((12+1)*(N + M) -1) & prod((12+1)*(N + M) -1) & prod((12+1)*(N + M) -1 downto 12*(N + M)) ) +
               ( prod((13+1)*(N + M) -1) & prod((13+1)*(N + M) -1) & prod((13+1)*(N + M) -1 downto 13*(N + M)) ) +
               ( prod((14+1)*(N + M) -1) & prod((14+1)*(N + M) -1) & prod((14+1)*(N + M) -1 downto 14*(N + M)) ) +
               ( prod((15+1)*(N + M) -1) & prod((15+1)*(N + M) -1) & prod((15+1)*(N + M) -1 downto 15*(N + M)) ) ;
        f05 <= ( prod((16+1)*(N + M) -1) & prod((16+1)*(N + M) -1) & prod((16+1)*(N + M) -1 downto 16*(N + M)) ) +
               ( prod((17+1)*(N + M) -1) & prod((17+1)*(N + M) -1) & prod((17+1)*(N + M) -1 downto 17*(N + M)) ) +
               ( prod((18+1)*(N + M) -1) & prod((18+1)*(N + M) -1) & prod((18+1)*(N + M) -1 downto 18*(N + M)) ) +
               ( prod((19+1)*(N + M) -1) & prod((19+1)*(N + M) -1) & prod((19+1)*(N + M) -1 downto 19*(N + M)) ) ;
        f06 <= ( prod((20+1)*(N + M) -1) & prod((20+1)*(N + M) -1) & prod((20+1)*(N + M) -1 downto 20*(N + M)) ) +
               ( prod((21+1)*(N + M) -1) & prod((21+1)*(N + M) -1) & prod((21+1)*(N + M) -1 downto 21*(N + M)) ) +
               ( prod((22+1)*(N + M) -1) & prod((22+1)*(N + M) -1) & prod((22+1)*(N + M) -1 downto 22*(N + M)) ) +
               ( prod((23+1)*(N + M) -1) & prod((23+1)*(N + M) -1) & prod((23+1)*(N + M) -1 downto 23*(N + M)) ) ;
        f07 <= ( prod((24+1)*(N + M) -1) & prod((24+1)*(N + M) -1) & prod((24+1)*(N + M) -1 downto 24*(N + M)) ) +
               ( prod((25+1)*(N + M) -1) & prod((25+1)*(N + M) -1) & prod((25+1)*(N + M) -1 downto 25*(N + M)) ) +
               ( prod((26+1)*(N + M) -1) & prod((26+1)*(N + M) -1) & prod((26+1)*(N + M) -1 downto 26*(N + M)) ) +
               ( prod((27+1)*(N + M) -1) & prod((27+1)*(N + M) -1) & prod((27+1)*(N + M) -1 downto 27*(N + M)) ) ;
       f08  <= ( prod((28+1)*(N + M) -1) & prod((28+1)*(N + M) -1) & prod((28+1)*(N + M) -1 downto 28*(N + M)) ) +
               ( prod((29+1)*(N + M) -1) & prod((29+1)*(N + M) -1) & prod((29+1)*(N + M) -1 downto 29*(N + M)) ) +
               ( prod((30+1)*(N + M) -1) & prod((30+1)*(N + M) -1) & prod((30+1)*(N + M) -1 downto 30*(N + M)) ) +
               ( prod((31+1)*(N + M) -1) & prod((31+1)*(N + M) -1) & prod((31+1)*(N + M) -1 downto 31*(N + M)) ) ;
       f09  <= ( prod((32+1)*(N + M) -1) & prod((32+1)*(N + M) -1) & prod((32+1)*(N + M) -1 downto 32*(N + M)) ) +
               ( prod((33+1)*(N + M) -1) & prod((33+1)*(N + M) -1) & prod((33+1)*(N + M) -1 downto 33*(N + M)) ) +
               ( prod((34+1)*(N + M) -1) & prod((34+1)*(N + M) -1) & prod((34+1)*(N + M) -1 downto 34*(N + M)) ) +
               ( prod((35+1)*(N + M) -1) & prod((35+1)*(N + M) -1) & prod((35+1)*(N + M) -1 downto 35*(N + M)) ) ;
       f10  <= ( prod((36+1)*(N + M) -1) & prod((36+1)*(N + M) -1) & prod((36+1)*(N + M) -1 downto 36*(N + M)) ) +
               ( prod((37+1)*(N + M) -1) & prod((37+1)*(N + M) -1) & prod((37+1)*(N + M) -1 downto 37*(N + M)) ) +
               ( prod((38+1)*(N + M) -1) & prod((38+1)*(N + M) -1) & prod((38+1)*(N + M) -1 downto 38*(N + M)) ) +
               ( prod((39+1)*(N + M) -1) & prod((39+1)*(N + M) -1) & prod((39+1)*(N + M) -1 downto 39*(N + M)) ) ;
       f11  <= ( prod((40+1)*(N + M) -1) & prod((40+1)*(N + M) -1) & prod((40+1)*(N + M) -1 downto 40*(N + M)) ) +
               ( prod((41+1)*(N + M) -1) & prod((41+1)*(N + M) -1) & prod((41+1)*(N + M) -1 downto 41*(N + M)) ) +
               ( prod((42+1)*(N + M) -1) & prod((42+1)*(N + M) -1) & prod((42+1)*(N + M) -1 downto 42*(N + M)) ) +
               ( prod((43+1)*(N + M) -1) & prod((43+1)*(N + M) -1) & prod((43+1)*(N + M) -1 downto 43*(N + M)) ) ;
       f12  <= ( prod((44+1)*(N + M) -1) & prod((44+1)*(N + M) -1) & prod((44+1)*(N + M) -1 downto 44*(N + M)) ) +
               ( prod((45+1)*(N + M) -1) & prod((45+1)*(N + M) -1) & prod((45+1)*(N + M) -1 downto 45*(N + M)) ) +
               ( prod((46+1)*(N + M) -1) & prod((46+1)*(N + M) -1) & prod((46+1)*(N + M) -1 downto 46*(N + M)) ) +
               ( prod((47+1)*(N + M) -1) & prod((47+1)*(N + M) -1) & prod((47+1)*(N + M) -1 downto 47*(N + M)) ) ;
       f13 <=  ( prod((48+1)*(N + M) -1) & prod((48+1)*(N + M) -1) & prod((48+1)*(N + M) -1 downto 48*(N + M)) ) ;

       f21 <= (f01(f01'left) & f01(f01'left) & f01) +
              (f02(f02'left) & f02(f02'left) & f02) +
              (f03(f03'left) & f03(f03'left) & f03) +
              (f04(f04'left) & f04(f04'left) & f04) ;
       f22 <= (f05(f05'left) & f05(f05'left) & f05) +
              (f06(f06'left) & f06(f06'left) & f06) +
              (f07(f07'left) & f07(f07'left) & f07) +
              (f08(f08'left) & f08(f08'left) & f08) ;
       f23 <= (f09(f09'left) & f09(f09'left) & f09) +
              (f10(f10'left) & f10(f10'left) & f10) +
              (f11(f11'left) & f11(f11'left) & f11) +
              (f12(f12'left) & f12(f12'left) & f12) ;
       f24 <= (f13(f13'left) & f13(f13'left) & f13) ;

--       f25 <= (f21(f21'left) & f21(f21'left) & f21) +
--              (f22(f22'left) & f22(f22'left) & f22) +
--              (f23(f23'left) & f23(f23'left) & f23) +
--              (f24(f24'left) & f24(f24'left) & f24) ;

      end if;

    end if;
  end process p_conv_oper;

--add_kernel5: if Kernel_size = 5 generate
--  p_conv_oper2 : process (clk)
--  begin
--    if rising_edge(clk) then
--      d20 <= (d01(d01'left) & d01(d01'left) & d01) + (d02(d02'left) & d02(d02'left) & d02) + (d03(d03'left) & d03(d03'left) & d03) + (d04(d04'left) & d04(d04'left) & d04);
--      d21 <= (d05(d05'left) & d05(d05'left) & d05) + (d06(d06'left) & d06(d06'left) & d06) + (d07(d07'left) & d07(d07'left) & d07) + (d08(d08'left) & d08(d08'left) & d08);
--      d22 <= (d09(d09'left) & d09(d09'left) & d09) + (d10(d10'left) & d10(d10'left) & d10) + (d11(d11'left) & d11(d11'left) & d11) + (d12(d12'left) & d12(d12'left) & d12);
--      d23 <= (d13(d13'left) & d13(d13'left) & d13) + (d14(d14'left) & d14(d14'left) & d14) + (d15(d15'left) & d15(d15'left) & d15) + (d16(d16'left) & d16(d16'left) & d16);
--
--      d24 <= (d20(d20'left) & d20(d20'left) & d20) + (d21(d21'left) & d21(d21'left) & d21) + (d22(d22'left) & d22(d22'left) & d22) + (d23(d23'left) & d23(d23'left) & d23);
--
--    end if;
--  end process p_conv_oper2;

--end generate;

  insamp2 : process (clk,rst)
  begin
    if rst = '1' then
       en_end2 <= (others => '0');
       en_end3 <= (others => '0');
       en_end4 <= (others => '0');
    elsif rising_edge(clk) then
       en_end2 <= en_in1;
       en_end3 <= en_end2;
       en_end4 <= en_end3;
    end if;
  end process insamp2;

  p_ker : process (clk)
  begin
    if rising_edge(clk) then

       if    Kernel_size = 7 then
          d_ker <= (f21(f21'left) & f21(f21'left) & f21) +
                   (f22(f22'left) & f22(f22'left) & f22) +
                   (f23(f23'left) & f23(f23'left) & f23) +
                   (f24(f24'left) & f24(f24'left) & f24) ;
       elsif Kernel_size = 5 then
          d_ker <= (c13(c13'left) & c13(c13'left) & c13) + 
                   (d24(d24'left) & d24(d24'left) & d24) ;
       else
          d_ker <= c13(c13'left) & c13(c13'left) & c13;
       end if;
    end if;
  end process p_ker;

--  p_relu : process (clk)
--  begin
--    if rising_edge(clk) then
--      if Relu = "yes" then
--         relu_for: for i in 0 to d_ker'length-1  loop
--           d_relu(i) <= d_ker(i) and not d_ker(d_ker'left);    -- if MSB=1 (negative) thwen all bits are 0
--         end loop relu_for;
--      else
--         d_relu <= d_ker;
--      end if;
--    end if;
--  end process p_relu;
--
--  p_relu_samp : process (clk,rst)
--  begin
--    if rst = '1' then
--       en_relu <= (others => '0');
--    elsif rising_edge(clk) then
--       en_relu <= en_end4;
--    end if;
--  end process p_relu_samp;
--
-- -- check overflow before shift and change value to maximum if overflow occurs
--   p_ovf : process (clk)
--  begin
--    if rising_edge(clk) then
--       --if SR = 0 then
--       --   d_ovf <= d_relu;
--       --else
--          --if d_relu(d_relu'left  downto d_relu'left - SR ) = 0  then
--          if d_relu(d_relu'left  downto W + SR -2) = 0  then
--             d_ovf <= d_relu;
--          else
--             d_ovf( d_relu'left  downto W + SR -2 ) <= (others => '0'); 
--             d_ovf( W + SR - 3   downto         0 ) <= (others => '1'); 
--          end if;
--       --end if;
--    end if;
--  end process p_ovf;
--
-- p_ovf_samp : process (clk,rst)
--  begin
--    if rst = '1' then
--       en_ovf <= (others => '0');
--    elsif rising_edge(clk) then
--       en_ovf <= en_relu;
--    end if;
--  end process p_ovf_samp;

en_out  <= en_end4(EN_BIT);
sof_out <= en_end4(SOF_BIT);
d_out   <= d_ker; 

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

    d_out(N + M +5 downto 0) <= data2conv(N + M +5 downto 0);
    en_out  <= en_in;
    sof_out <= sof_in;
 --end process ;

end generate; --  BP = "yes"

end a;