library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;
use ieee.math_real.all;
library work;
use work.ConvLayer_types_package.all;

entity Identity_connection_tb is
    generic (
           Pooling       : string := "yes";   --"no"/"yes" -- Bypass
           BP            : string := "no";   --"no"/"yes"  -- Bypass
           TP            : string := "no";   --"no"/"yes"  -- Test pattern output
           poll_criteria : string := "max"; --"max"/"average" -                    average -> TBD!!!! !
           mult_sum      : string := "mult"; --"mult"/"sum";
           CL_Kernel_size: integer :=  3; -- 3/5
           P_Kernel_size : integer :=  5; -- 3/5
           stridePool    : integer :=  2; -- stride of the pooling stage, stride of CL is 1
           CL_inputs     : integer := 4; -- number of inputs features
           CL_outs       : integer := 4; -- number of output features 
           NumOfLayers   : integer := 3; --1/2/3 -- number of CL layers

           N             : integer := 8; --W; -- input data width
           M             : integer := 8; --W; -- input weight width
           W             : integer := 8; --         output data width      (Note, W+SR <= N+M+4)
           SR_cl         : int_array := (9,9,9,6);  -- CL0, CL1,  CL2, CL3 units.  data shift right before output (deleted LSBs)
           --SR_cl         : integer := 9; -- CL unit.  data shift right before output (deleted LSBs)
           SR_sum        : integer := 0; -- 0/1 -- Sum unit. data shift right before output (deleted LSBs)
           in_row        : integer := 10;
           in_col        : integer := 10
           );
end Identity_connection_tb;

architecture a of Identity_connection_tb is

component Identity_connection is
  generic (
           Pooling       : string := "no";   --"no"/"yes"  -- Bypass
           BP            : string := "no";   --"no"/"yes"  -- Bypass
           TP            : string := "no";   --"no"/"yes"  -- Test pattern output
           poll_criteria : string := "max"; --"max"/"average" -                    average -> TBD!!!! !
           mult_sum      : string := "mult"; --"mult"/"sum";
           CL_Kernel_size: integer :=  5; -- 3/5
           P_Kernel_size : integer :=  5; -- 3/5
           stridePool    : integer :=  2; -- stride of the pooling stage, stride of CL is 1
           CL_inputs     : integer := 3; -- number of inputs features of the first CL
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
           --sol     : in std_logic; -- start of line
           --eof     : in std_logic; -- end of frame

           w_unit_n    : in std_logic_vector( 15 downto 0);  -- address weight generators,  8MSB - CL inputs, 8LSB - CL outputs
           w_in        : in std_logic_vector(M-1 downto 0);  -- value
           w_num       : in std_logic_vector(  4 downto 0);  -- number of weight
           w_en        : in std_logic;
           w_CL_select : in std_logic_vector(  2 downto 0);

           d_out   : out vec(0 to CL_outs -1)(N-1 downto 0); --vec;
           en_out  : out std_logic);
end component;

signal   clk         :  std_logic;
signal   rst         :  std_logic;
signal   d_in        :  vec(0 to CL_inputs -1)(N-1 downto 0); --invec;                                      --std_logic_vector (N-1 downto 0);
signal   en_in       :  std_logic := '0';
signal   sof_in      :  std_logic := '0'; -- start of frame
signal   w_unit_n    :  std_logic_vector( 15 downto 0);  -- address weight generators,  8MSB - CL inputs, 8LSB - CL outputs
signal   w_in        :  std_logic_vector(M-1 downto 0);  -- value
signal   w_num       :  std_logic_vector(  4 downto 0);  -- number of weight
signal   w_en        :  std_logic;
signal   w_CL_select :  std_logic_vector(  2 downto 0);
signal   d_out       :  vec(0 to CL_outs -1)(N-1 downto 0); --vec;
signal   en_out      :  std_logic;

--signal   init_w_done    :  std_logic := '0';
signal   init_w_done_0  :  std_logic := '0';
signal   init_w_done_1  :  std_logic := '0';
--signal   init_w_done_L  :  std_logic := '0';
signal    sign_p        : integer := 1;
signal   CL_num         :  integer := 0;
constant CLs            :  integer := 2;

signal    w_val       : integer := 1;
signal    sign_w      : integer := 1;

signal   FCin_row     : integer := ((in_row - 4)/2 - 4)/2;
signal   FCin_col     : integer := ((in_col - 4)/2 - 4)/2;

begin

process        
   begin

   --- CL0  
       gen_layers: for Num in 0 to NumOfLayers-1 loop
       wait for 10 ns; w_CL_select <= conv_std_logic_vector(Num, w_CL_select'length);
       gen0_inputs: for k in 0 to CL_outs-1 loop
          gen_outputs: for j in 0 to CL_outs-1 loop
             wait for 10 ns;  w_en <= '0'; w_unit_n <= conv_std_logic_vector( j*256+k, w_unit_n'length);
             gen0_w: for i in 1 to 25 loop
             --gen_w: for i in 1 to 9 loop
                 wait for 10 ns; w_en <= '1'; w_num <= conv_std_logic_vector( i, w_num'length); w_in <= conv_std_logic_vector(i+j+k+1, w_in'length); 
             end loop gen0_w;
          end loop gen_outputs;
        end loop gen0_inputs;

        if    Num = 0 then
          init_w_done_0 <= '1';
        elsif Num = 1 then
          init_w_done_1 <= '1';
        end if;
       end loop gen_layers;

     wait for 10 ns; init_w_done_0 <= '1';

   
--   init  
    data_init: for i in 0 to CL_inputs-1 loop
      d_in(i) <= conv_std_logic_vector(i+5, N);
    end loop data_init;
    wait for 10 ns; 

--   streaming  
    data_fr: for k in 0 to 6*in_row loop
    en_in <= '1';
    --sign_p <= (-1) * sign_p;
    data_cl: for j in 0 to in_row -1 loop
      data_ch: for i in 0 to CL_inputs-1 loop
        --d_in(i) <= conv_std_logic_vector((i+j+k+1)*sign_p, N);
        d_in(i) <= d_in(i)(N-2 downto 0) & (d_in(i)(N-1) xor d_in(i)(N-2));
      end loop data_ch;
    wait for 10 ns;
    end loop data_cl;
    en_in <= '0';
    data_0: for i in 0 to CL_inputs-1 loop
      d_in(i) <= conv_std_logic_vector(0, N);
    end loop data_0;
--    wait for 10 ns;
--    wait for 10 ns;
--    wait for 10 ns;
--    wait for 10 ns;
--    wait for 10 ns;
--    wait for 10 ns;
--    wait for 10 ns;
--    wait for 10 ns;
--    wait for 10 ns;
--    wait for 10 ns;
--    wait for 10 ns;
--    wait for 10 ns;
--    wait for 10 ns;
--    wait for 10 ns;
--    wait for 10 ns;
--    wait for 10 ns;
--    wait for 10 ns;
--    wait for 10 ns;
--    wait for 10 ns;
--    wait for 10 ns;
--    wait for 10 ns;
--    wait for 10 ns;
--    wait for 10 ns;
--    wait for 10 ns;
--    wait for 10 ns;
--    wait for 10 ns;
--    wait for 10 ns;
--    wait for 10 ns;
--    wait for 10 ns;
--    wait for 10 ns;
--    wait for 10 ns;
--    wait for 10 ns;
--    wait for 10 ns;
--    wait for 10 ns;
--    wait for 10 ns;
--    wait for 10 ns;
--    wait for 10 ns;
--    wait for 10 ns;
--    wait for 10 ns;
--    wait for 10 ns;
--    wait for 10 ns;
--    wait for 10 ns;
--    wait for 10 ns;
    end loop data_fr;
end process;

process        
   begin
     clk <= '0';    
     wait for 5 ns;
     clk <= '1';
     wait for 5 ns;
   end process;

rst <= '1', '0' after 10 ns;

DUT:  Identity_connection 
  generic map(
           Pooling       => Pooling       ,
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
           w_unit_n      => w_unit_n      ,
           w_in          => w_in          ,
           w_num         => w_num         ,
           w_en          => w_en          ,`
           w_CL_select   => w_CL_select   ,
           d_out         => d_out         ,
           en_out        => en_out
           );

end a;