library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;
--library work;
--use work.ConvLayer_types_package.all;

entity ConvLayer_1CE_top is
  generic (
           mem_model     : string := "model_2d"; --"mem_2d" / "mem_dpram4096x36";
           addr_w        : integer := 12; -- 17;  -- 2**addr = sqrt(in_row*in_col) 
           in_row        : integer := 30; -- 100;
           in_col        : integer := 30; -- 100;
           Kernel_size   : integer := 7; -- 3/5/7
           grp_w         : integer := 5; --group_of_weights
           N             : integer := 4  -- input data/weigth width
  	       );
  port    (
           clk         : in  std_logic;
           rst         : in  std_logic;
           sof_in      : in  std_logic; -- start of frame

           init_stage  : in  std_logic;
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
           grp_w         : integer := 5;    --group_of_weights
           addr_w        : integer := 16;
           in_row        : integer := 10;
           in_col        : integer := 10
           );
  port    (
           clk         : in  std_logic;
           rst         : in  std_logic;
           init_stage  : in  std_logic;
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

COMPONENT dpram4096x36
  GENERIC (display_header : boolean;
           verbose        : integer );
  PORT (A1   : IN std_logic_vector((12-1) downto 0) := (others => 'X');
        A2   : IN std_logic_vector((12-1) downto 0) := (others => 'X');
        CEB1 : IN std_logic := 'X';
        CEB2 : IN std_logic := 'X';
        WEB1 : IN std_logic := 'X';
        WEB2 : IN std_logic := 'X';
        OEB1 : IN std_logic := 'X';
        OEB2 : IN std_logic := 'X';
        CSB1 : IN std_logic := 'X';
        CSB2 : IN std_logic := 'X';
        I1   : IN  std_logic_vector((36-1) downto 0) := (others => 'X');
        I2   : IN  std_logic_vector((36-1) downto 0) := (others => 'X');
        O1   : OUT std_logic_vector((36-1) downto 0) := (others => 'X');
        O2   : OUT std_logic_vector((36-1) downto 0) := (others => 'X'));
END COMPONENT;

constant BP             : string := "no";  --"no"/"yes"  -- Bypass
constant TP             : string := "no";  --"no"/"yes"  -- Test pattern output
constant mult_sum       : string := "mult"; --"mult"/"sum"

constant memN           : integer := 11;   -- 7^2*8bits_in_pixel/36bits_in_mem_line
-- memory generics 
constant display_header : boolean := TRUE;     
constant verbose        : integer := 2;

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
signal  data2conv, data2conv1, o2_lsb : std_logic_vector (data_width-1 downto 0);
signal  w        , w1         : std_logic_vector (data_width-1 downto 0); -- weight matrix
signal  en_in        : std_logic;
signal  calc_d_out   : std_logic_vector (N + M +5 downto 0); --(Kernel_size*Kernel_size*M-1 downto 0);
signal  calc_en_out  : std_logic;
signal  calc_sof_out : std_logic;

signal  addr_out    : std_logic_vector (addr_w-1 downto 0);


signal  cntl_en_out  : std_logic;
signal  addr_wr_d : std_logic_vector (addr_w-1 downto 0);

-- memory signals
-- inputs
SIGNAL a1, a1_w     : std_logic_vector((12-1) downto 0) := (others => 'X');
SIGNAL ceb1         : std_logic := 'X';
SIGNAL web1, web1_w : std_logic := 'X';
SIGNAL oeb1         : std_logic := 'X';
SIGNAL csb1         : std_logic := 'X';
SIGNAL i1, i1_w     : std_logic_vector((memN*36-1) downto 0) := (others => 'X');
SIGNAL o1, o1_w     : std_logic_vector((memN*36-1) downto 0) := (others => 'X');
SIGNAL a2, a2_w     : std_logic_vector(     (12-1) downto 0) := (others => 'X');
SIGNAL ceb2         : std_logic := 'X';
SIGNAL web2         : std_logic := 'X';
SIGNAL oeb2         : std_logic := 'X';
SIGNAL csb2         : std_logic := 'X';
-- outputs
SIGNAL i2           : std_logic_vector((memN*36-1) downto 0);
SIGNAL o2, o2_w     : std_logic_vector((memN*36-1) downto 0);

signal out_val_2d   : std_logic_vector (2*N +5 downto 0);

-- result memory instance
SIGNAL a1_r, a2_r       : std_logic_vector((12-1) downto 0) := (others => 'X');
signal out_val_mem      : std_logic_vector (36-1   downto 0);
signal i1_r, o1_r, o2_r : std_logic_vector (36-1   downto 0);
signal web1_r           : std_logic;

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

gen_mem: for i in 0 to memN-1 generate
    u1: dpram4096x36
      GENERIC MAP (display_header,verbose)
      PORT MAP    (a1, a2, ceb1, ceb2, web1, web2, oeb1, oeb2, csb1, csb2,
                   i1(((i+1)*36-1) downto i*36) , 
                   i2(((i+1)*36-1) downto i*36) , 
                   o1(((i+1)*36-1) downto i*36) , 
                   o2(((i+1)*36-1) downto i*36) );
end generate gen_mem;
     
    -- if data_addr'left = 12 (=addr_rd_d'left =memory address width)
    a1      <= data_addr;
    a2      <= addr_rd_d;


    i1(data_val'left downto               0) <= data_val;         -- input data is connencted to memory LSBs
    i1(      i1'left downto data_val'left+1) <= (others => '0');  -- zero padding to memory MSBs
    i2 <= (others => '0');  -- no write operations to 2-nd port 

    ceb1    <= clk;
    web1    <= not data_wr;
    oeb1    <= '0';
    csb1    <= '0';
    ceb2    <= clk;
    web2    <= '1';
    oeb2    <= '0';
    csb2    <= '0';

gen_w: for i in 0 to memN-1 generate
    w_m: dpram4096x36
      GENERIC MAP (display_header,verbose)
      PORT MAP    (a1_w, a2_w, ceb1, ceb2, web1_w, web2, oeb1, oeb2, csb1, csb2,
                   i1_w(((i+1)*36-1) downto i*36) , 
                   i2  (((i+1)*36-1) downto i*36) , 
                   o1_w(((i+1)*36-1) downto i*36) , 
                   o2_w(((i+1)*36-1) downto i*36) );
end generate gen_w;
a1_w   <= w_addr   ;
a2_w   <= addr_rd_w;
web1_w <= not w_wr ;
i1_w(w_val'left downto            0) <= w_val;         -- input data is connencted to memory LSBs
i1_w( i1_w'left downto w_val'left+1) <= (others => '0');  -- zero padding to memory MSBs

   data2conv1 <=    data2conv when mem_model = "model_2d" else
                 o2(data2conv'left downto 0);

  w1  <= w when mem_model = "model_2d" else
         o2_w(data2conv'left downto 0);
-- debug:
o2_lsb <= o2(data2conv'left downto 0);

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
           data2conv    => data2conv1  ,
           en_in        => cntl_en_out ,  -- from control
           sof_in       => sof_in      ,  -- from input
           w            => w1          ,
           d_out        => calc_d_out  ,
           en_out       => calc_en_out ,
           sof_out      => calc_sof_out
           );


control: ConvLayer_cntr 
  generic map(
           grp_w       => grp_w ,
           addr_w      => addr_w,
           in_row      => in_row,
           in_col      => in_col
           )
  port map (
           clk         => clk         ,
           rst         => rst         ,
           init_stage  => init_stage  ,
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
       out_val_2d <= res_mem(conv_integer("0" & addr_out));
    end if;
  end process p_res_mem;


  res_m: dpram4096x36
    GENERIC MAP (display_header,verbose)
    PORT MAP    (a1_r, a2_r, ceb1, ceb2, web1_r, web2, oeb1, oeb2, csb1, csb2,
                 i1_r(36-1 downto 0) , 
                 i2  (36-1 downto 0) , 
                 o1_r(36-1 downto 0) , 
                 o2_r(36-1 downto 0) );

a1_r   <= addr_wr_d;
a2_r   <= addr_out;
web1_r <= not calc_en_out ;
i1_r(calc_d_out'left downto            0) <= calc_d_out;         -- input data is connencted to memory LSBs
i1_r(      i1_r'left downto calc_d_out'left+1) <= (others => '0');  -- zero padding to memory MSBs

   out_val <=    out_val_2d when mem_model = "model_2d" else
                 o2_r(out_val_2d'left downto 0);

  p_res_cnt: process (clk,rst)
  begin
    if rst = '1' then
       addr_out    <= (others => '0');
    elsif rising_edge(clk) then
       --if out_rd = '1' thena2
       if a2 = x"001" then    -- tmp DEBUG use
          addr_out  <= addr_out + 1;
       end if;
    end if;
  end process p_res_cnt;

end a;