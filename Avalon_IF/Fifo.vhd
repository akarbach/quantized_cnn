library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;

library ieee;
use ieee.std_logic_1164.all;

entity Fifo is
  generic (
           N             : integer :=  16; -- data width
           A             : integer :=   8  -- bits of address (log2(fifo depth))
           );
  port 
  (
    data_in   : in std_logic_vector(N-1 downto 0);
    fifo_wr   : in std_logic;
    fifo_rd   : in std_logic;
    r_clk     : in std_logic;
    w_clk     : in std_logic;
    r_rst     : in std_logic;
    w_rst     : in std_logic;
    fifo_full : out std_logic;
    Fifo_empty: out std_logic;
    data_out  : out std_logic_vector(N-1 downto 0)
  );
  
end Fifo;

architecture rtl of Fifo is

  -- Build a 2-D array type for the RAM
  subtype word_t is std_logic_vector(N-1 downto 0);
  type memory_t is array(((2**A) - 1) downto 0) of word_t;
  
  -- Declare the RAM signal.
  signal ram : memory_t;

signal  raddr : std_logic_vector(A-1 downto 0);
signal  waddr : std_logic_vector(A-1 downto 0);


begin

  p_data_in : process (w_clk,rst)
  begin
    if rst = '1' then
       waddr <= (others => '0');
    elsif rising_edge(clk) then
      if(fifo_wr = '1') then 
          waddr <= waddr + 1;
      end if;
    end if;
  end process p_data_in;

  process(w_clk)
  begin
    if(rising_edge(w_clk)) then 
      if(fifo_wr = '1') then
        ram(waddr) <= data_in;
      end if;
    end if;
  end process;
  
  process(rclk)
  begin
    if(rising_edge(rclk)) then
      data_out <= ram(raddr);
    end if;
  end process;

end rtl;

entity Fifo is
  generic (
           N             : integer :=  16; -- input data width
           W             : integer := 512; -- output data width
           B             : integer :=   7; -- burst count
           A             : integer :=  32  --address width
  	       );
  port    (
           clk           : in  std_logic;
           rst           : in  std_logic; 
           ddr_clk       : in  std_logic;
           ddr_reset_n   : in  std_logic;

 --      data processing interface
  	       d_in          : in  std_logic_vector (N-1 downto 0);   -- data to convert
  	       en_in         : in  std_logic;
  	       sof_in        : in  std_logic;                         -- start of frame
           eof_in        : in  std_logic;                         -- end of frame

--  DDR interface
          ddr_waitrequest      :  in std_logic;                         --   width = 1,            ddr.waitrequest
          ddr_readdata         :  in std_logic_vector (W-1 downto 0);   -- width = 512,               .readdata
          ddr_readdatavalid    :  in std_logic;                         --   width = 1,               .readdatavalid
          ddr_burstcount       : out std_logic_vector (B-1 downto 0);   --   width = 7,               .burstcount
          ddr_writedata        : out std_logic_vector (W-1 downto 0);   -- width = 512,               .writedata
          ddr_address          : out std_logic_vector (A-1 downto 0);   --  width = 32,               .address
          ddr_write            : out std_logic;                         --   width = 1,               .write
          ddr_read             : out std_logic;                         --   width = 1,               .read
          ddr_byteenable       : out std_logic_vector (W/8-1 downto 0); --  width = 64,               .byteenable
          ddr_debugaccess      : out std_logic;                         --   width = 1,               .debugaccess



           d_out         : out std_logic_vector (W-1 downto 0);
           en_out        : out std_logic;
           eof_out       : out std_logic);                        -- huffman codde output
end Fifo;

architecture a of Fifo is

--constant alphabet_depth : integer := 2**N - 1;
--type t_Huf_code  is array (0 to alphabet_depth) of std_logic_vector(M-1 downto 0);
--type t_Huf_width is array (0 to alphabet_depth) of std_logic_vector(  3 downto 0);
--signal Huf_code_m    : t_Huf_code;
--signal Huf_width_m   : t_Huf_width;
--
--
--signal Huf_coded     : std_logic_vector(M-1 downto 0);
--signal Huf_width     : std_logic_vector(  3 downto 0);
--
--signal pointer       : integer; -- range 0 to (2**(pointer'left+1) - 1);
signal out_buff      : std_logic_vector( W downto 0);
--signal Huf_en        : std_logic;
--signal Huf_eof       : std_logic;
--signal Huf_eof2      : std_logic;
--
--signal Huf_width_i   : integer range 0 to 15;
signal pointer         : integer range 0 to (W - 1);
--
--signal old_tail_M    : integer ;
--signal new_val_L     : integer ;
--signal new_val_M     : integer ;

begin




-- Huffman table initialisation
  init : process (clk)
  begin
    if rising_edge(clk) then
       if init_en = '1' then
           Huf_code_m (conv_integer('0' & alpha_data)) <= alpha_code ;
           Huf_width_m(conv_integer('0' & alpha_data)) <= alpha_width; 
       end if;
    end if;
  end process init;

-- conversion
  conv : process (clk)
  begin
    if rising_edge(clk) then
       if en_in = '1' then
          Huf_coded  <= Huf_code_m (conv_integer('0' & d_in));
          Huf_width  <= Huf_width_m(conv_integer('0' & d_in));
       end if;
    end if;
  end process conv;

-- out control

Huf_width_i <= conv_integer('0' & Huf_width);
--pointer_i   <= conv_integer('0' & pointer  );

old_tail_M <= pointer - W - 1       ;
new_val_L  <= pointer - W           ;
new_val_M  <= new_val_L + Huf_width_i -1;

  out_ctl : process (clk,rst)
  begin
    if rst = '1' then
       pointer     <= 0;
       out_buff    <= (others => '0');
       d_out       <= (others => '0');
       Huf_en      <= '0';
       Huf_eof     <= '0';
       Huf_eof2    <= '0';
       en_out      <= '0';
       eof_out     <= '0';
    elsif rising_edge(clk) then
       Huf_en   <= en_in;
       Huf_eof  <= eof_in;
       Huf_eof2  <= Huf_eof;
       if Huf_eof2 = '0' then
         if Huf_en = '1' then
            if (pointer < W) then
               out_buff(Huf_width_i-1 + pointer downto         pointer) <= Huf_coded(Huf_width_i-1 downto 0);
               pointer  <= pointer + Huf_width_i;
               en_out   <= '0';
            else
               en_out   <= '1';
               pointer  <= pointer - W + Huf_width_i;
               d_out    <= out_buff(W-1 downto 0);
               if (pointer > W) then
                 out_buff(old_tail_M downto          0) <= out_buff(pointer-1       downto W);   -- old 'tail'
               end if;
               out_buff( new_val_M downto  new_val_L) <= Huf_coded(Huf_width_i- 1 downto 0);   -- new value
               out_buff(out_buff'left  downto new_val_M + 1 ) <= (others => '0');              -- MSB <- zero
              end if;
           else
              en_out   <= '0';
         end if;
         eof_out     <= '0';
      else
        eof_out     <= '1';
        if pointer /= 0 then
          d_out <=  out_buff(W-1 downto 0);
          out_buff <= (others => '0');
          en_out   <= '1';
        else
          en_out   <= '0';
        end if;
      end if;
    end if;
  end process out_ctl;

end a;