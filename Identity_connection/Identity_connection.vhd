library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;
library work;
use work.ConvLayer_types_package.all;

entity Identity_connection is
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
end Identity_connection;



architecture Behavioral of Identity_connection is

component ConvLayer is
  generic (
           Relu          : string := "yes";  --"no"/"yes"  -- nonlinear Relu function
           BP            : string := "no";   --"no"/"yes"  -- Bypass
           TP            : string := "no";   --"no"/"yes"  -- Test pattern output
           mult_sum      : string := "sum"; --"mult"/"sum";
           Kernel_size   : integer := 5; -- 3/5
           zero_padding  : string := "yes";  --"no"/"yes"
           stride        : integer := 1;
           CL_inputs     : integer := 1; -- number of inputs features
           CL_outs       : integer := 1; -- number of output features

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

           w_unit_n: in std_logic_vector( 15 downto 0);  -- address weight generators,  8MSB - CL inputs, 8LSB - CL outputs
           w_in    : in std_logic_vector(M-1 downto 0);  -- value
           w_num   : in std_logic_vector(  4 downto 0);  -- number of weight
           w_en    : in std_logic;

           d_out   : out vec(0 to CL_outs -1)(W-1 downto 0); --std_logic_vector (W-1 downto 0); --vec;
           en_out  : out std_logic;
           sof_out : out std_logic);
end component;

component fifo is
generic (depth   : integer := 16 ;
         burst   : integer := 10 ;  -- indication for burst read (Note, depth>burst) 
         Win     : integer := 16 ;
         Wout    : integer := 64 );  --depth of fifo
port (    clk        : in std_logic;
          rst        : in std_logic;
          enr        : in std_logic;   --enable read,should be '0' when not in use.
          enw        : in std_logic;    --enable write,should be '0' when not in use.
          data_in    : in std_logic_vector  (Win -1 downto 0);     --input data
          data_out   : out std_logic_vector(Wout-1 downto 0);    --output data
          burst_r    : out std_logic;   --set as '1' when the queue is ready for burst transaction
          fifo_empty : out std_logic;   --set as '1' when the queue is empty
          fifo_full  : out std_logic     --set as '1' when the queue is full
         );
end component;

component Pooling_kernel_top is
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
end component;

constant  zero_padding  : string := "yes";  --"no"/"yes"
constant  strideCL      : integer := 1;

signal  w_unit_n_s : std_logic_vector( 15 downto 0);  -- address weight generators,  8MSB - CL inputs, 8LSB - CL outputs
signal  w_in_s     : std_logic_vector(M-1 downto 0);  -- value
signal  w_num_s    : std_logic_vector(  4 downto 0);  -- number of weight
signal  w_en_s     : std_logic_vector(  7 downto 0); 
signal  d_in1      : vec(0 to NumOfLayers*CL_outs -1)(N-1  downto 0);    

signal  en_in1     : std_logic_vector(NumOfLayers downto 0);  
signal  sof_in1    : std_logic_vector(NumOfLayers downto 0);

signal d_out0    : vec(0 to CL_outs -1)(N-1 downto 0);
signal d_out1    : vec(0 to CL_outs -1)(N-1 downto 0);
signal short_out : vec(0 to CL_outs -1)(N-1 downto 0);

signal  en_s , en_relu  : std_logic;
signal  sof_s, sof_relu : std_logic;
signal  d_s      : vec(0 to CL_outs -1)(N-1 downto 0);
signal  d_sum    : vec(0 to CL_outs -1)(N   downto 0); 
signal  d_relu   : vec(0 to CL_outs -1)(N   downto 0); 

signal  d_conv   : vec(0 to CL_outs -1)(N-1 downto 0); --vec;
signal  en_conv  : std_logic;
signal  sof_conv : std_logic;

signal   maxpool_en1 : std_logic_vector (CL_outs-1 downto 0);
signal   maxpool_sof1: std_logic_vector (CL_outs-1 downto 0);
begin

residual_yes: if CL_outs = CL_inputs generate
   gen_shortcut: for i in 0 to CL_inputs-1 generate
   shortcut: fifo 
   generic map (depth      => NumOfLayers*(CL_Kernel_size+1)/2*in_row, --: integer := 16 ;
                burst      => 1,                    --: integer := 10 ;  -- indication for burst read (Note, depth>burst) 
                Win        => N,                    --: integer := 16 ;
                Wout       => N)                    --: integer := 64 );  --depth of fifo
   port map(    clk        => clk,                  --: in std_logic;
                rst        => rst,                  --: in std_logic;
                enr        => en_in1 (NumOfLayers), --: in std_logic;   --enable read,should be '0' when not in use.
                enw        => en_in,                --: in std_logic;    --enable write,should be '0' when not in use.
                data_in    => d_in(i),                 --: in std_logic_vector  (Win -1 downto 0);     --input data
                data_out   => short_out(i),            --: out std_logic_vector(Wout-1 downto 0);    --output data
                burst_r    => open,                 --: out std_logic;   --set as '1' when the queue is ready for burst transaction
                fifo_empty => open,                 --: out std_logic;   --set as '1' when the queue is empty
                fifo_full  => open                  --: out std_logic     --set as '1' when the queue is full
            );
   end generate gen_shortcut;
end generate residual_yes;

residual_no: if CL_outs /= CL_inputs generate
   gen_shortcut: for i in 0 to CL_outs-1 generate
      short_out(i) <= (others => '0');
   end generate gen_shortcut;
end generate residual_no;


CL_first: ConvLayer 
  generic map (
           Relu          => "yes"         ,
           BP            => BP            ,
           TP            => TP            ,
           mult_sum      => mult_sum      ,
           Kernel_size   => CL_Kernel_size,
           zero_padding  => zero_padding  ,
           stride        => strideCL      ,
           CL_inputs     => CL_inputs     ,
           CL_outs       => CL_outs       ,
           N             => N             ,
           M             => M             ,
           W             => W             ,
           SR            => SR_cl(0)      ,
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
           d_out         => d_in1(0 to CL_outs-1),
           en_out        => en_in1(1)     ,
           sof_out       => sof_in1(1))   ;


gen_CL: for i in 1 to NumOfLayers-2 generate
   CLi: ConvLayer 
     generic map (
              Relu          => "yes"         ,
              BP            => BP            ,
              TP            => TP            ,
              mult_sum      => mult_sum      ,
              Kernel_size   => CL_Kernel_size,
              zero_padding  => zero_padding  ,
              stride        => strideCL      ,
              CL_inputs     => CL_outs       ,
              CL_outs       => CL_outs       ,
              N             => N             ,
              M             => M             ,
              W             => W             ,
              SR            => SR_cl(i)      ,
              in_row        => in_row        ,
              in_col        => in_col
              )
     port map   (
              clk           => clk           ,
              rst           => rst           , 
              d_in          => d_in1((i-1)*CL_outs to (i)*CL_outs-1),
              en_in         => en_in1(i)     ,
              sof_in        => sof_in1(i)    ,
              w_unit_n      => w_unit_n_s    ,
              w_in          => w_in_s        ,
              w_num         => w_num_s       ,
              w_en          => w_en_s(i)     ,
              d_out         => d_in1((i)*CL_outs to (i+1)*CL_outs-1),
              en_out        => en_in1(i+1)   ,
              sof_out       => sof_in1(i+1));
end generate gen_CL;


CL_last_new: ConvLayer 
  generic map (
           Relu          => "no"                  ,
           BP            => BP                    ,
           TP            => TP                    ,
           mult_sum      => mult_sum              ,
           Kernel_size   => CL_Kernel_size        ,
           zero_padding  => zero_padding          ,
           stride        => strideCL              ,
           CL_inputs     => CL_outs               ,
           CL_outs       => CL_outs               ,
           N             => N                     ,
           M             => M                     ,
           W             => W                     ,
           SR            => SR_cl(NumOfLayers-1)  ,
           in_row        => in_row                ,
           in_col        => in_col
           )
  port map   (
           clk           => clk                   ,
           rst           => rst                   , 
           d_in          => d_in1 ((NumOfLayers-2)*CL_outs to (NumOfLayers-1)*CL_outs-1),
           en_in         => en_in1 (NumOfLayers-1),
           sof_in        => sof_in1(NumOfLayers-1),
           w_unit_n      => w_unit_n_s            ,
           w_in          => w_in_s                ,
           w_num         => w_num_s               ,
           w_en          => w_en_s (NumOfLayers-1),
           d_out         => d_in1((NumOfLayers-1)*CL_outs to NumOfLayers*CL_outs-1),
           en_out        => en_in1(NumOfLayers)   ,
           sof_out       => sof_in1(NumOfLayers)) ;

p_sample_CLs : process(Clk,rst)
begin
  if(rst = '1') then
     en_s  <= '0';
     sof_s <= '0';
  elsif(rising_edge(Clk)) then
     en_s  <= en_in1 (NumOfLayers);
     sof_s <= sof_in1(NumOfLayers);
  end if; 
end process p_sample_CLs;

p_sample_CLs2 : process(Clk,rst)
begin
  if(rising_edge(Clk)) then
     d_s   <= d_in1  ((NumOfLayers-1)*CL_outs to NumOfLayers*CL_outs-1);
  end if; 
end process p_sample_CLs2;

------------- shortcut adder -----------

p_adder : process(Clk,rst)
begin
  if(rst = '1') then
     en_conv  <= '0';
     sof_conv <= '0';
     en_relu  <= '0'; 
     sof_relu <= '0'; 
  elsif(rising_edge(Clk)) then
     en_relu  <= en_s ;
     sof_relu <= sof_s;
     en_conv  <= en_relu ;
     sof_conv <= sof_relu;
  end if; 
end process p_adder;


p_adder2 : process(Clk,rst)
begin
  if(rising_edge(Clk)) then
     shortcut_adder: for i in 0 to CL_outs -1 loop
        d_sum(i)   <= (d_s(i)(N-1) & d_s(i)) + (short_out(i)(N-1) & short_out(i));
     end loop shortcut_adder;
  end if; 
end process p_adder2;

p_relu : process(Clk,rst)
begin
  if(rising_edge(Clk)) then
     shortcut_adder: for i in 0 to CL_outs -1 loop
          relu_bits_for: for j in 0 to N loop
             d_relu(i)(j) <= d_sum(i)(j) and not d_sum(i)(N);    -- if MSB=1 (negative) thwen all bits are 0 
          end loop relu_bits_for;
     end loop shortcut_adder;
  end if; 
end process p_relu;

p_SR_sum : process(d_relu)
begin
   shortcut_adder: for i in 0 to CL_outs -1 loop
      if SR_sum = 1 then
         d_conv(i)   <= d_relu(i)(N-1+SR_sum downto SR_sum);
      elsif d_relu(i)(N) = d_relu(i)(N-1) then             -- SR = 0, check sign
        d_conv(i)   <= d_relu(i)(N-1+SR_sum downto SR_sum); -- sign cutback
      else 
        d_conv(i)(N-1)          <= '0';                    --overflow, d_conv gets max value
        d_conv(i)(N-2 downto 0) <= (others => '1');
      end if;
   end loop shortcut_adder;
end process p_SR_sum;


pooling_no: if Pooling = "no" generate
   d_out   <= d_conv   ;
   en_out  <= en_conv  ;
   sof_out <= sof_conv ;
end generate pooling_no;


pooling_yes: if Pooling = "yes" generate
   pool_gen: for i in 0 to CL_outs -1 generate
      Pool: Pooling_kernel_top 
      generic map (
              BP            => BP            ,
              TP            => TP            ,
              mult_sum      => mult_sum      ,
              poll_criteria => poll_criteria ,
              Kernel_size   => P_Kernel_size ,
              zero_padding  => zero_padding  ,
              stride        => stridePool    ,
              N             => N             ,
              in_row        => in_row        ,
              in_col        => in_col
               )
      port map (
              clk          => clk            ,
              rst          => rst            ,
              d_in         => d_conv(i)      ,
              en_in        => en_conv        ,
              sof_in       => sof_conv       ,
              d_out        => d_out(i)       ,
              en_out       => maxpool_en1(i) ,
              sof_out      => maxpool_sof1(i)
              );
   end generate pool_gen;

   en_out  <= maxpool_en1(0);
   sof_out <= maxpool_sof1(0);
end generate pooling_yes;





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
       case w_CL_select is
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


end Behavioral;