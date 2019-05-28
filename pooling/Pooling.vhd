library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;
USE ieee.math_real.log2;
USE ieee.math_real.ceil;

entity Pooling is
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
end Pooling;

architecture a of Pooling is

constant EN_BIT  : integer range 0 to 1 := 0;
constant SOF_BIT : integer range 0 to 1 := 1;

signal d_in1,   d_in2,   d_in3   : std_logic_vector (N-1 downto 0);
--signal d_mid1,  d_mid2,  d_mid3  : std_logic_vector (N-1 downto 0);
--signal d_end1,  d_end2,  d_end3  : std_logic_vector (N-1 downto 0);
signal en_in1,  en_in2,  en_in3  : std_logic_vector(1 downto 0);
--signal en_mid1, en_mid2, en_mid3 : std_logic_vector(1 downto 0);
--signal en_end1, en_end2, en_end3 : std_logic_vector(1 downto 0);

--signal en_in1v,  en_in2v,  en_in3v  : std_logic_vector (N-1 downto 0);
--signal en_mid1v, en_mid2v, en_mid3v : std_logic_vector (N-1 downto 0);
--signal en_end1v, en_end2v, en_end3v : std_logic_vector (N-1 downto 0);

--constant fifo_depth : integer := in_col * N / bpp - 3;
constant fifo_depth : integer := in_col/(P+1);
type t_Memory is array (0 to fifo_depth) of std_logic_vector(N-1 downto 0);
signal mem_line1 : t_Memory;
--signal mem_line2 : t_Memory;




--signal Head : natural range 0 to fifo_depth ;
--signal Tail : natural range 0 to fifo_depth ;

constant row_bits: integer := integer(CEIL(LOG2(Real(in_row))));
constant col_bits: integer := integer(CEIL(LOG2(Real(in_col))));
--constant row_bits: integer := integer(LOG2(Real(in_row)));
--constant col_bits: integer := integer(LOG2(Real(in_col)));

signal row_num           : std_logic_vector (row_bits-1 downto 0);
signal col_num           : std_logic_vector (col_bits-1 downto 0);
signal addr_wr           : std_logic_vector (col_bits   downto P);
signal addr_rd           : std_logic_vector (col_bits   downto P);
signal row_num_d         : std_logic_vector (row_bits-1 downto 0);
signal col_num_d         : std_logic_vector (row_bits-1 downto 0);
--signal row_pol           : natural range 0 to in_row/P;
--signal col_pol           : natural range 0 to in_col/P;

signal read_old_max      : std_logic;
signal write_new_max     : std_logic;
signal max_old           : std_logic_vector (N-1 downto 0);
signal max_new           : std_logic_vector (N-1 downto 0);
signal max_line          : std_logic_vector (N-1 downto 0);
signal max_2mem          : std_logic_vector (N-1 downto 0);

signal p_index           : integer;

begin


-- 3 input samples

  p_insamp1 : process (clk)
  begin
    if rising_edge(clk) then
       if en_in = '1' then
          d_in1  <= d_in  ;
          d_in2  <= d_in1 ;
          d_in3  <= d_in2 ;
       end if;
    end if;
  end process p_insamp1;


  p_insamp2 : process (clk,rst)
  begin
    if rst = '1' then
       en_in1  <= (others => '0');
       en_in2  <= (others => '0');
       en_in3  <= (others => '0');
    elsif rising_edge(clk) then
       en_in1(EN_BIT)  <= en_in;
       en_in1(SOF_BIT) <= sof_in;
       en_in2  <= en_in1;
       en_in3  <= en_in2;
    end if;
  end process p_insamp2;

-- input pixel counter
  p_mem_ctr : process (clk,rst)
  begin
    if rst = '1' then
        row_num      <= (others => '0');
        col_num      <= (others => '0');
        --row_pol      <= 0;
        --col_pol      <= 0;
        read_old_max <= '0';
        row_num_d     <= (others => '0');
        col_num_d     <= (others => '0');
    elsif rising_edge(clk) then
       if en_in = '1' then
          if sof_in = '1' then
             row_num      <= (others => '0');
             col_num      <= (others => '0');
             --row_pol      <= 0;
             --col_pol      <= 0;
             read_old_max <= '0';
          else
             if col_num =  in_col -1 then
                col_num <= (others => '0');
                read_old_max <= '1';
                if row_num = in_row - 1 then
                   row_num   <= (others => '0');
                else
                   row_num <= row_num + 1;
                end if;
             else
                col_num <= col_num + 1;
                read_old_max <= '1';
             end if;
          end if;
       --else
       end if;
    row_num_d <= row_num;
    col_num_d <= col_num;
    end if;
  end process p_mem_ctr;


-- Memory control
-- Stage 1 old max value mem read
-- Stage 2 compare max_old and all data_in -s
-- Stage 3 new max value mem write
  p_mem1 : process (clk)
  begin
    if rising_edge(clk) then
       --if read_old_max = '1' then
          max_old <= mem_line1(conv_integer(addr_rd));     
       --end if;
       if write_new_max = '1' then
          mem_line1(conv_integer(addr_wr)) <= max_2mem; 
       end if;
    end if;
  end process p_mem1;
addr_rd <= '0' & col_num(col_num'left downto P);

  p_mem2 : process (clk,rst)
  begin
    if rst = '1' then
      write_new_max <= '0';
    elsif rising_edge(clk) then
      if (col_num(P-1  downto 0) + 1) = 0 then
        write_new_max <= '1';
        addr_wr <= '0' & col_num(col_num'left downto P);
      else
        write_new_max <= '0';
      end if;
    end if;
  end process p_mem2;


p_index <= conv_integer(col_num(P-1 downto 0));   
-- Data comparison
  p_data_comp : process (clk)
  begin
    if rising_edge(clk) then
      if en_in = '1' then
        if col_num(P-1 downto 0) = 0 then
          max_new <= d_in;
        else
          if d_in > max_new then
            max_new <= d_in;
          end if;
        end if;
      end if;
      --end if;
    end if;
  end process p_data_comp;




  p_data_comp2 : process (max_new, max_old) --, row_num_d,col_num )
  begin
  --   if row_num(P - 1 downto 0) = (2**P - 1) then -- last line in cluster
  --     max_2mem <= (max_2mem'left => '1', others => '0');
      --if max_old > max_new then
      --  d_out <= max_old;
      --else
      --  d_out <= max_new;
      --end if;
      --if (col_num_d(P-1  downto 0) + 1) = 0 then
      --  en_out  <= '1';
      --else
      --  en_out  <= '0';
      --end if;
   --  else
       if max_old > max_new then
         max_line <= max_old;
       else
         max_line <= max_new;
       end if;
   --  end if;
  end process p_data_comp2;

-- reset memory
  p_data_comp3 : process (max_line, row_num_d) --, row_num_d,col_num )
  begin
      if row_num_d(P -1 downto 0)= (2**p-1) then -- last line in cluster
         max_2mem <= (max_2mem'left => '1', others => '0');
       else
         max_2mem <= max_line;
       end if;
   --  end if;
  end process p_data_comp3;

-- Data output 
  p_data_out : process (clk,rst)
  begin
    if rst = '1' then
        en_out  <= '0';
    elsif rising_edge(clk) then
          if row_num_d(P -1 downto 0)= (2**p-1) then
             en_out  <= write_new_max;
             --sof_out <= '0'; --en_ovf(SOF_BIT);
             d_out   <= max_line;
          else
             en_out  <= '0';
          end if;
    end if;
  end process p_data_out;

--en_out  <= en_ovf(EN_BIT);
--sof_out <= '0'; --en_ovf(SOF_BIT);
--d_out   <= c80_ovf (W + SR - 1 downto SR);


end a;