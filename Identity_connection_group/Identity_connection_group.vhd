library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;
library work;
use work.ConvLayer_types_package.all;

entity Identity_connection_group is
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
           NumOfGrp      : integer := 4; --1..8 -- number of Filter Groups (Identity_connection)
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
           w_CL_select   : in std_logic_vector(  2 downto 0); -- number of CL layer
           w_Grp_select  : in std_logic_vector(  2 downto 0); -- number of Filter Group

           d_out         : out vec(0 to CL_outs -1)(N-1 downto 0); --vec;
           en_out        : out std_logic;
           sof_out       : out std_logic);
end Identity_connection_group;

architecture Behavioral of Identity_connection_group is

component Identity_connection is
  generic (
           Pooling       : string := "yes";   --"no"/"yes"  -- Bypass
           BP            : string := "no";   --"no"/"yes"  -- Bypass
           TP            : string := "no";   --"no"/"yes"  -- Test pattern output
           poll_criteria : string := "max"; --"max"/"average" -                    average -> TBD!!!! !
           mult_sum      : string := "mult"; --"mult"/"sum";
           CL_Kernel_size: integer :=  3; -- 3/5
           P_Kernel_size : integer :=  5; -- 3/5
           stridePool    : integer :=  2; -- stride of the pooling stage, stride of CL is 1
           CL_inputs     : integer := 2; -- number of inputs features of the first CL
           CL_outs       : integer := 3; -- number of output features of the first CL and all features of the next CLs
           NumOfLayers   : integer := 2; --1..8 -- number of CL layers

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
           clk     : in std_logic;
           rst     : in std_logic;
           d_in    : in vec(0 to CL_inputs -1)(N-1 downto 0); --invec;                                      --std_logic_vector (N-1 downto 0);
           en_in   : in std_logic;
           sof_in  : in std_logic; -- start of frame

           w_unit_n    : in std_logic_vector( 15 downto 0);  -- address weight generators,  8MSB - CL inputs, 8LSB - CL outputs
           w_in        : in std_logic_vector(M-1 downto 0);  -- value
           w_num       : in std_logic_vector(  4 downto 0);  -- number of weight
           w_en        : in std_logic;
           w_CL_select : in std_logic_vector(  2 downto 0); -- number of CL layer

           d_out   : out vec(0 to CL_outs -1)(N-1 downto 0); --vec;
           en_out  : out std_logic;
           sof_out : out std_logic);
end component;

signal  en_in1     : std_logic_vector(NumOfGrp downto 0);  
signal  sof_in1    : std_logic_vector(NumOfGrp downto 0);
signal  d_in1      : vec(0 to NumOfGrp * CL_outs -1)(N-1  downto 0);  

signal  w_unit_n_s : std_logic_vector  ( 15 downto 0);  -- address weight generators,  8MSB - CL inputs, 8LSB - CL outputs
signal  w_in_s     : std_logic_vector(M-1 downto 0);  -- value
signal  w_num_s    : std_logic_vector(  4 downto 0);  -- number of weight
signal  w_en_s     : std_logic_vector(  7 downto 0); 

begin

Grp_first: Identity_connection 
  generic map (
           Pooling       => "no"          ,
           BP            => BP            ,
           TP            => TP            ,
           poll_criteria => poll_criteria ,
           mult_sum      => mult_sum      ,
           CL_Kernel_size=> CL_Kernel_size,
           P_Kernel_size => P_Kernel_size ,
           stridePool    => stridePool    ,
           CL_inputs     => CL_inputs     ,
           CL_outs       => CL_outs       ,
           NumOfLayers   => NumOfLayers   ,
           N             => N             ,
           M             => M             ,
           W             => W             ,
           SR_cl         => SR_cl         ,
           SR_sum        => SR_sum        ,
           in_row        => in_row        ,
           in_col        => in_col
           )
  port map   (
           clk           => clk           ,
           rst           => rst           , 
           d_in          => d_in          ,
           en_in         => en_in         ,
           sof_in        => sof_in        ,
           w_unit_n      => w_unit_n_s    ,
           w_in          => w_in_s        ,
           w_num         => w_num_s       ,
           w_en          => w_en_s(0)     ,
           w_CL_select   => w_CL_select   ,

           d_out         => d_in1(0 to CL_outs-1),
           en_out        => en_in1(0)     ,
           sof_out       => sof_in1(0)    );


gen_grp: for i in 1 to NumOfGrp-2 generate
Grp_i: Identity_connection 
  generic map (
           Pooling       => "no"          ,
           BP            => BP            ,
           TP            => TP            ,
           poll_criteria => poll_criteria ,
           mult_sum      => mult_sum      ,
           CL_Kernel_size=> CL_Kernel_size,
           P_Kernel_size => P_Kernel_size ,
           stridePool    => stridePool    ,
           CL_inputs     => CL_outs       ,
           CL_outs       => CL_outs       ,
           NumOfLayers   => NumOfLayers   ,
           N             => N             ,
           M             => M             ,
           W             => W             ,
           SR_cl         => SR_cl         ,
           SR_sum        => SR_sum        ,
           in_row        => in_row        ,
           in_col        => in_col
           )
  port map   (
           clk           => clk           ,
           rst           => rst           , 
           d_in          => d_in1  ((i-1)*CL_outs to (i)*CL_outs-1), --(i-1)  ,
           en_in         => en_in1 (i-1)  ,
           sof_in        => sof_in1(i-1)  ,
           w_unit_n      => w_unit_n_s    ,
           w_in          => w_in_s        ,
           w_num         => w_num_s       ,
           w_en          => w_en_s(i)     ,
           w_CL_select   => w_CL_select   ,

           d_out         => d_in1  ((i)*CL_outs to (i+1)*CL_outs-1), --(i)    ,
           en_out        => en_in1 (i)    ,
           sof_out       => sof_in1(i)    );
end generate gen_grp;

Grp_last: Identity_connection 
  generic map (
           Pooling       => "no"          ,
           BP            => BP            ,
           TP            => TP            ,
           poll_criteria => poll_criteria ,
           mult_sum      => mult_sum      ,
           CL_Kernel_size=> CL_Kernel_size,
           P_Kernel_size => P_Kernel_size ,
           stridePool    => stridePool    ,
           CL_inputs     => CL_outs       ,
           CL_outs       => CL_outs       ,
           NumOfLayers   => NumOfLayers   ,
           N             => N             ,
           M             => M             ,
           W             => W             ,
           SR_cl         => SR_cl         ,
           SR_sum        => SR_sum        ,
           in_row        => in_row        ,
           in_col        => in_col
           )
  port map   (
           clk           => clk                 ,
           rst           => rst                 , 
           d_in          => d_in1((NumOfGrp-2)*CL_outs to (NumOfGrp-1)*CL_outs-1), --(NumOfGrp-2)   ,
           en_in         => en_in1(NumOfGrp-2)  ,
           sof_in        => sof_in1(NumOfGrp-2) ,
           w_unit_n      => w_unit_n_s          ,
           w_in          => w_in_s              ,
           w_num         => w_num_s             ,
           w_en          => w_en_s(NumOfGrp-1)  ,
           w_CL_select   => w_CL_select         ,

           d_out         => d_in1((NumOfGrp-1)*CL_outs to NumOfGrp*CL_outs-1), --(NumOfGrp-1)     ,
           en_out        => en_in1(NumOfGrp-1)    ,
           sof_out       => sof_in1(NumOfGrp-1)   );

   d_out   <= d_in1  ((NumOfGrp-1)*CL_outs to NumOfGrp*CL_outs-1);
   en_out  <= en_in1 (NumOfGrp-1);
   sof_out <= sof_in1(NumOfGrp-1);



-----------------------------------------------------------------
p_w_init : process(Clk,rst)
begin
if(rst = '1') then
    w_unit_n_s <= (others => '0');
    w_in_s     <= (others => '0');
    w_num_s    <= (others => '0');
    w_en_s     <= (others => '0'); 
elsif(rising_edge(Clk)) then
    w_unit_n_s <= w_unit_n;
    w_in_s     <= w_in    ;
    w_num_s    <= w_num   ;
    if w_en = '1' then
      --grp_en: for loop
       case w_Grp_select is
          when "000"   => w_en_s <= "00000001";
          when "001"   => w_en_s <= "00000010";
          when "010"   => w_en_s <= "00000100";
          when "011"   => w_en_s <= "00001000";
          when "100"   => w_en_s <= "00010000";
          when "101"   => w_en_s <= "00100000";
          when "110"   => w_en_s <= "01000000";
          when others  => w_en_s <= "10000000";
       end case; 
      --end loop grp_en;
    else
       w_en_s <= (others => '0');
    end if;
end if; 
end process p_w_init;


end Behavioral;