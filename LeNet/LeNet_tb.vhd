library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;
use ieee.math_real.all;
library work;
use work.ConvLayer_types_package.all;

entity LeNet_tb is
    generic (
           Relu          : string := "yes";  --"no"/"yes"  -- nonlinear Relu function
           BP            : string := "no";   --"no"/"yes"  -- Bypass
           TP            : string := "no";   --"no"/"yes"  -- Test pattern output
           mult_sum      : string := "mult"; --"mult"/"sum";
           Kernel_size   : integer :=  5; -- 3/5
           zero_padding  : string := "no";  --"no"/"yes"
           CL_inputs     : integer :=  1; -- 1; -- number of inputs features
           CL0_outs      : integer :=  3; -- 6; -- number of output features CL 1
           CL1_outs      : integer :=  5; --16; -- number of output features CL 2
           Linear1_outs  : integer :=  7; --10; -- number of output features Linear1

           N             : integer := 8; --W; -- input data width
           M             : integer := 8; --W; -- input weight width
           W             : integer := 8; -- output data width      (Note, W+SR <= N+M+4)
           SR0           : integer := 9; -- CL0 data shift right before output (deleted LSBs)
           SR1           : integer := 9; -- CL1 data shift right before output (deleted LSBs)
           SR_fc         : integer := 9; -- FullyConnecy data shift right before output (deleted LSBs)
           in_row        : integer := 20; -- 32;
           in_col        : integer := 20  -- 32
           );
end LeNet_tb;

architecture a of LeNet_tb is

component LeNet is
  generic (
           Relu          : string := "yes";  --"no"/"yes"  -- nonlinear Relu function
           BP            : string := "no";   --"no"/"yes"  -- Bypass
           TP            : string := "no";   --"no"/"yes"  -- Test pattern output
           mult_sum      : string := "mult"; --"mult"/"sum";
           Kernel_size   : integer :=  5; -- 3/5
           zero_padding  : string := "no";  --"no"/"yes"
           CL_inputs     : integer :=  1; -- number of inputs features
           CL0_outs      : integer :=  6; -- number of output features CL 1
           CL1_outs      : integer := 16; -- number of output features CL 2
           Linear1_outs  : integer := 10; -- number of output features Linear1

           N             : integer := 8; --W; -- input data width
           M             : integer := 8; --W; -- input weight width
           W             : integer := 8; -- output data width      (Note, W+SR <= N+M+4)
           SR0           : integer := 1; -- CL0 data shift right before output (deleted LSBs)
           SR1           : integer := 1; -- CL1 data shift right before output (deleted LSBs)
           SR_fc         : integer := 1; -- FullyConnecy data shift right before output (deleted LSBs)
           in_row        : integer := 32;
           in_col        : integer := 32
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
           w_num       : in std_logic_vector(8-1 downto 0);  -- number of weight
           w_en        : in std_logic;
           w_lin_rdy   : in std_logic; 
           w_CL_select : in std_logic_vector(  1 downto 0);

           d_out   : out vec(0 to Linear1_outs -1)(N-1 downto 0); --vec;
           en_out  : out std_logic);
end component;

signal   clk         :  std_logic;
signal   rst         :  std_logic;
signal   d_in        :  vec(0 to CL_inputs -1)(N-1 downto 0); --invec;                                      --std_logic_vector (N-1 downto 0);
signal   en_in       :  std_logic;
signal   sof_in      :  std_logic; -- start of frame
signal   w_unit_n    :  std_logic_vector( 15 downto 0);  -- address weight generators,  8MSB - CL inputs, 8LSB - CL outputs
signal   w_in        :  std_logic_vector(M-1 downto 0);  -- value
signal   w_num       :  std_logic_vector(8-1 downto 0);  -- number of weight
signal   w_en        :  std_logic;
signal   w_lin_rdy   :  std_logic; 
signal   w_CL_select :  std_logic_vector(  1 downto 0);
signal   d_out       :  vec(0 to Linear1_outs -1)(N-1 downto 0); --vec;
signal   en_out      :  std_logic;

signal   init_w_done    :  std_logic := '0';
signal   init_w_done_0  :  std_logic := '0';
signal   init_w_done_1  :  std_logic := '0';
signal   init_w_done_L  :  std_logic := '0';
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
       w_CL_select <= conv_std_logic_vector(0, w_CL_select'length);
       gen0_inputs: for k in 0 to CL_inputs-1 loop
          gen0_outputs: for j in 0 to CL0_outs-1 loop
             wait for 10 ns;  w_en <= '0'; w_unit_n <= conv_std_logic_vector( j*256+k, w_unit_n'length);
             gen0_w: for i in 1 to 25 loop
             --gen_w: for i in 1 to 9 loop
                 wait for 10 ns; w_en <= '1'; w_num <= conv_std_logic_vector( i, w_num'length); w_in <= conv_std_logic_vector(i+j+k+1, w_in'length); 
             end loop gen0_w;
          end loop gen0_outputs;
       end loop gen0_inputs;

     wait for 10 ns; init_w_done_0 <= '1';

   --- CL1
       w_CL_select <= conv_std_logic_vector(1, w_CL_select'length);
       gen1_inputs: for k in 0 to CL0_outs-1 loop
          gen1_outputs: for j in 0 to CL1_outs-1 loop
             wait for 10 ns;  w_en <= '0'; w_unit_n <= conv_std_logic_vector( j*256+k, w_unit_n'length);
             gen1_w: for i in 1 to 25 loop
             --gen_w: for i in 1 to 9 loop
                 wait for 10 ns; w_en <= '1'; w_num <= conv_std_logic_vector( i, w_num'length); w_in <= conv_std_logic_vector(i+j+k+1, w_in'length); 
             end loop gen1_w;
          end loop gen1_outputs;
       end loop gen1_inputs;

     wait for 10 ns; init_w_done_1 <= '1';

     w_unit_n <= (others => '0');
     w_en <= '0'; 
     wait for 10 ns; 
   --- Fully Connect
       w_CL_select <= conv_std_logic_vector(2, w_CL_select'length);
     gen_w1: for j in 0 to FCin_row * FCin_col -1 loop
        wait for 10 ns;                     w_lin_rdy <= '0';
        gen_w: for i in 0 to CL1_outs * Linear1_outs -1 loop
           wait for 10 ns; w_en  <= '1'; w_num <= conv_std_logic_vector( i, w_num'length); w_in<= conv_std_logic_vector(w_val*sign_w, w_in'length);  
                           w_val <= w_val + 1; --sign_w <= (-1)* sign_w;
        end loop gen_w;
        wait for 10 ns; w_en  <= '0';       w_lin_rdy <= '1';  w_unit_n(12 downto 0) <= conv_std_logic_vector( j, 13); -- connected to w_addr in LeNet.vhd
     end loop gen_w1;

     wait for 10 ns; init_w_done_L <= '1';  w_lin_rdy <= '0'; 

     wait for 10 ns; init_w_done <= '1';
    
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
    --data_0: for i in 0 to CL_inputs-1 loop
    --  d_in(i) <= conv_std_logic_vector(0, N);
    --end loop data_0;
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


DUT:  LeNet 
  generic map(
           Relu          => Relu         , 
           BP            => BP           , 
           TP            => TP           , 
           mult_sum      => mult_sum     , 
           Kernel_size   => Kernel_size  , 
           zero_padding  => zero_padding , 
           CL_inputs     => CL_inputs    , 
           CL0_outs      => CL0_outs     , 
           CL1_outs      => CL1_outs     , 
           Linear1_outs  => Linear1_outs , 
           N             => N            , 
           M             => M            , 
           W             => W            , 
           SR0           => SR0          ,
           SR1           => SR1          ,
           SR_fc         => SR_fc        ,
           in_row        => in_row       , 
           in_col        => in_col       
           )
  port map   (
           clk           => clk          ,
           rst           => rst          ,
           d_in          => d_in         ,
           en_in         => en_in        ,
           sof_in        => sof_in       ,
           w_unit_n      => w_unit_n     ,
           w_in          => w_in         ,
           w_num         => w_num        ,
           w_en          => w_en         ,
           w_lin_rdy     => w_lin_rdy    ,
           w_CL_select   => w_CL_select  ,
           d_out         => d_out        ,
           en_out        => en_out
           );



end a;