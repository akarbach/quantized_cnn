library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;
library work;
--use work.types_packege.all;
use work.ConvLayer_types_package.all;


entity PCA_pixel_tb is
    generic (
        N              : integer := 4; -- input/output data width
        M              : integer := 4; -- input weight width
        SR             : integer := 1;  -- data shift right before output (deleted LSBs)
        in_row         : integer := 4;
        in_col         : integer := 6
        );
end PCA_pixel_tb;


architecture PCA_pixel_arc of PCA_pixel_tb is

component PCA_pixel is
    generic (
        N              : integer := 8; -- input/output data width
        M              : integer := 8; -- input weight width
        SR             : integer := 1;  -- data shift right before output (deleted LSBs)
        in_row         : integer := 4;
        in_col         : integer := 6
        );
    port (
        rst            : in  std_logic;
        clk            : in  std_logic;
        sof            : in  std_logic;
        eof            : in  std_logic;
        data_in        : in  std_logic_vector(N-1 downto 0);
        data_in_valid  : in  std_logic;
        weight_in      : in  vec(0 to in_row - 1)(M-1 downto 0);
        data_out       : out vec(0 to in_row - 1)(N-1 downto 0);
        data_out_valid : out std_logic
    ) ;
end component;

signal  rst            : std_logic;
signal  clk            : std_logic := '0';
signal  sof            : std_logic;
signal  eof            : std_logic;
signal  data_in        : std_logic_vector(N-1 downto 0);
signal  data_in_valid  : std_logic;
signal  weight_in      : vec(0 to in_row - 1)(M-1 downto 0);
signal  data_out       : vec(0 to in_row - 1)(N-1 downto 0);
signal  data_out_valid : std_logic;

begin



process        
   begin   
     wait for 13 ns; 
     wait for 10 ns; data_in_valid <= '0'; sof <= '0'; eof <= '0';
     gen_w: for i in 0 to in_row - 1 loop
        weight_in(i) <=  conv_std_logic_vector(i+1, M);
     end loop gen_w;
     wait for 30 ns; 
     wait for 10 ns; 

     gen_d: for i in 0 to 30 loop
        wait for 10 ns; data_in_valid <= '1'; data_in <= conv_std_logic_vector( i+1, data_in'length);
     end loop gen_d;

     wait for 10 ns;     data_in_valid <= '0';              
     wait for 10 ns;  
   end process;


    clk_proc: process
    begin
        wait for 5 ns;
        clk <= not clk;
    end process clk_proc;

    rst <= '1', '0' after 10 ns;

dut: PCA_pixel 
    generic map(
        N              => N     ,
        M              => M     ,
        SR             => SR    ,
        in_row         => in_row,
        in_col         => in_col
        )
    port map (
        rst            => rst           ,
        clk            => clk           ,
        sof            => sof           ,
        eof            => eof           ,
        data_in        => data_in       ,
        data_in_valid  => data_in_valid ,
        weight_in      => weight_in     ,
        data_out       => data_out      ,
        data_out_valid => data_out_valid
    ) ;

end  PCA_pixel_arc;