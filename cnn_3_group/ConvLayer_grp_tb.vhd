library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;
--use ieee.math_real.all;
library work;
use work.ConvLayer_types_package.all;


entity ConvLayer_grp_tb is
  generic (
  	       mult_sum      : string := "mult"; --"mult"/"sum";
           Kernel_size   : integer := 3; -- 3/5
           CL_inputs     : integer := 4; -- number of inputs features
           CL_outs       : integer := 2; -- number of output features
           
           N             : integer := 4; --W; -- input data width
           M             : integer := 4;  --W; -- input weight width
      
           SR            : integer := 1; -- data shift right before output (deleted LSBs)
           --bpp           : integer := 8; -- bit per pixel
  	       in_row        : integer := 114;
  	       in_col        : integer := 114
  	       );
end ConvLayer_grp_tb;

architecture a of ConvLayer_grp_tb is

component ConvLayer_grp is
  generic (
           mult_sum      : string := "mult"; --"mult"/"sum";
           Kernel_size   : integer := 5; -- 3/5
           CL_inputs     : integer := 3; -- number of inputs features
           CL_outs       : integer := 4; -- number of output features
           
           --CL_outs      : integer := 3; -- number of CL units
           N             : integer := 8; --W; -- input data width
           M             : integer := 8;  --W; -- input weight width
      
           SR            : integer := 1; -- data shift right before output (deleted LSBs)
           --bpp           : integer := 8; -- bit per pixel
           in_row        : integer := 114;
           in_col        : integer := 114
           );
  port    (
           clk       : in std_logic;
           rst       : in std_logic;
           data2conv : in std_logic_vector (CL_inputs*Kernel_size*Kernel_size*N-1 downto 0);
           en_in     : in std_logic;
           sof_in    : in std_logic; -- start of frame
           w         : in std_logic_vector(CL_inputs*CL_outs*Kernel_size*Kernel_size*M-1 downto 0); -- weight matrix


           d_out     : out vec_out(0 to CL_outs -1); --std_logic_vector (W-1 downto 0); --vec;
           en_out    : out std_logic;
           sof_out   : out std_logic);                  
end component;

constant period    : time := 10 ns;
signal     clk       : std_logic;
signal     rst       : std_logic;
signal     data2conv : std_logic_vector (CL_inputs*Kernel_size*Kernel_size*N-1 downto 0);
signal     en_in     : std_logic;
signal     sof_in    : std_logic; -- start of frame
signal     w         : std_logic_vector(CL_inputs*CL_outs*Kernel_size*Kernel_size*M-1 downto 0); -- weight matrix
signal     d_out     : vec_out(0 to CL_outs -1); --std_logic_vector (W-1 downto 0); --vec;
signal     en_out    : std_logic;
signal     sof_out   : std_logic;   

constant  NKer2 : integer := N*Kernel_size*Kernel_size;

begin


DUT: ConvLayer_grp
  generic map (
           mult_sum    => mult_sum   ,
           Kernel_size => Kernel_size,
           CL_inputs   => CL_inputs  ,
           CL_outs     => CL_outs    ,  
           N           => N          ,  
           M           => M          ,  
           SR          => SR         ,  
           in_row      => in_row     , 
           in_col      => in_col      
           )
  port map (
           clk         => clk        ,
           rst         => rst        ,
           data2conv   => data2conv  ,
           en_in       => en_in      ,
           sof_in      => sof_in     ,
           w           => w          ,
           d_out       => d_out      ,
           en_out      => en_out     , 
           sof_out     => sof_out
           );

process
begin
 en_in <= '0';
  wait until rst = '0';

  wait until rising_edge(clk);
  wait until rising_edge(clk);
  
     for j in 0 to CL_inputs -1 loop
        data2conv (NKer2*(j+1)-1 downto NKer2*j) <= conv_std_logic_vector(j, NKer2);
        for i in 0 to CL_outs -1 loop
           w      (j * NKer2 * CL_outs + i * NKer2 + NKer2 - 1 downto j * NKer2 * CL_outs + i * NKer2) <= conv_std_logic_vector(3*j+i+1, NKer2);
        end loop;
     end loop;


     for j in 0 to 10 -1 loop
        wait until rising_edge(clk);
        for i in 0 to CL_inputs -1 loop
           data2conv (N*(i+1)-1 downto N*i) <= data2conv (N*(i+1)-1 downto N*i)  + 1; en_in <= '1';
        end loop;
     end loop;
       

    wait until rising_edge(clk);          en_in <= '0' ;
    for j in 0 to 2*in_row*in_col-1 loop
        wait until rising_edge(clk);                 
    end loop;

end process;

process        
   begin
     clk <= '0';    
     wait for period/2;
     clk <= '1';
     wait for period/2;
   end process;

rst <= '1', '0' after 10 ns;

end a;