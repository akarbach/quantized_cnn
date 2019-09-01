library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;
--USE ieee.math_real.log2;
--USE ieee.math_real.ceil;
library work;
use work.ConvLayer_types_package.all;

entity ResNet18 is
  generic (
           mult_sum        : string := "mult"; --"mult"/"sum"
           poll_criteria   : string := "max"; --"max"/"average" -                    average -> TBD!!!! !
           Kernel_size_1   : integer :=    5;  -- 3/5 first CL level 
           Kernel_size_int : integer :=    3;  -- 3/5 internal CL levels 
           stride1         : integer :=    2;  -- stride, first CL level 
           CL_inputs       : integer := 2; --   3;  -- number of inputs features (maximum = 1024)
           CL_1            : integer := 3; --  64;  -- number CL output features of the 1/2 CL level
           CL_2            : integer := 4; --  64;  -- number CL output features of the 1st CL level
           CL_3            : integer := 5; -- 128;  -- number CL output features of the 1st CL level
           CL_4            : integer := 6; -- 256;  -- number CL output features of the 1st CL level
           CL_5            : integer := 7; -- 512;  -- number CL output features of the 1st CL level
           CL_outs         : integer := 8; --1000;  -- number of output features of the fully connected level
           FC_w_num_max    : integer := 4;  -- 512;  -- number of weights in one memory line of fully conected level, CL_outs > w_num_max (see below)
           N               : integer :=    8;  -- input/output data width
           M               : integer :=    8;  -- input weight width
           SR_1            : integer :=    9;  -- data shift right before output
           SR_int          : integer :=    9;  -- data shift right before output
           SR_FC           : integer :=    3;
           in_row          : integer :=  224;  -- input image size
           in_col          : integer :=  224   -- input image size
  	       );
  port    (
           clk           : in std_logic;
           rst           : in std_logic;
           d_in          : in vec(0 to CL_inputs-1)(N-1 downto 0);
  	       en_in         : in std_logic;
           sof_in        : in std_logic; -- start of frame
           
           w_unit_n      : in std_logic_vector( 15 downto 0); 
           w_in          : in std_logic_vector( M-1 downto 0);  -- value
           w_en          : in std_logic;
           w_pixel_N     : in std_logic_vector(12-1 downto 0);  -- FC. weignt of pixel number
           w_pixel_L     : in std_logic_vector(12-1 downto 0);  -- FC. weignt of pixel line
           w_num         : in std_logic_vector( 8-1 downto 0);  -- number of weight in the line
           w_lin_rdy     : in std_logic;                        -- weigth line ready indication
           w_CL_select   : in std_logic_vector(  2 downto 0);   -- number of CL layer
           w_Grp_select  : in std_logic_vector(  2 downto 0);   -- number of Filter Group
           w_GoF_select  : in std_logic_vector(  2 downto 0);   -- number of grouf of Filter Group

           d_out       : out vec(0 to CL_outs -1)(N-1 downto 0);
           en_out      : out std_logic);
end ResNet18;

architecture a of ResNet18 is

component ConvLayer is
  generic (
           Relu          : string := "no"; --"no"/"yes"  -- nonlinear Relu function
           BP            : string := "no";  --"no"/"yes"  -- Bypass
           TP            : string := "no";  --"no"/"yes"  -- Test pattern output
           mult_sum      : string := "sum";
           Kernel_size   : integer := 3; -- 3/5
           zero_padding  : string := "yes";  --"no"/"yes"
           stride        : integer := 1;
           CL_inputs     : integer := 14; -- number of inputs features
           CL_outs       : integer := 4; -- number of output features
           N             : integer := 8; -- input data width
           M             : integer := 8; -- input weight width
           W             : integer := 2; -- output data width      (Note, W+SR <= N+M+4)
           SR            : integer := 2; -- data shift right before output
           in_row        : integer := 256;
           in_col        : integer := 256
           );
  port    (
           clk     : in std_logic;
           rst     : in std_logic;
           d_in    : in vec(0 to CL_inputs -1)(N-1 downto 0);
           en_in   : in std_logic;
           sof_in  : in std_logic; -- start of frame

           w_unit_n: in std_logic_vector( 15 downto 0);
           w_in    : in std_logic_vector(M-1 downto 0);
           w_num   : in std_logic_vector(  4 downto 0);
           w_en    : in std_logic;

           d_out   : out vec(0 to CL_outs -1)(W-1 downto 0);
           en_out  : out std_logic;
           sof_out : out std_logic);
end component;



component Identity_connection_group is
  generic (
           --Pooling       : string := "yes";   --"no"/"yes"  -- Bypass
           BP            : string := "no";   --"no"/"yes"  -- Bypass
           TP            : string := "no";   --"no"/"yes"  -- Test pattern output
           poll_criteria : string := "max"; --"max"/"average" -                    average -> TBD!!!! !
           mult_sum      : string := "mult"; --"mult"/"sum";
           CL_Kernel_size: integer :=  3; -- 3/5
           P_Kernel_size : integer :=  3; -- 3/5
           stridePool    : integer :=  2; -- stride of the pooling stage, stride of CL is 1
           CL_inputs     : integer := 2; -- number of inputs features of the first CL
           CL_outs       : integer := 3; -- number of output features of the first CL and all features of the next CLs
           NumOfGrp      : integer := 2; --1..8 -- number of Filter Groups (Identity_connection)
           NumOfLayers   : integer := 2; --1..8 -- number of CL layers in each Filter Group

           N             : integer := 8; --W; -- input data width
           M             : integer := 8; --W; -- input weight width
           W             : integer := 8; --         output data width      (Note, W+SR <= N+M+4)
           SR_cl         : int_array := (5,5,5,5); -- CL0, CL1,  CL2, CL3 units.  data shift right before output (deleted LSBs)
           --SR_cl         : integer := 1; -- 0/1  -- CL unit.  data shift right before output (deleted LSBs)
           SR_sum        : integer := 1; -- Sum unit. data shift right before output (deleted LSBs)
           in_row        : integer := 5;
           in_col        : integer := 5
           );
  port    (
           clk           : in std_logic;
           rst           : in std_logic;
           d_in          : in vec(0 to CL_inputs -1)(N-1 downto 0); --invec;                                      --std_logic_vector (N-1 downto 0);
           en_in         : in std_logic;
           sof_in        : in std_logic; -- start of frame

           w_unit_n      : in std_logic_vector( 15 downto 0);  -- address weight generators,  8MSB - CL inputs, 8LSB - CL outputs
           w_in          : in std_logic_vector(M-1 downto 0);  -- value
           w_num         : in std_logic_vector(  4 downto 0);  -- number of weight
           w_en          : in std_logic;
           w_lin_rdy     : in std_logic; 
           w_CL_select   : in std_logic_vector(  2 downto 0); -- number of CL layer
           w_Grp_select  : in std_logic_vector(  2 downto 0); -- number of Filter Group

           d_out         : out vec(0 to CL_outs -1)(N-1 downto 0); --vec;
           en_out        : out std_logic;
           sof_out       : out std_logic
           );
end component;

component Pooling_serial is
  generic (
           CL_inputs     : integer := 3; -- number of inputs features
           N             : integer := 8;  -- data width (maxinum 8 bit)
           in_row        : integer := 7;
           in_col        : integer := 7
           );
  port    (
           clk     : in  std_logic;
           rst     : in  std_logic;
           d_in    : in  vec(0 to CL_inputs -1)(N-1 downto 0);
           en_in   : in  std_logic;
           sof_in  : in  std_logic; -- start of frame
           d_out   : out vec(0 to CL_inputs -1)(N-1 downto 0);
           en_out  : out std_logic);
end component;

component Linear_serial is
  generic (
           mult_sum      : string := "mult"; --"mult"/"sum"
           CL_inputs     : integer := 16;    -- number of inputs features (maximum = 1024)
           CL_outs       : integer := 512;    -- number of output features
           w_num_max     : integer := 512;    -- number of weights in one memory line, CL_outs > w_num_max (see below)
           N             : integer := 16;     -- input/output data width
           M             : integer := 8;     -- input weight width
           SR            : integer := 2      -- data shift right before output
           );
  port    (
           clk         : in std_logic;
           rst         : in std_logic;
           d_in        : in vec(0 to CL_inputs-1)(N-1 downto 0);
           en_in       : in std_logic;
           
           w_in        : in std_logic_vector( M-1 downto 0);  -- value
           w_en        : in std_logic;
           w_pixel_N   : in std_logic_vector(12-1 downto 0);  -- weignt of pixel number
           w_pixel_L   : in std_logic_vector(12-1 downto 0);  -- weignt of pixel line
           w_num       : in std_logic_vector( 8-1 downto 0);  -- number of weight in the line
           w_lin_rdy   : in std_logic;                        -- weigth line ready indication

           d_out       : out vec(0 to CL_outs -1)(N-1 downto 0);
           en_out      : out std_logic);
end component;

constant Relu          : string  := "yes";
constant TP            : string  := "no";
constant BP            : string  := "no";
constant zero_padding  : string  := "yes";
constant NumOfGrp      : integer := 2; 
constant NumOfLayers   : integer := 2; 
constant SR_cl         : int_array := (5,5,5,5);
constant SR_sum        : integer := 1;
constant strideInternal: integer := 1; 

constant in_row_2     : integer := in_row  /2;
constant in_col_2     : integer := in_col  /2;
constant in_row_3     : integer := in_row_2/2;
constant in_col_3     : integer := in_col_2/2;
constant in_row_4     : integer := in_row_3/2;
constant in_col_4     : integer := in_col_3/2;
constant in_row_5     : integer := in_row_4/2;
constant in_col_5     : integer := in_col_4/2;
constant in_row_aver  : integer := in_row_5/2;
constant in_col_aver  : integer := in_col_5/2;

signal  w_unit_n_s      : std_logic_vector( 15 downto 0);  -- address weight generators,  8MSB - CL inputs, 8LSB - CL outputs
signal  w_in_s          : std_logic_vector(M-1 downto 0);  -- value
signal  w_num_s         : std_logic_vector( 8-1 downto 0);  -- number of weight
signal  w_en_s          : std_logic_vector(  7 downto 0);
signal  w_lin_rdy_s     : std_logic; 
signal  w_CL_select_s   : std_logic_vector(  2 downto 0); -- number of CL layer
signal  w_Grp_select_s  : std_logic_vector(  2 downto 0); -- number of Filter Group
signal  w_pixel_N_s     : std_logic_vector(12-1 downto 0);
signal  w_pixel_L_s     : std_logic_vector(12-1 downto 0);

signal  d_out_1   : vec(0 to CL_1 -1)(N-1 downto 0);
signal  en_out_1  : std_logic;
signal  sof_out_1 : std_logic;
signal  d_out_2   : vec(0 to CL_2 -1)(N-1 downto 0);
signal  en_out_2  : std_logic;
signal  sof_out_2 : std_logic;
signal  d_out_3   : vec(0 to CL_3 -1)(N-1 downto 0);
signal  en_out_3  : std_logic;
signal  sof_out_3 : std_logic;
signal  d_out_4   : vec(0 to CL_4 -1)(N-1 downto 0);
signal  en_out_4  : std_logic;
signal  sof_out_4 : std_logic;
signal  d_out_5   : vec(0 to CL_5 -1)(N-1 downto 0);
signal  en_out_5  : std_logic;
signal  sof_out_5 : std_logic;
signal  d_out_aver  : vec(0 to CL_5 -1)(N-1 downto 0);
signal  en_out_aver : std_logic;

begin
----------------------
-----   1st CL   -----
----------------------
-- 5x5, (7x7 TBD)
-- 1 input, 64 outs
-- stride 2
---------------------
CL1: ConvLayer 
  generic map (
           Relu          => Relu         , 
           BP            => BP           , 
           TP            => TP           , 
           mult_sum      => mult_sum     , 
           Kernel_size   => Kernel_size_1, 
           zero_padding  => zero_padding , 
           stride        => stride1      , 
           CL_inputs     => CL_inputs    , 
           CL_outs       => CL_1         , 
           N             => N            , 
           M             => M            , 
           W             => N            , 
           SR            => SR_1         , 
           in_row        => in_row       , 
           in_col        => in_col         
           )
  port map   (
           clk          => clk      , 
           rst          => rst      , 
           d_in         => d_in     , 
           en_in        => en_in    , 
           sof_in       => sof_in   , 
           w_unit_n     => w_unit_n , 
           w_in         => w_in     , 
           w_num        => w_num(4 downto 0), 
           w_en         => w_en_s(1), 
           d_out        => d_out_1  , 
           en_out       => en_out_1 , 
           sof_out      => sof_out_1  
          );

----------------------
-----   2nd CL   -----
----------------------
-- frame 56x56 
-- 64 input, 64 outs
---------------------

CL2: Identity_connection_group 
  generic map (
           BP             => BP             , 
           TP             => TP             , 
           poll_criteria  => poll_criteria  ,
           mult_sum       => mult_sum       ,
           CL_Kernel_size => Kernel_size_int,
           P_Kernel_size  => Kernel_size_int,
           stridePool     => strideInternal ,
           CL_inputs      => CL_1           , 
           CL_outs        => CL_2           ,
           NumOfGrp       => NumOfGrp       ,
           NumOfLayers    => NumOfLayers    , 
           N              => N              , 
           M              => M              , 
           W              => N              , 
           SR_cl          => SR_cl          , 
           SR_sum         => SR_sum         , 
           in_row         => in_row_2       , 
           in_col         => in_col_2         
           )
  port map   (
           clk         => clk            ,
           rst         => rst            ,
           d_in        => d_out_1        ,
           en_in       => en_out_1       ,
           sof_in      => sof_out_1      ,
           w_unit_n    => w_unit_n_s     ,
           w_in        => w_in_s         ,
           w_num       => w_num_s(4 downto 0),
           w_en        => w_en_s(2)      ,
           w_lin_rdy   => w_lin_rdy_s    , 
           w_CL_select => w_CL_select_s  ,
           w_Grp_select=> w_Grp_select_s ,
           d_out       => d_out_2        ,
           en_out      => en_out_2       ,
           sof_out     => sof_out_2           
           );

----------------------
-----   3rd CL   -----
----------------------
-- frame 28x28 
-- 64 input, 128 outs
---------------------

CL3: Identity_connection_group 
  generic map (
           BP             => BP             , 
           TP             => TP             , 
           poll_criteria  => poll_criteria  ,
           mult_sum       => mult_sum       ,
           CL_Kernel_size => Kernel_size_int,
           P_Kernel_size  => Kernel_size_int,
           stridePool     => strideInternal ,
           CL_inputs      => CL_2           , 
           CL_outs        => CL_3           ,
           NumOfGrp       => NumOfGrp       ,
           NumOfLayers    => NumOfLayers    , 
           N              => N              , 
           M              => M              , 
           W              => N              , 
           SR_cl          => SR_cl          , 
           SR_sum         => SR_sum         , 
           in_row         => in_row_3       , 
           in_col         => in_col_3         
           )
  port map   (
           clk         => clk            ,
           rst         => rst            ,
           d_in        => d_out_2        ,
           en_in       => en_out_2       ,
           sof_in      => sof_out_2      ,
           w_unit_n    => w_unit_n_s     ,
           w_in        => w_in_s         ,
           w_num       => w_num_s(4 downto 0),
           w_en        => w_en_s(3)      ,
           w_lin_rdy   => w_lin_rdy_s    , 
           w_CL_select => w_CL_select_s  ,
           w_Grp_select=> w_Grp_select_s ,
           d_out       => d_out_3        ,
           en_out      => en_out_3       ,
           sof_out     => sof_out_3           
           );

----------------------
-----   4th CL   -----
----------------------
-- frame 14x14 
-- 128 input, 256 outs
---------------------
CL4: Identity_connection_group 
  generic map (
           BP             => BP             , 
           TP             => TP             , 
           poll_criteria  => poll_criteria  ,
           mult_sum       => mult_sum       ,
           CL_Kernel_size => Kernel_size_int,
           P_Kernel_size  => Kernel_size_int,
           stridePool     => strideInternal ,
           CL_inputs      => CL_3           , 
           CL_outs        => CL_4           ,
           NumOfGrp       => NumOfGrp       ,
           NumOfLayers    => NumOfLayers    , 
           N              => N              , 
           M              => M              , 
           W              => N              , 
           SR_cl          => SR_cl          , 
           SR_sum         => SR_sum         , 
           in_row         => in_row_4       , 
           in_col         => in_col_4         
           )
  port map   (
           clk         => clk            ,
           rst         => rst            ,
           d_in        => d_out_3        ,
           en_in       => en_out_3       ,
           sof_in      => sof_out_3      ,
           w_unit_n    => w_unit_n_s     ,
           w_in        => w_in_s         ,
           w_num       => w_num_s(4 downto 0),
           w_en        => w_en_s(4)      ,
           w_lin_rdy   => w_lin_rdy_s    , 
           w_CL_select => w_CL_select_s  ,
           w_Grp_select=> w_Grp_select_s ,
           d_out       => d_out_4        ,
           en_out      => en_out_4       ,
           sof_out     => sof_out_4           
           );
----------------------
-----   5th CL   -----
----------------------
-- frame 7x7 
-- 64 input, 128 outs
---------------------
CL5: Identity_connection_group 
  generic map (
           BP             => BP             , 
           TP             => TP             , 
           poll_criteria  => poll_criteria  ,
           mult_sum       => mult_sum       ,
           CL_Kernel_size => Kernel_size_int,
           P_Kernel_size  => Kernel_size_int,
           stridePool     => strideInternal ,
           CL_inputs      => CL_4           , 
           CL_outs        => CL_5           ,
           NumOfGrp       => NumOfGrp       ,
           NumOfLayers    => NumOfLayers    , 
           N              => N              , 
           M              => M              , 
           W              => N              , 
           SR_cl          => SR_cl          , 
           SR_sum         => SR_sum         , 
           in_row         => in_row_5       , 
           in_col         => in_col_5         
           )
  port map   (
           clk         => clk            ,
           rst         => rst            ,
           d_in        => d_out_4        ,
           en_in       => en_out_4       ,
           sof_in      => sof_out_4      ,
           w_unit_n    => w_unit_n_s     ,
           w_in        => w_in_s         ,
           w_num       => w_num_s(4 downto 0),
           w_en        => w_en_s(5)      ,
           w_lin_rdy   => w_lin_rdy_s    , 
           w_CL_select => w_CL_select_s  ,
           w_Grp_select=> w_Grp_select_s ,
           d_out       => d_out_5        ,
           en_out      => en_out_5       ,
           sof_out     => sof_out_5           
           );


AverPool: Pooling_serial
  generic map (
           CL_inputs   => CL_5        ,
           N           => N           ,
           in_row      => in_row_aver ,
           in_col      => in_col_aver
           )
  port map   (
           clk         => clk         ,
           rst         => rst         ,
           d_in        => d_out_5     ,
           en_in       => en_out_5    ,
           sof_in      => sof_out_5   ,
           d_out       => d_out_aver  ,
           en_out      => en_out_aver
           );

FC: Linear_serial
  generic map (
           mult_sum   => mult_sum     ,
           CL_inputs  => CL_5         ,
           CL_outs    => CL_outs      ,
           w_num_max  => FC_w_num_max ,
           N          => N            ,
           M          => M            ,
           SR         => SR_FC        
           )
  port map (
           clk        => clk          ,
           rst        => rst          ,
           d_in       => d_out_aver   ,
           en_in      => en_out_aver  ,
           
           w_in        => w_in_s      ,
           w_en        => w_en_s(5)   ,
           w_pixel_N   => w_pixel_N_s ,
           w_pixel_L   => w_pixel_L_s ,
           w_num       => w_num_s     ,
           w_lin_rdy   => w_lin_rdy_s ,

           d_out       => d_out       ,
           en_out      => en_out
           );

-----------------------------------------------------------------
p_w_init : process(Clk,rst)
begin
if(rst = '1') then
    w_unit_n_s     <= (others => '0');
    w_in_s         <= (others => '0');
    w_num_s        <= (others => '0');
    w_en_s         <= (others => '0'); 
    w_lin_rdy_s    <= '0';
    w_CL_select_s  <= (others => '0');
    w_Grp_select_s <= (others => '0');
    w_pixel_N_s    <= w_pixel_N ;
    w_pixel_L_s    <= w_pixel_L ;
elsif(rising_edge(Clk)) then
    w_unit_n_s     <= w_unit_n    ;
    w_in_s         <= w_in        ;
    w_num_s        <= w_num       ;
    w_lin_rdy_s    <= w_lin_rdy   ;
    w_CL_select_s  <= w_CL_select ;
    w_Grp_select_s <= w_Grp_select;
    w_pixel_N_s    <= w_pixel_N   ;
    w_pixel_L_s    <= w_pixel_L   ;
    if w_en = '1' then
       case w_GoF_select is
          when "000"   => w_en_s <= "00000001";
          when "001"   => w_en_s <= "00000010";
          when "010"   => w_en_s <= "00000100";
          when "011"   => w_en_s <= "00001000";
          when "100"   => w_en_s <= "00010000";
          when "101"   => w_en_s <= "00100000";
          when "110"   => w_en_s <= "01000000";
          when others  => w_en_s <= "10000000";
       end case; 
    else
       w_en_s <= (others => '0');
    end if;
end if; 
end process p_w_init;

end a;