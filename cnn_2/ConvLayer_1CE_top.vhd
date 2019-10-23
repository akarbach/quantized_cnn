library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;
--library work;
--use work.ConvLayer_types_package.all;

entity ConvLayer_1CE_top is
  generic (
           addr_w        : integer := 6;
           in_row        : integer := 10;
           in_col        : integer := 10;
           Kernel_size   : integer := 7; -- 3/5/7
           N             : integer := 4  -- input data/weigth width
  	       );
  port    (
           clk         : in  std_logic;
           rst         : in  std_logic;
           sof_in      : in  std_logic; -- start of frame

           data_wr     : in  std_logic;
           data_val    : in  std_logic_vector (Kernel_size*Kernel_size*N-1 downto 0);
           data_addr   : in  std_logic_vector (                   addr_w-1 downto 0);
           w_wr        : in  std_logic;
           w_val       : in  std_logic_vector (Kernel_size*Kernel_size*N-1 downto 0);
           w_addr      : in  std_logic_vector (                   addr_w-1 downto 0);

           out_rd       : in  std_logic;
           out_val      : out  std_logic_vector (2*N +5 downto 0)

           );
end ConvLayer_1CE_top;

architecture a of ConvLayer_1CE_top is

--constant addr_w        : integer := 6;
--constant in_row        : integer := 10;
--constant in_col        : integer := 10;

component ConvLayer_cntr is
  generic (
           addr_w        : integer := 16;
           in_row        : integer := 10;
           in_col        : integer := 10
           );
  port    (
           clk         : in  std_logic;
           rst         : in  std_logic;
           sof_in      : in  std_logic; -- start of frame
           addr_rd_d   : out std_logic_vector (addr_w-1 downto 0);
           addr_rd_w   : out std_logic_vector (addr_w-1 downto 0);

           en_out      : out std_logic;
           addr_wr_d   : out std_logic_vector (addr_w-1 downto 0)
           );
end component;

component ConvLayer_calc is
  generic (
           BP            : string := "no";  --"no"/"yes"  -- Bypass
           TP            : string := "no";  --"no"/"yes"  -- Test pattern output
           mult_sum      : string := "mult"; --"mult"/"sum"
           Kernel_size   : integer := 7; -- 3/5/7
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


constant BP            : string := "no";  --"no"/"yes"  -- Bypass
constant TP            : string := "no";  --"no"/"yes"  -- Test pattern output
constant mult_sum      : string := "mult"; --"mult"/"sum"

--constant addr_w        : integer := 6;
--constant in_row        : integer := 5;
--constant in_col        : integer := 5;

constant EN_BIT  : integer range 0 to 1 := 0;
constant SOF_BIT : integer range 0 to 1 := 1;

--constant Kernel_size2 : integer := Kernel_size*Kernel_size;
constant M            : integer := N;
constant data_width   : integer := Kernel_size*Kernel_size*N;

type data_mem_type is array ( 0 to 2**addr_w-1 ) of std_logic_vector(data_width-1 downto 0);
signal data_mem  : data_mem_type; 
signal w_mem     : data_mem_type; 


type out_mem_type is array ( 0 to 2**addr_w-1 ) of std_logic_vector(N + M +5 downto 0);
signal res_mem   : out_mem_type; 


signal  addr_rd_d    : std_logic_vector (addr_w-1 downto 0);
signal  addr_rd_w    : std_logic_vector (addr_w-1 downto 0);
signal  data2conv    : std_logic_vector (data_width-1 downto 0);
signal  w            : std_logic_vector (data_width-1 downto 0); -- weight matrix
signal  en_in        : std_logic;
signal  calc_d_out   : std_logic_vector (N + M +5 downto 0); --(Kernel_size*Kernel_size*M-1 downto 0);
signal  calc_en_out  : std_logic;
signal  calc_sof_out : std_logic;

signal  addr_out    : std_logic_vector (addr_w-1 downto 0);


signal  cntl_en_out  : std_logic;
signal  addr_wr_d : std_logic_vector (addr_w-1 downto 0);

begin

-------------------------------------------
-- Two input Cache regions (data and weight)
-------------------------------------------

  p_d_mem: process (clk)
  begin
    if rising_edge(clk) then
       if data_wr = '1' then
          data_mem(conv_integer('0' & data_addr))  <= data_val;
       end if;
       data2conv <= data_mem(conv_integer("0" & addr_rd_d));
    end if;
  end process p_d_mem;

  p_w_mem: process (clk)
  begin
    if rising_edge(clk) then
       if w_wr = '1' then
          w_mem(conv_integer("0" & w_addr))  <= w_val;
       end if;
       w <= w_mem(conv_integer("0" & addr_rd_w));
    end if;
  end process p_w_mem;


CE: ConvLayer_calc 
  generic map(
           BP           => BP         ,
           TP           => TP         ,
           mult_sum     => mult_sum   ,
           Kernel_size  => Kernel_size,
           N            => N          ,
           M            => M
           )
  port map (
           clk          => clk         ,
           rst          => rst         ,
           data2conv    => data2conv   ,
           en_in        => cntl_en_out ,  -- from control
           sof_in       => sof_in      ,  -- from input
           w            => w           ,
           d_out        => calc_d_out  ,
           en_out       => calc_en_out ,
           sof_out      => calc_sof_out
           );


control: ConvLayer_cntr 
  generic map(
           addr_w      => addr_w,
           in_row      => in_row,
           in_col      => in_col
           )
  port map (
           clk         => clk         ,
           rst         => rst         ,
           sof_in      => sof_in      ,
           addr_rd_d   => addr_rd_d   ,
           addr_rd_w   => addr_rd_w   ,
           en_out      => cntl_en_out ,
           addr_wr_d   => addr_wr_d 
           );
-------------------------------------------
-- Ouput Cache region 
-------------------------------------------

  p_res_mem: process (clk)
  begin
    if rising_edge(clk) then
       if calc_en_out = '1' then
          res_mem(conv_integer("0" & addr_wr_d))  <= calc_d_out;
       end if;
       out_val <= res_mem(conv_integer("0" & addr_out));
    end if;
  end process p_res_mem;


  p_res_cnt: process (clk,rst)
  begin
    if rst = '1' then
       addr_out    <= (others => '0');
    elsif rising_edge(clk) then
       if out_rd = '1' then
          addr_out  <= addr_out + 1;
       end if;
    end if;
  end process p_res_cnt;

end a;