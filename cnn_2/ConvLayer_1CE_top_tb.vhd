library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;
--library work;
--use work.ConvLayer_types_package.all;

entity ConvLayer_1CE_top_tb is
  generic (
           addr_w        : integer := 5;
           in_row        : integer := 5;
           in_col        : integer := 5;
           Kernel_size   : integer := 3; -- 3/5/7
           N             : integer := 4  -- input data/weigth width
  	       );
end ConvLayer_1CE_top_tb;

architecture a of ConvLayer_1CE_top_tb is

--constant addr_w        : integer := 6;
--constant in_row        : integer := 5;
--constant in_col        : integer := 5;

component ConvLayer_1CE_top is
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
end component;

signal clk         : std_logic;
signal rst         : std_logic;
signal sof_in      : std_logic; -- start of frame
signal data_wr     : std_logic;
signal data_val    : std_logic_vector (Kernel_size*Kernel_size*N-1 downto 0);
signal data_addr   : std_logic_vector (                   addr_w-1 downto 0);
signal w_wr        : std_logic;
signal w_val       : std_logic_vector (Kernel_size*Kernel_size*N-1 downto 0);
signal w_addr      : std_logic_vector (                   addr_w-1 downto 0);
signal out_rd      : std_logic;
signal out_val     : std_logic_vector (2*N +5 downto 0);




begin

process
begin

  sof_in    <= '0' ; -- start of frame
  data_wr   <= '0' ;
  w_wr      <= '0' ;
  out_rd    <= '0' ;
  wait until rst = '0';

  wait until rising_edge(clk);
  wait until rising_edge(clk);
  data_wr   <= '1' ;
  w_wr      <= '1' ;
     for j in 0 to in_row*in_col-1 loop
        wait until rising_edge(clk);
        data_addr <= conv_std_logic_vector(j, data_addr'length);
        w_addr    <= conv_std_logic_vector(j, w_addr   'length);
        for i in 0 to Kernel_size*Kernel_size-1 loop
           data_val((i+1)*N-1 downto i*N) <= conv_std_logic_vector(i+j+1, N); 
           w_val   ((i+1)*N-1 downto i*N) <= conv_std_logic_vector(i+j+1, N);                   
        end loop;
     end loop;

  wait until rising_edge(clk); sof_in <= '1';
  wait until rising_edge(clk); sof_in <= '0';

    for j in 0 to 2*in_row*in_col-1 loop
        wait until rising_edge(clk);                 
    end loop;

end process;



dut: ConvLayer_1CE_top 
  generic map(
           addr_w       => addr_w     ,
           in_row       => in_row     ,
           in_col       => in_col     ,
           Kernel_size  => Kernel_size,
           N            => N 
           )
  port map (
           clk          => clk      ,
           rst          => rst      ,
           sof_in       => sof_in,
           data_wr      => data_wr,
           data_val     => data_val,
           data_addr    => data_addr,
           w_wr         => w_wr,
           w_val        => w_val,
           w_addr       => w_addr,
           out_rd       => out_rd,
           out_val      => out_val
           );


process        
   begin
     clk <= '0';    
     wait for 5 ns;
     clk <= '1';
     wait for 5 ns;
   end process;

rst <= '1', '0' after 10 ns;


end a;