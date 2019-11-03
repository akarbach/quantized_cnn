library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;
--use ieee.math_real.all;
library work;
use work.ConvLayer_types_package.all;


entity ConvLayer_grp is
  generic (
  	       mult_sum      : string := "mult"; --"mult"/"sum";
           Kernel_size   : integer := 3; -- 3/5
           CL_inputs     : integer := 4; -- number of inputs features
           CL_outs       : integer := 2; -- number of output features
           
           --CL_outs      : integer := 3; -- number of CL units
           N             : integer := 4; --W; -- input data width
           M             : integer := 4;  --W; -- input weight width
      
           SR            : integer := 1; -- data shift right before output (deleted LSBs)
           --bpp           : integer := 8; -- bit per pixel
  	       in_row        : integer := 114;
  	       in_col        : integer := 114
  	       );
  port    (
           clk       : in std_logic;
           rst       : in std_logic;
  	       data2conv : in std_logic_vector (CL_inputs*Kernel_size*Kernel_size*N-1 downto 0);
  	       en_in     : in std_logic;
  	       sof_in    : in std_logic; -- start of frame
           w         : in std_logic_vector(CL_inputs*CL_outs*Kernel_size*Kernel_size*M-1 downto 0); -- weight matrix


           d_out     : out vec_out(0 to CL_outs -1); --std_logic_vector (W-1 downto 0); --vec;
           en_out    : out std_logic;
           sof_out   : out std_logic);
end ConvLayer_grp;

architecture a of ConvLayer_grp is

component ConvLayer_calc is
  generic (
           BP            : string := "no";  --"no"/"yes"  -- Bypass
           TP            : string := "no";  --"no"/"yes"  -- Test pattern output
           mult_sum      : string := "mult"; --"mult"/"sum"
           Kernel_size   : integer := 3; -- 3/5/7
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
end component;


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
           d_in        : in vec_mavin(0 to CL_inputs*CL_outs -1);

           en_in       : in std_logic;
           sof_in      : in std_logic; -- start of frame

           d_out       : out vec_out(0 to CL_outs -1);
           en_out      : out std_logic;
           sof_out     : out std_logic);
end component;

constant   Relu        : string := "yes";  --"no"/"yes"  -- nonlinear Relu function
constant   BP          : string := "no" ;   --"no"/"yes"  -- Bypass
constant   TP          : string := "no" ;   --"no"/"yes"  -- Test pattern output


--signal en_s       : std_logic_vector(CL_inputs-1 downto 0);         -- std_logic;
--signal sof_s      : std_logic_vector(CL_inputs-1 downto 0);         -- std_logic;
--
--signal w_in_s     : vec_weight(0 to CL_inputs -1);
--signal w_num_s    : std_logic_vector(  4 downto 0);
----signal w_unit_en  : std_logic_vector (CL_outs-1 downto 0);
----signal w_unit_input   : integer;
--signal w_unit_output  : integer;
--
----type d_out_mat is array (natural range 0 to CL_inputs -1) of vec;
--type d_out_vec is array (natural range 0 to CL_outs -1) of std_logic_vector(W-1 downto 0); --element;
--type d_out_mat is array (natural range 0 to (CL_inputs -1)) of d_out_vec;
----signal d_out1     : d_out_mat;                                      --vec;
signal d_out1     : vec_mavin(0 to CL_inputs*CL_outs -1);                                      --vec;
--
signal d_sums     : vec_out(0 to CL_outs -1);
--signal w_unit_en  : std_logic_vector(CL_outs-1 downto 0);
--
--type t_mat is array (0 to CL_inputs-1) of std_logic_vector(CL_outs-1 downto 0); 
--signal en_out1    : t_mat;                                            -- std_logic_vector (CL_outs-1 downto 0);
--signal sof_out1   : t_mat;                                            -- std_logic_vector (CL_outs-1 downto 0);
--
--signal countI      : std_logic_vector (9 downto 0);
--signal countJ      : std_logic_vector (9 downto 0);
--
signal en_sums     : std_logic;
signal sof_sums    : std_logic;
--signal d_out1     : d_out_mat;                                      --vec;
--signal d_out1       : std_logic_vector ((N + M + 6) * CL_inputs * CL_outs -1 downto 0);
signal en_out1      : std_logic_vector (CL_inputs * CL_outs -1 downto 0);
signal sof_out1     : std_logic_vector (CL_inputs * CL_outs -1 downto 0);


begin


gen_inCL: for J in 0 to CL_inputs-1 generate

gen_CL: for I in 0 to CL_outs-1 generate


 CL_c:  ConvLayer_calc
  generic map (
           BP         => BP         ,
           TP         => TP         ,
           mult_sum   => mult_sum   ,
           Kernel_size=> Kernel_size,
           N          => N          ,
           M          => M                  

           )
  port  map  ( 
           clk         => clk        ,
           rst         => rst        ,
           data2conv   => data2conv (Kernel_size*Kernel_size*N*(j+1)-1 downto Kernel_size*Kernel_size*N*j),

           en_in      => en_in       ,
           sof_in     => sof_in      ,
     --    w          => w(Kernel_size*Kernel_size*M * (j * CL_inputs+1)*(i+1)-1 downto Kernel_size*Kernel_size*M*(j * CL_inputs + 1)*i), -- weight matrix
           w          => w(Kernel_size*Kernel_size*M * (j * CL_outs + i + 1)-1 downto Kernel_size*Kernel_size*M*(j * CL_outs + i)), -- weight matrix


           d_out      => d_out1  (j*CL_outs + i) , --d_out1  ((N + M + 6) * j* CL_inputs * (i+1) -1 downto (N + M + 6) * j* CL_inputs * i ),
           en_out     => en_out1 (j*CL_outs + i) ,
           sof_out    => sof_out1(j*CL_outs + i)
         );

end generate gen_CL;


end generate gen_inCL;


adder: multi_adder
  generic map (
           Relu        => Relu          ,
           BP          => BP            ,
           TP          => TP            ,
           CL_inputs   => CL_inputs     , 
           CL_outs     => CL_outs       ,
           N           => N + M + 6     ,
           W           => N             ,            
           SR          => SR            
           )
  port map   (
           clk         => clk           ,
           rst         => rst           ,
           d_in        => d_out1        ,

           en_in       => en_out1 (0)   ,
           sof_in      => sof_out1(0)   ,

           d_out       => d_sums        ,
           en_out      => en_sums       ,
           sof_out     => sof_sums
           );

d_out <= d_sums;
en_out  <= en_sums ;
sof_out <= sof_sums;

end a;