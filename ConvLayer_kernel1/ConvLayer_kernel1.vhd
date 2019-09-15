library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;
use ieee.math_real.all;
library work;
use work.ConvLayer_types_package.all;

entity ConvLayer_kernel1 is
  generic (
           Relu          : string := "yes";  --"no"/"yes"  -- nonlinear Relu function
           BP            : string := "no";   --"no"/"yes"  -- Bypass
           TP            : string := "no";   --"no"/"yes"  -- Test pattern output
  	       mult_sum      : string := "sum"; --"mult"/"sum";
           CL_inputs     : integer := 16; --160; -- number of inputs features
           CL_outs       : integer := 96; --960; -- number of output features

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

           w_CLin_n  : in std_logic_vector( 9 downto 0) ;  -- address weight generators, CL inputs
           w_CLout_n : in std_logic_vector( 9 downto 0) ;  -- address weight generators, CL outputs
           w_in      : in std_logic_vector(M-1 downto 0);  -- value
           w_en      : in std_logic;

           d_out   : out vec(0 to CL_outs -1)(W-1 downto 0); --std_logic_vector (W-1 downto 0); --vec;
           en_out  : out std_logic;
           sof_out : out std_logic);
end ConvLayer_kernel1;

architecture a of ConvLayer_kernel1 is

component multi_adder is
  generic (
           Relu          : string := "yes"; --"no"/"yes"  -- nonlinear Relu function
           BP            : string := "no";  --"no"/"yes"  -- Bypass
           TP            : string := "no";  --"no"/"yes"  -- Test pattern output
           CL_inputs     : integer := 3;    -- number of inputs features
           CL_outs       : integer := 6;    -- number of output features
           N             : integer := 8;    -- input data width
           W             : integer := 8;     -- output data width  
           SR            : integer := 2     -- data shift right before output
           );
  port    (
           clk         : in std_logic;
           rst         : in std_logic;
           d_in        : in vec(0 to CL_inputs*CL_outs -1)(N-1 downto 0);

           en_in       : in std_logic;
           sof_in      : in std_logic; -- start of frame

           d_out       : out vec(0 to CL_outs -1)(W-1 downto 0);
           en_out      : out std_logic;
           sof_out     : out std_logic);
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

signal w1         : vec(0 to CL_outs*CL_inputs -1)(M-1 downto 0);

type t_data2conv is array (0 to CL_inputs-1) of std_logic_vector(N-1 downto 0);
signal data2conv1  : t_data2conv;                                   --std_logic_vector (N-1 downto 0);


--signal en_s       : std_logic_vector(CL_inputs-1 downto 0);         -- std_logic;
--signal sof_s      : std_logic_vector(CL_inputs-1 downto 0);         -- std_logic;
--signal w_in_s     : std_logic_vector(M-1 downto 0);
--signal w_num_s    : std_logic_vector(  4 downto 0);


--type d_out_mat is array (natural range 0 to CL_inputs -1) of vec;
type d_out_vec is array (natural range 0 to CL_outs -1) of std_logic_vector(W-1 downto 0); --element;
type d_out_mat is array (natural range 0 to (CL_inputs -1)) of d_out_vec;
--signal d_out1     : d_out_mat;                                      --vec;
signal d_out1     : vec(0 to CL_inputs*CL_outs -1)(N + M -1  downto 0);                                      --vec;

signal d_sums     : vec(0 to CL_outs -1)(W-1 downto 0);
signal w_unit_en  : vec(0 to CL_inputs -1)(CL_outs-1 downto 0);


signal en_out1  , en_tmp    : std_logic; 
signal sof_out1 , sof_tmp   : std_logic; 

signal countI      : std_logic_vector (9 downto 0);
signal countJ      : std_logic_vector (9 downto 0);

signal en_sums     : std_logic;
signal sof_sums    : std_logic;

begin


w_en_p : process (clk,rst)
begin
   if rst = '1' then
       w_unit_en     <= (others => (others => '0'));
   elsif rising_edge(clk) then
      if w_en = '1' then
         w1 (conv_integer(unsigned('0' & w_CLin_n))*CL_outs + conv_integer(unsigned('0' & w_CLout_n)) )  <= w_in;
      end if;
   end if;
end process w_en_p;


gen_inCL: for J in 0 to CL_inputs-1 generate
   gen_CL: for I in 0 to CL_outs-1 generate
      gen_Mults: if mult_sum = "mult" generate 
         p_conv_oper : process (clk)
         begin
           if rising_edge(clk) then
             d_out1  (j*CL_outs + i) <= w1 (j*CL_outs + i) * d_in(j);
           end if;
         end process p_conv_oper;
      end generate gen_Mults;  -- mult
      
      gen_Adds: if mult_sum = "sum" generate 
         A1: generic_mult generic map (N => N,M => M) port map ( clk => clk,rst => rst, a => d_in(j),  b  => w1 (j*CL_outs + i),  prod => d_out1  (j*CL_outs + i));
      end generate gen_Adds; -- sum
   end generate gen_CL;
end generate gen_inCL;

  p_en : process (clk,rst)
  begin
    if rst = '1' then
       en_out1  <= '0';
       sof_out1 <= '0';
       en_tmp   <= '0';
       sof_tmp  <= '0';
    elsif rising_edge(clk) then
       if mult_sum  = "mult" then
          en_out1  <= en_in;
          sof_out1 <= sof_in;
       end if;
       if mult_sum  = "sum" then
          en_tmp   <= en_in;
          sof_tmp  <= sof_in;
          en_out1  <= en_tmp;
          sof_out1 <= sof_tmp;
       end if;
    end if;
  end process p_en;


adder: multi_adder
  generic map (
           Relu        => Relu     ,
           BP          => BP       ,
           TP          => TP       ,
           CL_inputs   => CL_inputs, 
           CL_outs     => CL_outs  ,
           N           => N + M    ,
           W           => W        ,            
           SR          => SR            
           )
  port map   (
           clk         => clk      ,
           rst         => rst      ,
           d_in        => d_out1   ,

           en_in       => en_out1  ,
           sof_in      => sof_out1 ,

           d_out       => d_sums   ,
           en_out      => en_sums  ,
           sof_out     => sof_sums
           );

d_out <= d_sums;
en_out  <= en_sums ;
sof_out <= sof_sums;

end a;