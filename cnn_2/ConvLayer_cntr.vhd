library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;

entity ConvLayer_cntr is
  generic (
           --Kernel_size   : integer := 7;  -- 3/5/7   
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
end ConvLayer_cntr;

architecture a of ConvLayer_cntr is

constant EN_BIT  : integer range 0 to 1 := 0;
constant SOF_BIT : integer range 0 to 1 := 1;

signal   time_stable     : std_logic_vector (7-1 downto 0);
constant time_stable_max : integer := in_row*in_col;
constant amount_of_pixels: integer := in_row*in_col;

signal conv_run : std_logic;

signal addr_rd_d1   : std_logic_vector (addr_w-1 downto 0);
signal addr_rd_w1   : std_logic_vector (addr_w-1 downto 0);
signal addr_wr_d1   : std_logic_vector (addr_w-1 downto 0);

begin

addr_rd_d <= addr_rd_d1;
addr_rd_w <= addr_rd_w1;
addr_wr_d <= addr_wr_d1;

  p_conv_run: process (clk,rst)
  begin
    if rst = '1' then
       conv_run  <= '0';
       en_out    <= '0';
    elsif rising_edge(clk) then
       if sof_in = '1' then
          conv_run  <= '1';
       --elsif addr_rd_d1 = conv_std_logic_vector(in_row*in_col-1, addr_rd_d1'length)  then
       elsif addr_rd_w1 = conv_std_logic_vector(amount_of_pixels-1, addr_rd_w1'length) and
             addr_rd_d1 = conv_std_logic_vector(amount_of_pixels-1, addr_rd_d1'length) then
          conv_run  <= '0';
       end if;
       en_out <= conv_run;
    end if;
  end process p_conv_run;

  p_rd_addr : process (clk,rst)
  begin
    if rst = '1' then
       addr_rd_d1 <= (others => '0');
    elsif rising_edge(clk) then
       if conv_run = '1' then
          if addr_rd_d1 = conv_std_logic_vector(amount_of_pixels-1, addr_rd_d1'length)  then
             addr_rd_d1 <= (others => '0');
          else
             addr_rd_d1 <= addr_rd_d1 + 1;
          end if;
       else
          addr_rd_d1 <= (others => '0');
       end if;
    end if;
  end process p_rd_addr;


  p_rd_w : process (clk,rst)
  begin
    if rst = '1' then
       addr_rd_w1   <= (others => '0');
       time_stable <= (others => '0');
    elsif rising_edge(clk) then
       if conv_run = '1' then
          if time_stable = conv_std_logic_vector(time_stable_max-1, time_stable'length) then
             time_stable <= (others => '0');
             addr_rd_w1   <= addr_rd_w1 + 1;
          else
             time_stable <= time_stable + 1;
          end if;
       else
          time_stable <= (others => '0');
          addr_rd_w1  <= (others => '0');
       end if;
    end if;
  end process p_rd_w;

  p_wr_data : process (clk,rst)
  begin
    if rst = '1' then
       addr_wr_d1 <= (others => '0');
    elsif rising_edge(clk) then
       if conv_run = '1' then
          addr_wr_d1 <= addr_wr_d1 + 1;
       else
          addr_wr_d1 <= (others => '0');
       end if;
    end if;
  end process p_wr_data;

end a;