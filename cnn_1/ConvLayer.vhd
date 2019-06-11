library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;
use ieee.math_real.all;
library work;
use work.ConvLayer_types_package.all;

entity ConvLayer is
  generic (
           Relu          : string := "yes";  --"no"/"yes"  -- nonlinear Relu function
           BP            : string := "no";   --"no"/"yes"  -- Bypass
           TP            : string := "no";   --"no"/"yes"  -- Test pattern output
  	       mult_sum      : string := "sum"; --"mult"/"sum";
           --CL_units      : integer := 3; -- number of CL units
           N             : integer := W; -- input data width
           M             : integer := W; -- input weight width
           --W             : integer := 8; -- output data width      (Note, W+SR <= N+M+4)
           SR            : integer := 2; -- data shift right before output
           --bpp           : integer := 8; -- bit per pixel
  	       in_row        : integer := 114;
  	       in_col        : integer := 114
  	       );
  port    (
           clk     : in std_logic;
           rst     : in std_logic;
  	       d_in    : in std_logic_vector (N-1 downto 0);
  	       en_in   : in std_logic;
  	       sof_in  : in std_logic; -- start of frame
  	       --sol     : in std_logic; -- start of line
  	       --eof     : in std_logic; -- end of frame

           w_unit_n: in std_logic_vector(  9 downto 0);
           w_in    : in std_logic_vector(M-1 downto 0);
           w_num   : in std_logic_vector(  3 downto 0);
           w_en    : in std_logic;

           d_out   : out std_logic_vector (W-1 downto 0); --vec;--std_logic_vector (W-1 downto 0);
           en_out  : out std_logic;
           sof_out : out std_logic);
end ConvLayer;

architecture a of ConvLayer is

component ConvLayer_calc is
  generic (
           Relu          : string := "yes"; --"no"/"yes"  -- nonlinear Relu function
           BP            : string := "no";  --"no"/"yes"  -- Bypass
           TP            : string := "no";  --"no"/"yes"  -- Test pattern output
           mult_sum      : string := "sum"; --"mult"/"sum"
           N             : integer := 8; -- input data width
           M             : integer := 8; -- input weight width
           W             : integer := 8; -- output data width      (Note, W+SR <= N+M+4)
           SR            : integer := 2 -- data shift right before output
           );
  port    (
           clk         : in std_logic;
           rst         : in std_logic;
           data2conv1  : in std_logic_vector (N-1 downto 0);
           data2conv2  : in std_logic_vector (N-1 downto 0);
           data2conv3  : in std_logic_vector (N-1 downto 0);
           data2conv4  : in std_logic_vector (N-1 downto 0);
           data2conv5  : in std_logic_vector (N-1 downto 0);
           data2conv6  : in std_logic_vector (N-1 downto 0);
           data2conv7  : in std_logic_vector (N-1 downto 0);
           data2conv8  : in std_logic_vector (N-1 downto 0);
           data2conv9  : in std_logic_vector (N-1 downto 0);
           en_in       : in std_logic;
           sof_in      : in std_logic; -- start of frame
           --sol     : in std_logic; -- start of line
           --eof     : in std_logic; -- end of frame

          w1           : in std_logic_vector(M-1 downto 0); -- weight matrix
          w2           : in std_logic_vector(M-1 downto 0); -- weight matrix
          w3           : in std_logic_vector(M-1 downto 0); -- weight matrix
          w4           : in std_logic_vector(M-1 downto 0); -- weight matrix
          w5           : in std_logic_vector(M-1 downto 0); -- weight matrix
          w6           : in std_logic_vector(M-1 downto 0); -- weight matrix
          w7           : in std_logic_vector(M-1 downto 0); -- weight matrix
          w8           : in std_logic_vector(M-1 downto 0); -- weight matrix
          w9           : in std_logic_vector(M-1 downto 0); -- weight matrix

           d_out       : out std_logic_vector (W-1 downto 0);
           en_out      : out std_logic;
           sof_out     : out std_logic);                     
end component;

component ConvLayer_data_gen is
  generic (
           BP            : string := "no";  --"no"/"yes"  -- Bypass
           mult_sum      : string := "sum";           
           N             : integer := 8; -- input data width
     --      M             : integer := 8; -- input weight width
     --      W             : integer := 8; -- output data width      (Note, W+SR <= N+M+4)
     --      SR            : integer := 2; -- data shift right before output
           --bpp           : integer := 8; -- bit per pixel
           in_row        : integer := 256;
           in_col        : integer := 256
           );
  port    (
           clk         : in std_logic;
           rst         : in std_logic;
           d_in        : in std_logic_vector (N-1 downto 0);
           en_in       : in std_logic;
           sof_in      : in std_logic; -- start of frame
           --sol         : in std_logic; -- start of line
           --eof         : in std_logic; -- end of frame


           data2conv1  : out std_logic_vector (N-1 downto 0);
           data2conv2  : out std_logic_vector (N-1 downto 0);
           data2conv3  : out std_logic_vector (N-1 downto 0);
           data2conv4  : out std_logic_vector (N-1 downto 0);
           data2conv5  : out std_logic_vector (N-1 downto 0);
           data2conv6  : out std_logic_vector (N-1 downto 0);
           data2conv7  : out std_logic_vector (N-1 downto 0);
           data2conv8  : out std_logic_vector (N-1 downto 0);
           data2conv9  : out std_logic_vector (N-1 downto 0);

           en_out      : out std_logic;
           sof_out     : out std_logic);
end component;

component ConvLayer_weight_gen is
  generic (
           BP            : string := "no";  --"no"/"yes"  -- Bypass
           M             : integer := 8 -- input weight width
           );
  port    (
           clk         : in std_logic;
           rst         : in std_logic;

           w_in        : in  std_logic_vector(M-1 downto 0);
           w_num       : in  std_logic_vector(  3 downto 0);
           w_en        : in  std_logic;

          w1           : out std_logic_vector(M-1 downto 0); -- weight matrix
          w2           : out std_logic_vector(M-1 downto 0); -- weight matrix
          w3           : out std_logic_vector(M-1 downto 0); -- weight matrix
          w4           : out std_logic_vector(M-1 downto 0); -- weight matrix
          w5           : out std_logic_vector(M-1 downto 0); -- weight matrix
          w6           : out std_logic_vector(M-1 downto 0); -- weight matrix
          w7           : out std_logic_vector(M-1 downto 0); -- weight matrix
          w8           : out std_logic_vector(M-1 downto 0); -- weight matrix
          w9           : out std_logic_vector(M-1 downto 0)  -- weight matrix
           );
end component;

type t_weight is array (0 to CL_units-1) of std_logic_vector(M-1 downto 0);
signal w1         : t_weight;
signal w2         : t_weight;
signal w3         : t_weight;
signal w4         : t_weight;
signal w5         : t_weight;
signal w6         : t_weight;
signal w7         : t_weight;
signal w8         : t_weight;
signal w9         : t_weight;

--signal w1         : std_logic_vector(M-1 downto 0); -- weight matrix
--signal w2         : std_logic_vector(M-1 downto 0); -- weight matrix
--signal w3         : std_logic_vector(M-1 downto 0); -- weight matrix
--signal w4         : std_logic_vector(M-1 downto 0); -- weight matrix
--signal w5         : std_logic_vector(M-1 downto 0); -- weight matrix
--signal w6         : std_logic_vector(M-1 downto 0); -- weight matrix
--signal w7         : std_logic_vector(M-1 downto 0); -- weight matrix
--signal w8         : std_logic_vector(M-1 downto 0); -- weight matrix
--signal w9         : std_logic_vector(M-1 downto 0); -- weight matrix

signal data2conv1 : std_logic_vector (N-1 downto 0);
signal data2conv2 : std_logic_vector (N-1 downto 0);
signal data2conv3 : std_logic_vector (N-1 downto 0);
signal data2conv4 : std_logic_vector (N-1 downto 0);
signal data2conv5 : std_logic_vector (N-1 downto 0);
signal data2conv6 : std_logic_vector (N-1 downto 0);
signal data2conv7 : std_logic_vector (N-1 downto 0);
signal data2conv8 : std_logic_vector (N-1 downto 0);
signal data2conv9 : std_logic_vector (N-1 downto 0);

signal en_s       : std_logic;
signal sof_s      : std_logic;

signal w_in_s     : std_logic_vector(M-1 downto 0);
signal w_num_s    : std_logic_vector(  3 downto 0);
signal w_unit_en  : std_logic_vector (CL_units-1 downto 0);
signal w_unit_ni  : integer;

signal d_out1     : vec;
signal en_out1    : std_logic_vector (CL_units-1 downto 0);
signal sof_out1   : std_logic_vector (CL_units-1 downto 0);

signal count      : std_logic_vector (9 downto 0);
begin

w_unit_ni <= conv_integer(unsigned('0' & w_unit_n));

w_en_p : process (clk,rst)
--w_en_p : process (w_unit_ni)
begin
   if rst = '1' then
       w_unit_en     <= (others => '0');
   elsif rising_edge(clk) then
      w_in_s   <= w_in ;
      w_num_s  <= w_num;

      For I in 0 to CL_units-1 loop
         if w_en = '1' then
            if w_unit_ni = i then 
               w_unit_en(i) <= '1';
            else 
               w_unit_en(i) <= '0';
            end if;
         end if;
      end loop;
   end if;
end process w_en_p;

CL_d_g: ConvLayer_data_gen 
          generic map (
           BP         =>BP       ,
           mult_sum   =>mult_sum ,           
           N          =>N        , 
          -- M          =>M        ,
          -- W          =>W        ,
          -- SR         =>SR       ,
           in_row     =>in_row   ,
           in_col     =>in_col   ) 
          port map(
           clk        => clk       ,
           rst        => rst       , 
           d_in       => d_in      ,
           en_in      => en_in     ,
           sof_in     => sof_in    ,

           data2conv1 => data2conv1, 
           data2conv2 => data2conv2, 
           data2conv3 => data2conv3, 
           data2conv4 => data2conv4, 
           data2conv5 => data2conv5, 
           data2conv6 => data2conv6, 
           data2conv7 => data2conv7, 
           data2conv8 => data2conv8, 
           data2conv9 => data2conv9, 

           en_out     => en_s      ,
           sof_out    => sof_s
  );

gen_CL: for I in 0 to CL_units-1 generate

CL_w_g:  ConvLayer_weight_gen
  generic map (
           BP         => BP         ,
           M          => M          
           )
  port  map  (
           clk        => clk       ,
           rst        => rst       , 

           w_in       => w_in_s    ,
           w_num      => w_num_s   ,
           w_en       => w_unit_en(i)   ,

           w1         => w1(i)     ,
           w2         => w2(i)     ,
           w3         => w3(i)     ,
           w4         => w4(i)     ,
           w5         => w5(i)     ,
           w6         => w6(i)     ,
           w7         => w7(i)     ,
           w8         => w8(i)     ,
           w9         => w9(i)     
         );

 CL_c:  ConvLayer_calc
  generic map (
           Relu       => Relu       ,
           BP         => BP         ,
           TP         => TP         ,
           mult_sum   => mult_sum   ,
           N          => N          ,
           M          => M          ,
           W          => W          ,
           SR         => SR        
           )
  port  map  (
           clk        => clk        ,
           rst        => rst        ,
           data2conv1 => data2conv1 ,
           data2conv2 => data2conv2 ,
           data2conv3 => data2conv3 ,
           data2conv4 => data2conv4 ,
           data2conv5 => data2conv5 ,
           data2conv6 => data2conv6 ,
           data2conv7 => data2conv7 ,
           data2conv8 => data2conv8 ,
           data2conv9 => data2conv9 ,
           en_in      => en_s       ,
           sof_in     => sof_s      ,

           w1         => w1(i)      ,
           w2         => w2(i)      ,
           w3         => w3(i)      ,
           w4         => w4(i)      ,
           w5         => w5(i)      ,
           w6         => w6(i)      ,
           w7         => w7(i)      ,
           w8         => w8(i)      ,
           w9         => w9(i)      ,

           d_out      => d_out1(i)   ,
           en_out     => en_out1(i) ,
           sof_out    => sof_out1(i)
         );

end generate gen_CL;

en_out  <= en_out1(0);
sof_out <= sof_out1(0);

--process (d_out1)
--  variable TMP : std_logic_vector (W-1 downto 0);
--begin
--  TMP := (others => '0') ;
--  for i in 0 to CL_units -1 loop
--     for j in TMP'low to TMP'high loop
--        TMP(j) := TMP(j) and  d_out1(i)(j);
--     end loop;
--  end loop;
--  d_out <= TMP;
--end process;

  p_out : process (clk,rst)
  begin
    if rst = '1' then
       count     <= (others => '0');
    elsif rising_edge(clk) then
       d_out <= d_out1(conv_integer('0' & count));
       if count = CL_units - 1 then
          count <= (others => '0');
       else
          count <= count + 1;
       end if;
    end if;
  end process p_out;

end a;