library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;


entity Pooling_kernel_top is
  generic (
           BP            : string := "no";  --"no"/"yes"  -- Bypass
           TP            : string := "no";  --"no"/"yes"  -- Test pattern output
           mult_sum      : string := "sum";     
           poll_criteria : string := "max"; --"max"/"average" -                    average -> TBD!!!! !
           Kernel_size   : integer := 3; -- 3/5
           zero_padding  : string := "yes";  --"no"/"yes"
           stride        : integer := 1;
           N             : integer := 8; -- input data width
           in_row        : integer := 256;
           in_col        : integer := 256
  	       );
  port    (
           clk         : in std_logic;
           rst         : in std_logic;

           d_in        : in std_logic_vector (N-1 downto 0);
  	       en_in       : in std_logic;
  	       sof_in      : in std_logic; -- start of frame

           d_out       : out std_logic_vector (N -1 downto 0);
           en_out      : out std_logic;
           sof_out     : out std_logic);
end Pooling_kernel_top;

architecture a of Pooling_kernel_top is


component ConvLayer_data_gen is
  generic (
           BP            : string := "no";  --"no"/"yes"  -- Bypass
           mult_sum      : string := "sum";     
           Kernel_size   : integer := 3; -- 3/5
           zero_padding  : string := "yes";  --"no"/"yes"
           stride        : integer := 1;
           N             : integer := 8; -- input data width
           in_row        : integer := 256;
           in_col        : integer := 256
           );
  port    (
           clk         : in std_logic;
           rst         : in std_logic;
           d_in        : in std_logic_vector (N-1 downto 0);
           en_in       : in std_logic;
           sof_in      : in std_logic; -- start of frame

           data2conv1  : out std_logic_vector (N-1 downto 0);
           data2conv2  : out std_logic_vector (N-1 downto 0);
           data2conv3  : out std_logic_vector (N-1 downto 0);
           data2conv4  : out std_logic_vector (N-1 downto 0);
           data2conv5  : out std_logic_vector (N-1 downto 0);
           data2conv6  : out std_logic_vector (N-1 downto 0);
           data2conv7  : out std_logic_vector (N-1 downto 0);
           data2conv8  : out std_logic_vector (N-1 downto 0);
           data2conv9  : out std_logic_vector (N-1 downto 0);
           data2conv10 : out std_logic_vector (N-1 downto 0);
           data2conv11 : out std_logic_vector (N-1 downto 0);
           data2conv12 : out std_logic_vector (N-1 downto 0);
           data2conv13 : out std_logic_vector (N-1 downto 0);
           data2conv14 : out std_logic_vector (N-1 downto 0);
           data2conv15 : out std_logic_vector (N-1 downto 0);
           data2conv16 : out std_logic_vector (N-1 downto 0);
           data2conv17 : out std_logic_vector (N-1 downto 0);
           data2conv18 : out std_logic_vector (N-1 downto 0);
           data2conv19 : out std_logic_vector (N-1 downto 0);
           data2conv20 : out std_logic_vector (N-1 downto 0);
           data2conv21 : out std_logic_vector (N-1 downto 0);
           data2conv22 : out std_logic_vector (N-1 downto 0);
           data2conv23 : out std_logic_vector (N-1 downto 0);
           data2conv24 : out std_logic_vector (N-1 downto 0);
           data2conv25 : out std_logic_vector (N-1 downto 0);
           en_out      : out std_logic;
           sof_out     : out std_logic);
end component;

component Pooling_calc is
  generic (
           BP            : string := "no";  --"no"/"yes"  -- Bypass
           TP            : string := "no";  --"no"/"yes"  -- Test pattern output
           poll_criteria : string := "max"; --"max"/"average" -                    average -> TBD!!!! !
           Kernel_size   : integer := 3; -- 3/5
           N             : integer := 8 -- input data width
           );
  port    (
           clk         : in std_logic;
           rst         : in std_logic;
           data2pool1  : in std_logic_vector (N-1 downto 0);
           data2pool2  : in std_logic_vector (N-1 downto 0);
           data2pool3  : in std_logic_vector (N-1 downto 0);
           data2pool4  : in std_logic_vector (N-1 downto 0);
           data2pool5  : in std_logic_vector (N-1 downto 0);
           data2pool6  : in std_logic_vector (N-1 downto 0);
           data2pool7  : in std_logic_vector (N-1 downto 0);
           data2pool8  : in std_logic_vector (N-1 downto 0);
           data2pool9  : in std_logic_vector (N-1 downto 0);
           data2pool10 : in std_logic_vector (N-1 downto 0);
           data2pool11 : in std_logic_vector (N-1 downto 0);
           data2pool12 : in std_logic_vector (N-1 downto 0);
           data2pool13 : in std_logic_vector (N-1 downto 0);
           data2pool14 : in std_logic_vector (N-1 downto 0);
           data2pool15 : in std_logic_vector (N-1 downto 0);
           data2pool16 : in std_logic_vector (N-1 downto 0);
           data2pool17 : in std_logic_vector (N-1 downto 0);
           data2pool18 : in std_logic_vector (N-1 downto 0);
           data2pool19 : in std_logic_vector (N-1 downto 0);
           data2pool20 : in std_logic_vector (N-1 downto 0);
           data2pool21 : in std_logic_vector (N-1 downto 0);
           data2pool22 : in std_logic_vector (N-1 downto 0);
           data2pool23 : in std_logic_vector (N-1 downto 0);
           data2pool24 : in std_logic_vector (N-1 downto 0);
           data2pool25 : in std_logic_vector (N-1 downto 0);
           en_in       : in std_logic;
           sof_in      : in std_logic; -- start of frame

           d_out       : out std_logic_vector (N -1 downto 0);
           en_out      : out std_logic;
           sof_out     : out std_logic);
end component;

signal   data2pool1  : std_logic_vector (N-1 downto 0);
signal   data2pool2  : std_logic_vector (N-1 downto 0);
signal   data2pool3  : std_logic_vector (N-1 downto 0);
signal   data2pool4  : std_logic_vector (N-1 downto 0);
signal   data2pool5  : std_logic_vector (N-1 downto 0);
signal   data2pool6  : std_logic_vector (N-1 downto 0);
signal   data2pool7  : std_logic_vector (N-1 downto 0);
signal   data2pool8  : std_logic_vector (N-1 downto 0);
signal   data2pool9  : std_logic_vector (N-1 downto 0);
signal   data2pool10 : std_logic_vector (N-1 downto 0);
signal   data2pool11 : std_logic_vector (N-1 downto 0);
signal   data2pool12 : std_logic_vector (N-1 downto 0);
signal   data2pool13 : std_logic_vector (N-1 downto 0);
signal   data2pool14 : std_logic_vector (N-1 downto 0);
signal   data2pool15 : std_logic_vector (N-1 downto 0);
signal   data2pool16 : std_logic_vector (N-1 downto 0);
signal   data2pool17 : std_logic_vector (N-1 downto 0);
signal   data2pool18 : std_logic_vector (N-1 downto 0);
signal   data2pool19 : std_logic_vector (N-1 downto 0);
signal   data2pool20 : std_logic_vector (N-1 downto 0);
signal   data2pool21 : std_logic_vector (N-1 downto 0);
signal   data2pool22 : std_logic_vector (N-1 downto 0);
signal   data2pool23 : std_logic_vector (N-1 downto 0);
signal   data2pool24 : std_logic_vector (N-1 downto 0);
signal   data2pool25 : std_logic_vector (N-1 downto 0);
signal   maxpool_en  : std_logic;
signal   maxpool_sof : std_logic;

begin

gen_no_BP: if BP = "no" and TP = "no" generate 

   pool_max_gen: ConvLayer_data_gen
     generic map (
              BP            => "no"          ,
              mult_sum      => mult_sum      ,
              Kernel_size   => Kernel_size   ,
              zero_padding  => zero_padding  ,
              stride        => stride        ,
              N             => N             ,
              in_row        => in_row        ,
              in_col        => in_col       
              )
     port map (
              clk         => clk        ,
              rst         => rst        ,
              d_in        => d_in       ,
              en_in       => en_in      ,
              sof_in      => sof_in     ,
              data2conv1  => data2pool1 , data2conv2  => data2pool2 , data2conv3  => data2pool3 , data2conv4  => data2pool4 , data2conv5  => data2pool5 , 
              data2conv6  => data2pool6 , data2conv7  => data2pool7 , data2conv8  => data2pool8 , data2conv9  => data2pool9 , data2conv10 => data2pool10, 
              data2conv11 => data2pool11, data2conv12 => data2pool12, data2conv13 => data2pool13, data2conv14 => data2pool14, data2conv15 => data2pool15, 
              data2conv16 => data2pool16, data2conv17 => data2pool17, data2conv18 => data2pool18, data2conv19 => data2pool19, data2conv20 => data2pool20, 
              data2conv21 => data2pool21, data2conv22 => data2pool22, data2conv23 => data2pool23, data2conv24 => data2pool24, data2conv25 => data2pool25, 
              en_out      => maxpool_en ,
              sof_out     => maxpool_sof
              );
   
   
   pool_max_calc: Pooling_calc
     generic map (
              BP            => "no"         ,
              TP            => TP           ,
              poll_criteria => poll_criteria,
              Kernel_size   => Kernel_size  ,
              N             => N              
              )
     port  map  (
              clk           => clk,
              rst           => rst,
              data2pool1    => data2pool1 , data2pool2    => data2pool2 , data2pool3    => data2pool3 , data2pool4    => data2pool4 , data2pool5    => data2pool5 , 
              data2pool6    => data2pool6 , data2pool7    => data2pool7 , data2pool8    => data2pool8 , data2pool9    => data2pool9 , data2pool10   => data2pool10, 
              data2pool11   => data2pool11, data2pool12   => data2pool12, data2pool13   => data2pool13, data2pool14   => data2pool14, data2pool15   => data2pool15, 
              data2pool16   => data2pool16, data2pool17   => data2pool17, data2pool18   => data2pool18, data2pool19   => data2pool19, data2pool20   => data2pool20, 
              data2pool21   => data2pool21, data2pool22   => data2pool22, data2pool23   => data2pool23, data2pool24   => data2pool24, data2pool25   => data2pool25, 
              en_in         => maxpool_en ,
              sof_in        => maxpool_sof,
              d_out         => d_out      ,
              en_out        => en_out     ,
              sof_out       => sof_out
              );

end generate;  -- gen_no_BP, BP = "no" and TP = "no"


gen_TP_out: if BP = "no" and TP = "yes" generate 
  
end generate; -- TP = "yes"

gen_BP: if BP = "yes" generate 


end generate; --  BP = "yes"

end a;