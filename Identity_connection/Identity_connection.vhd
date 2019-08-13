library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;
library work;
use work.ConvLayer_types_package.all;

entity Identity_connection is
  generic (
           Relu          : string := "yes";  --"no"/"yes"  -- nonlinear Relu function
           BP            : string := "no";   --"no"/"yes"  -- Bypass
           TP            : string := "no";   --"no"/"yes"  -- Test pattern output
           mult_sum      : string := "mult"; --"mult"/"sum";
           Kernel_size   : integer :=  5; -- 3/5
           CL_inputs     : integer := 32; -- number of inputs features
           NumOfLayers   : integer := 2; --1/2/3/4 -- number of CL layers

           N             : integer := 8; --W; -- input data width
           M             : integer := 8; --W; -- input weight width
           W             : integer := 8; --         output data width      (Note, W+SR <= N+M+4)
           SR_cl         : integer := 1; -- 0/1  -- CL unit.  data shift right before output (deleted LSBs)
           SR_sum        : integer := 1; -- Sum unit. data shift right before output (deleted LSBs)
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
           w_num       : in std_logic_vector(  4 downto 0);  -- number of weight
           w_en        : in std_logic;
           w_lin_rdy   : in std_logic; 
           w_CL_select : in std_logic_vector(  1 downto 0);

           d_out   : out vec(0 to CL_inputs -1)(N-1 downto 0); --vec;
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

constant  zero_padding  : string := "yes";  --"no"/"yes"

signal  w_unit_n_s : std_logic_vector( 15 downto 0);  -- address weight generators,  8MSB - CL inputs, 8LSB - CL outputs
signal  w_in_s     : std_logic_vector(M-1 downto 0);  -- value
signal  w_num_s    : std_logic_vector(  4 downto 0);  -- number of weight
signal  w_en_s     : std_logic_vector(  3 downto 0); 
signal  d_in1      : mat(0 to NumOfLayers)(0 to CL_inputs -1)(N-1  downto 0);    
--signal  d_out1     : mat(0 to NumOfLayers  )(0 to CL_inputs -1)(N + M +4  downto 0);    
signal  en_in1     : std_logic_vector(NumOfLayers downto 0);  
signal  sof_in1    : std_logic_vector(NumOfLayers downto 0);

signal d_out0    : vec(0 to CL_inputs -1)(N-1 downto 0);
signal d_out1    : vec(0 to CL_inputs -1)(N-1 downto 0);
signal short_out : vec(0 to CL_inputs -1)(N-1 downto 0);

signal     en_s  : std_logic;
signal     sof_s : std_logic;
signal     d_s   : vec(0 to CL_inputs -1)(N-1 downto 0);

begin


gen_shortcut: for i in 0 to CL_inputs-1 generate
shortcut: fifo 
generic map (depth      => NumOfLayers*(Kernel_size+1)/2*in_row, --: integer := 16 ;
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


d_in1(0)  <= d_in;
en_in1(0) <= en_in ;
sof_in1(0)<= sof_in;

gen_CL: for i in 0 to NumOfLayers-1 generate
CLi: ConvLayer 
  generic map (
           Relu          => Relu         ,
           BP            => BP           ,
           TP            => TP           ,
           mult_sum      => mult_sum     ,
           Kernel_size   => Kernel_size  ,
           zero_padding  => zero_padding ,
           CL_inputs     => CL_inputs    ,
           CL_outs       => CL_inputs    ,
           N             => N            ,
           M             => M            ,
           W             => W            ,
           SR            => SR_cl        ,
           in_row        => in_row       ,
           in_col        => in_col
           )
  port map   (
           clk           => clk           ,
           rst           => rst           , 
           d_in          => d_in1(i)      ,
           en_in         => en_in1(i)     ,
           sof_in        => sof_in1(i)    ,
           w_unit_n      => w_unit_n_s    ,
           w_in          => w_in_s        ,
           w_num         => w_num_s       ,
           w_en          => w_en_s(i)     ,
           d_out         => d_in1(i+1)    ,
           en_out        => en_in1(i+1)   ,
           sof_out       => sof_in1(i+1));
end generate gen_CL;

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
     d_s   <= d_in1  (NumOfLayers);
  end if; 
end process p_sample_CLs2;

------------- shortcut adder -----------

p_adder : process(Clk,rst)
begin
  if(rst = '1') then
     en_out  <= '0';
     sof_out <= '0';
  elsif(rising_edge(Clk)) then
     en_out  <= en_s ;
     sof_out <= sof_s;
  end if; 
end process p_adder;


p_adder2 : process(Clk,rst)
begin
  if(rising_edge(Clk)) then
     shortcut_adder: for i in 0 to CL_inputs -1 loop
        d_out(i)   <= d_s(i) + short_out(i);
     end loop shortcut_adder;
  end if; 
end process p_adder2;

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
          when "00"   => w_en_s <= "0001";
          when "01"   => w_en_s <= "0010";
          when "10"   => w_en_s <= "0100";
          when others => w_en_s <= "1000";
       end case; 
    else
       w_en_s <= (others => '0');
    end if;
end if; 
end process p_w_init;


end Behavioral;