library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;
use ieee.math_real.all;
library work;
use work.ConvLayer_types_package.all;

entity LeNet is
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
           SR_fc         : integer := 1; -- FullyConnect data shift right before output (deleted LSBs)
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
           w_CL_select : in std_logic_vector(  1 downto 0);  -- 0 - CL0 , 1 - CL1, 2-FullyConnect

           d_out   : out vec(0 to Linear1_outs -1)(N-1 downto 0); --vec;
           en_out  : out std_logic);
end LeNet;

architecture a of LeNet is
component ConvLayer is
  generic (
           Relu          : string := "yes";  --"no"/"yes"  -- nonlinear Relu function
           BP            : string := "no";   --"no"/"yes"  -- Bypass
           TP            : string := "no";   --"no"/"yes"  -- Test pattern output
  	       mult_sum      : string := "sum"; --"mult"/"sum";
           Kernel_size   : integer := 5; -- 3/5
           zero_padding  : string := "no";  --"no"/"yes"
           CL_inputs     : integer := 1; -- number of inputs features
           CL_outs       : integer := 1; -- number of output features

           --CL_outs      : integer := 3; -- number of CL units
           N             : integer := 8; --W; -- input data width
           M             : integer := 8; --W; -- input weight width
           W             : integer := 8; -- output data width      (Note, W+SR <= N+M+4)
           SR            : integer := 1; -- data shift right before output (deleted LSBs)
           --bpp           : integer := 8; -- bit per pixel
  	       in_row        : integer := 114;
  	       in_col        : integer := 114
  	       );
  port    (
           clk     : in std_logic;
           rst     : in std_logic;
  	       d_in    : in vec(0 to CL_inputs -1)(N-1 downto 0); --invec;                                      --std_logic_vector (N-1 downto 0);
  	       en_in   : in std_logic;
  	       sof_in  : in std_logic; -- start of frame
  	       --sol     : in std_logic; -- start of line
  	       --eof     : in std_logic; -- end of frame

           w_unit_n: in std_logic_vector( 15 downto 0);  -- address weight generators,  8MSB - CL inputs, 8LSB - CL outputs
           w_in    : in std_logic_vector(M-1 downto 0);  -- value
           w_num   : in std_logic_vector(  4 downto 0);  -- number of weight
           w_en    : in std_logic;

           d_out   : out vec(0 to CL_outs -1)(W-1 downto 0);
           en_out  : out std_logic;
           sof_out : out std_logic);
end component;


component Pooling is
  generic (
           N             : integer := 8; -- data width
           P             : integer := 1; -- power of pooling cluster (1 - 2x2, 2 - 4x4, 3 - 8x8, etc)
           in_row        : integer := 256;
           in_col        : integer := 256
           );
  port    (
           clk     : in std_logic;
           rst     : in std_logic;
           d_in    : in std_logic_vector (N-1 downto 0);
           en_in   : in std_logic;
           sof_in  : in std_logic; -- start of frame
           d_out   : out std_logic_vector (N-1 downto 0);
           en_out  : out std_logic;
           sof_out : out std_logic);
end component;

component Linear1 is
  generic (
           Relu          : string := "yes"; --"no"/"yes"  -- nonlinear Relu function
           BP            : string := "no";  --"no"/"yes"  -- Bypass
           TP            : string := "no";  --"no"/"yes"  -- Test pattern output
           mult_sum      : string := "mult"; --"mult"/"sum"
           CL_inputs     : integer := 16;    -- number of inputs features (maximum = 256)
           CL_outs       : integer := 10;    -- number of output features
           N             : integer := 8;    -- input/output data width
           M             : integer := 8;    -- input weight width
           SR            : integer := 2;    -- data shift right before output
           in_row        : integer :=  5;   -- max value in_row * in_col = 256
           in_col        : integer :=  5    -- max value in_row * in_col = 256
           );
  port    (
           clk         : in std_logic;
           rst         : in std_logic;
           d_in        : in vec(0 to CL_inputs-1)(N-1 downto 0);

            en_in       : in std_logic;
            sof_in      : in std_logic; -- start of frame
           
           w_in        : in std_logic_vector( M-1 downto 0);  -- value
           w_en        : in std_logic;
           w_addr      : in std_logic_vector(12-1 downto 0);  -- address of weight table
           w_num       : in std_logic_vector( 8-1 downto 0);  -- number of weight in the line
           w_lin_rdy   : in std_logic;                        -- weigth line ready indication

           d_out       : out vec(0 to CL_outs -1)(N-1 downto 0);
           en_out      : out std_logic);
end component;

signal CL0_d_out   , Pool0_d_out   : vec(0 to CL0_outs -1)(W-1 downto 0);
signal CL1_d_out   , Pool1_d_out   : vec(0 to CL1_outs -1)(W-1 downto 0);
signal CL0_en_out  , CL1_en_out    : std_logic ;
signal CL0_sof_out , CL1_sof_out   : std_logic ;


signal Pool0_en_out  : std_logic_vector (CL0_outs-1 downto 0) ;
signal Pool0_sof_out : std_logic_vector (CL0_outs-1 downto 0) ;
signal Pool1_en_out  : std_logic_vector (CL1_outs-1 downto 0) ;
signal Pool1_sof_out : std_logic_vector (CL1_outs-1 downto 0) ;

constant Pool0in_row  : integer := in_row -4;
constant Pool0in_col  : integer := in_col -4;
constant CL1in_row    : integer := Pool0in_row/2;
constant CL1in_col    : integer := Pool0in_col/2;
constant Pool1in_row  : integer := CL1in_row -4;
constant Pool1in_col  : integer := CL1in_col -4;
constant FCin_row     : integer := Pool1in_row/2;
constant FCin_col     : integer := Pool1in_col/2;

signal  w_unit_n_s  : std_logic_vector( 15 downto 0);  -- address weight generators,  8MSB - CL inputs, 8LSB - CL outputs
signal  w_in_s      : std_logic_vector(M-1 downto 0);  -- value
signal  w_num_s     : std_logic_vector( 8-1 downto 0);  -- number of weight
signal  w_addr_s    : std_logic_vector(12-1 downto 0);  -- address of weight table
signal  w_lin_rdy_s : std_logic;                        -- weigth line ready indication

signal  w0_en       : std_logic;
signal  w1_en       : std_logic;
signal  wFC_en       : std_logic;

begin


w_en_p : process (clk,rst)
begin
   if rst = '1' then
      w_unit_n_s  <= (others => '0');
      w_in_s      <= (others => '0');
      w_num_s     <= (others => '0');
      --w_addr_s    <= (others => '0');
      w_lin_rdy_s <= '0';
      w0_en       <= '0'; w1_en <= '0'; wFC_en <= '0';
   elsif rising_edge(clk) then
      w_in_s      <= w_in ;
      w_num_s     <= w_num;
      w_unit_n_s  <= w_unit_n;
      --w_addr_s    <= w_addr;
      w_lin_rdy_s <= w_lin_rdy;

      case w_CL_select is
         when "00"   => w0_en <= '1'; w1_en <= '0'; wFC_en <= '0';
         when "01"   => w0_en <= '0'; w1_en <= '1'; wFC_en <= '0';
         when "10"   => w0_en <= '0'; w1_en <= '0'; wFC_en <= '1';
         when others => w0_en <= '0'; w1_en <= '0'; wFC_en <= '0';
      end case;
   end if;
end process w_en_p;


ConvLayer0:  ConvLayer 
  generic map(
           Relu          => Relu          , --: string := "yes";  --"no"/"yes"  -- nonlinear Relu function
           BP            => BP            , --: string := "no";   --"no"/"yes"  -- Bypass
           TP            => TP            , --: string := "no";   --"no"/"yes"  -- Test pattern output
           mult_sum      => mult_sum      , --: string := "sum"; --"mult"/"sum";
           Kernel_size   => Kernel_size   , --: integer := 5; -- 3/5
           zero_padding  => zero_padding  , --: string := "yes";  --"no"/"yes"
           CL_inputs     => CL_inputs     , --: integer := 1; -- number of inputs features
           CL_outs       => CL0_outs      , --: integer := 1; -- number of output features

           N             => N             , -- : integer := 8; --W; -- input data width
           M             => M             , -- : integer := 8; --W; -- input weight width
           W             => N             , -- : integer := 8; -- output data width      (Note, W+SR <= N+M+4)
           SR            => SR0           , -- : integer := 1; -- data shift right before output (deleted LSBs)
           in_row        => in_row        , -- : integer := 114;
           in_col        => in_col          -- : integer := 114
           )
  port map   (
           clk           => clk           , --: in std_logic;
           rst           => rst           , --: in std_logic;
           d_in          => d_in          , --: in vec(0 to CL_inputs -1)(N-1 downto 0); --invec;                                      --std_logic_vector (N-1 downto 0);
           en_in         => en_in         , --: in std_logic;
           sof_in        => sof_in        , --: in std_logic; -- start of frame

           w_unit_n     => w_unit_n_s     , --: in std_logic_vector( 15 downto 0);  -- address weight generators,  8MSB - CL inputs, 8LSB - CL outputs
           w_in         => w_in_s           , --: in std_logic_vector(M-1 downto 0);  -- value
           w_num        => w_num_s(4 downto 0)          , --: in std_logic_vector(  4 downto 0);  -- number of weight
           w_en         => w0_en           , --: in std_logic;

           d_out        => CL0_d_out      , --: out vec(0 to CL_outs -1)(W-1 downto 0)
           en_out       => CL0_en_out     , --: out std_logic;
           sof_out      => CL0_sof_out      --: out std_logic);
           );

gen_Pool0: for i in 0 to CL0_outs-1 generate
Pool0: Pooling
  generic map (
           N         => N           , --    : integer := 8; -- data width
           P         => 1           , --    : integer := 1; -- power of pooling cluster (1 - 2x2, 2 - 4x4, 3 - 8x8, etc)
           in_row    => Pool0in_row , --    : integer := 256;
           in_col    => Pool0in_col   --    : integer := 256
           )
  port map   (
           clk       => clk               , -- : in std_logic;
           rst       => rst               , -- : in std_logic;
           d_in      => CL0_d_out(i)         , -- : in std_logic_vector (N-1 downto 0);
           en_in     => CL0_en_out        , -- : in std_logic;
           sof_in    => CL0_sof_out       , -- : in std_logic; -- start of frame
           d_out     => Pool0_d_out(i)    , -- : out std_logic_vector (N-1 downto 0);
           en_out    => Pool0_en_out(i)   , -- : out std_logic;
           sof_out   => Pool0_sof_out(i) ); -- : out std_logic);
end generate gen_Pool0;


ConvLayer1:  ConvLayer
  generic map(
           Relu          => Relu          , --: string := "yes";  --"no"/"yes"  -- nonlinear Relu function
           BP            => BP            , --: string := "no";   --"no"/"yes"  -- Bypass
           TP            => TP            , --: string := "no";   --"no"/"yes"  -- Test pattern output
           mult_sum      => mult_sum      , --: string := "sum"; --"mult"/"sum";
           Kernel_size   => Kernel_size   , --: integer := 5; -- 3/5
           zero_padding  => zero_padding  , --: string := "yes";  --"no"/"yes"
           CL_inputs     => CL0_outs     , --: integer := 1; -- number of inputs features
           CL_outs       => CL1_outs       , --: integer := 1; -- number of output features

           N             => N             , -- : integer := 8; --W; -- input data width
           M             => M             , -- : integer := 8; --W; -- input weight width
           W             => N             , -- : integer := 8; -- output data width      (Note, W+SR <= N+M+4)
           SR            => SR1           , -- : integer := 1; -- data shift right before output (deleted LSBs)
           in_row        => CL1in_row     , -- : integer := 114;
           in_col        => CL1in_col       -- : integer := 114
           )
  port map   (
           clk           => clk             , --: in std_logic;
           rst           => rst             , --: in std_logic;
           d_in          => Pool0_d_out     , --: in vec(0 to CL_inputs -1)(N-1 downto 0); --invec;                                      --std_logic_vector (N-1 downto 0);
           en_in         => Pool0_en_out(0) , --: in std_logic;
           sof_in        => Pool0_sof_out(0), --: in std_logic; -- start of frame

           w_unit_n     => w_unit_n_s       , --: in std_logic_vector( 15 downto 0);  -- address weight generators,  8MSB - CL inputs, 8LSB - CL outputs
           w_in         => w_in_s           , --: in std_logic_vector(M-1 downto 0);  -- value
           w_num        => w_num_s(4 downto 0)       , --: in std_logic_vector(  4 downto 0);  -- number of weight
           w_en         => w1_en            , --: in std_logic;

           d_out        => CL1_d_out      , --: out vec(0 to CL_outs -1)(W-1 downto 0)
           en_out       => CL1_en_out     , --: out std_logic;
           sof_out      => CL1_sof_out      --: out std_logic);
           );


gen_Pool1: for i in 0 to CL1_outs-1 generate
Pool1: Pooling
  generic map (
           N         => N           , --    : integer := 8; -- data width
           P         => 1           , --    : integer := 1; -- power of pooling cluster (1 - 2x2, 2 - 4x4, 3 - 8x8, etc)
           in_row    => Pool1in_row , --    : integer := 256;
           in_col    => Pool1in_col   --    : integer := 256
           )
  port map   (
           clk       => clk               , -- : in std_logic;
           rst       => rst               , -- : in std_logic;
           d_in      => CL1_d_out(i)         , -- : in std_logic_vector (N-1 downto 0);
           en_in     => CL1_en_out        , -- : in std_logic;
           sof_in    => CL1_sof_out       , -- : in std_logic; -- start of frame
           d_out     => Pool1_d_out(i)    , -- : out std_logic_vector (N-1 downto 0);
           en_out    => Pool1_en_out(i)   , -- : out std_logic;
           sof_out   => Pool1_sof_out(i) ); -- : out std_logic);
end generate gen_Pool1;

FullyConnect1: Linear1
  generic map (
           Relu         => Relu      , -- : string := "yes"; --"no"/"yes"  -- nonlinear Relu function
           BP           => BP        , -- : string := "no";  --"no"/"yes"  -- Bypass
           TP           => TP        , -- : string := "no";  --"no"/"yes"  -- Test pattern output
           mult_sum     => mult_sum  , -- : string := "mult"; --"mult"/"sum"
           CL_inputs    => CL1_outs , -- : integer := 16;    -- number of inputs features (maximum = 256)
           CL_outs      => Linear1_outs   , -- : integer := 10;    -- number of output features
           N            => N         , -- : integer := 8;    -- input/output data width
           M            => N         , -- : integer := 8;    -- input weight width
           SR           => SR_fc     , -- : integer := 2;    -- data shift right before output
           in_row       => FCin_row    , -- : integer :=  5;   -- max value in_row * in_col = 256
           in_col       => FCin_col      -- : integer :=  5    -- max value in_row * in_col = 256
           )
  port map  (
           clk         => clk          , --: in std_logic;
           rst         => rst          , --: in std_logic;
           d_in        => Pool1_d_out  , --: in vec(0 to CL_inputs-1)(N-1 downto 0);
           en_in       => Pool1_en_out(0) , --: in std_logic;
           sof_in      => Pool1_sof_out(0), --: in std_logic; -- start of frame
           
           w_in        => w_in_s      , --: in std_logic_vector( M-1 downto 0);  -- value
           w_en        => wFC_en      , --: in std_logic;
           w_addr      => w_unit_n_s(12-1 downto 0)    , --: in std_logic_vector(12-1 downto 0);  -- address of weight table
           w_num       => w_num_s     , --: in std_logic_vector( 8-1 downto 0);  -- number of weight in the line
           w_lin_rdy   => w_lin_rdy_s , --: in std_logic;                        -- weigth line ready indication

           d_out       => d_out     , --: out vec(0 to CL_outs -1)(N-1 downto 0);
           en_out      => en_out    ); --: out std_logic);


end a;