library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;

entity Huffman is
  generic (
           N             : integer := 4; -- input data width
           --M             : integer := 8; -- max code width
           W             : integer := 10 -- output data width (Note W>=M)
  	       );
  port    (
           clk           : in  std_logic;
           rst           : in  std_logic; 

           init_en       : in  std_logic;                         -- initialising convert table
           alpha_data    : in  std_logic_vector(N-1 downto 0);    
           alpha_code    : in  std_logic_vector(W-1 downto 0);    
           alpha_width   : in  std_logic_vector(  3 downto 0);

  	       d_in          : in  std_logic_vector (N-1 downto 0);   -- data to convert
  	       en_in         : in  std_logic;
  	       sof_in        : in  std_logic;                         -- start of frame
           eof_in        : in  std_logic;                         -- end of frame

           d_out         : out std_logic_vector (W-1 downto 0);
           en_out        : out std_logic;
           eof_out       : out std_logic);                        -- huffman codde output
end Huffman;

architecture a of Huffman is

constant Wmax : integer := 16;
constant alphabet_depth : integer := 2**N - 1;
type t_Huf_code  is array (0 to alphabet_depth) of std_logic_vector(W-1 downto 0);
type t_Huf_width is array (0 to alphabet_depth) of std_logic_vector(  3 downto 0);
signal Huf_code_m    : t_Huf_code;
signal Huf_width_m   : t_Huf_width;


signal Huf_coded     : std_logic_vector(W-1 downto 0);
signal Huf_width     : std_logic_vector(  3 downto 0);

signal pointer       : integer; -- range 0 to (2**(pointer'left+1) - 1);
signal out_buff , out_buff2     : std_logic_vector( 2*W - 1 downto 0);
signal Huf_en        : std_logic;
signal Huf_eof       : std_logic;
signal Huf_eof2      : std_logic;

signal Huf_width_i   : integer range 0 to 15;
signal pointer_i     : integer; -- range 0 to (2**(pointer'left+1) - 1);

signal old_tail_M    : integer ;
signal new_val_L     : integer ;
signal new_val_M     : integer ;

signal shiftreg      : std_logic_vector (3*Wmax  downto 0);
signal head          : integer ;
signal d_out2        : std_logic_vector (W-1 downto 0);
signal en_out2       : std_logic;
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
       shiftreg    <= (others => '0');
       head        <= 0;
       d_out2      <= (others => '0');
       en_out2     <= '0';
    elsif rising_edge(clk) then
       Huf_en   <= en_in;
       Huf_eof  <= eof_in;
       Huf_eof2  <= Huf_eof;
       --if Huf_eof2 = '0' then
          if Huf_en = '1' then
             shiftreg <= shiftreg(shiftreg'left - Huf_width_i  downto 0) & Huf_coded(Huf_width_i-1 downto 0);
             case Huf_width_i is
                when  1 => shiftreg <= shiftreg(shiftreg'left -  1 downto 0) & Huf_coded( 1 - 1 downto 0);
                when  2 => shiftreg <= shiftreg(shiftreg'left -  2 downto 0) & Huf_coded( 2 - 1 downto 0);
                when  3 => shiftreg <= shiftreg(shiftreg'left -  3 downto 0) & Huf_coded( 3 - 1 downto 0);
                when  4 => shiftreg <= shiftreg(shiftreg'left -  4 downto 0) & Huf_coded( 4 - 1 downto 0);
                when  5 => shiftreg <= shiftreg(shiftreg'left -  5 downto 0) & Huf_coded( 5 - 1 downto 0);
                when  6 => shiftreg <= shiftreg(shiftreg'left -  6 downto 0) & Huf_coded( 6 - 1 downto 0);
                when  7 => shiftreg <= shiftreg(shiftreg'left -  7 downto 0) & Huf_coded( 7 - 1 downto 0);
                when  8 => shiftreg <= shiftreg(shiftreg'left -  8 downto 0) & Huf_coded( 8 - 1 downto 0);
                when  9 => shiftreg <= shiftreg(shiftreg'left -  9 downto 0) & Huf_coded( 9 - 1 downto 0);
                when 10 => shiftreg <= shiftreg(shiftreg'left - 10 downto 0) & Huf_coded(10 - 1 downto 0);
                when 11 => shiftreg <= shiftreg(shiftreg'left - 11 downto 0) & Huf_coded(11 - 1 downto 0);
                when 12 => shiftreg <= shiftreg(shiftreg'left - 12 downto 0) & Huf_coded(12 - 1 downto 0);
                when 13 => shiftreg <= shiftreg(shiftreg'left - 13 downto 0) & Huf_coded(13 - 1 downto 0);
                when 14 => shiftreg <= shiftreg(shiftreg'left - 14 downto 0) & Huf_coded(14 - 1 downto 0);
                when 15 => shiftreg <= shiftreg(shiftreg'left - 15 downto 0) & Huf_coded(15 - 1 downto 0);
               -- when 16 => shiftreg <= shiftreg(shiftreg'left - 16 downto 0) & Huf_coded(16 - 1 downto 0);
               when others => null;
             end case;
             if head < 2*W then
                head    <= head + Huf_width_i;
                en_out2 <= '0';
             else
                head    <= head + Huf_width_i - W;
                d_out2  <= shiftreg(head downto head - W + 1);
                case head is
                   when  1 => d_out2  <= shiftreg( 1 downto  1 - W + 1);
                   when  2 => d_out2  <= shiftreg( 2 downto  2 - W + 1);
                   when  3 => d_out2  <= shiftreg( 3 downto  3 - W + 1);
                   when  4 => d_out2  <= shiftreg( 4 downto  4 - W + 1);
                   when  5 => d_out2  <= shiftreg( 5 downto  5 - W + 1);
                   when  6 => d_out2  <= shiftreg( 6 downto  6 - W + 1);
                   when  7 => d_out2  <= shiftreg( 7 downto  7 - W + 1);
                   when  8 => d_out2  <= shiftreg( 8 downto  8 - W + 1);
                   when  9 => d_out2  <= shiftreg( 9 downto  9 - W + 1);
                   when 10 => d_out2  <= shiftreg(10 downto 10 - W + 1);
                   when 11 => d_out2  <= shiftreg(11 downto 11 - W + 1);
                   when 12 => d_out2  <= shiftreg(12 downto 12 - W + 1);
                   when 13 => d_out2  <= shiftreg(13 downto 13 - W + 1);
                   when 14 => d_out2  <= shiftreg(14 downto 14 - W + 1);
                   when 15 => d_out2  <= shiftreg(15 downto 15 - W + 1);
                   when 16 => d_out2  <= shiftreg(16 downto 16 - W + 1);
                   when 17 => d_out2  <= shiftreg(17 downto 17 - W + 1);
                   when 18 => d_out2  <= shiftreg(18 downto 18 - W + 1);
                   when 19 => d_out2  <= shiftreg(19 downto 19 - W + 1);
                   when 20 => d_out2  <= shiftreg(20 downto 20 - W + 1);
                   when 21 => d_out2  <= shiftreg(21 downto 21 - W + 1);
                   when 22 => d_out2  <= shiftreg(22 downto 22 - W + 1);
                   when 23 => d_out2  <= shiftreg(23 downto 23 - W + 1);
                   when 24 => d_out2  <= shiftreg(24 downto 24 - W + 1);
                   when 25 => d_out2  <= shiftreg(25 downto 25 - W + 1);
                   when 26 => d_out2  <= shiftreg(26 downto 26 - W + 1);
                   when 27 => d_out2  <= shiftreg(27 downto 27 - W + 1);
                   when 28 => d_out2  <= shiftreg(28 downto 28 - W + 1);
                   when 29 => d_out2  <= shiftreg(29 downto 29 - W + 1);
                   when 30 => d_out2  <= shiftreg(30 downto 30 - W + 1);
                   when 31 => d_out2  <= shiftreg(31 downto 31 - W + 1);
                   when 32 => d_out2  <= shiftreg(32 downto 32 - W + 1);
                   when 33 => d_out2  <= shiftreg(33 downto 33 - W + 1);
                   when 34 => d_out2  <= shiftreg(34 downto 34 - W + 1);
                   when 35 => d_out2  <= shiftreg(35 downto 35 - W + 1);
                   when 36 => d_out2  <= shiftreg(36 downto 36 - W + 1);
                   when 37 => d_out2  <= shiftreg(37 downto 37 - W + 1);
                   when 38 => d_out2  <= shiftreg(38 downto 38 - W + 1);
                   when 39 => d_out2  <= shiftreg(39 downto 39 - W + 1);
                   when 40 => d_out2  <= shiftreg(40 downto 40 - W + 1);
                   when 41 => d_out2  <= shiftreg(41 downto 41 - W + 1);
                   when 42 => d_out2  <= shiftreg(42 downto 42 - W + 1);
                   when 43 => d_out2  <= shiftreg(43 downto 43 - W + 1);
                   when 44 => d_out2  <= shiftreg(44 downto 44 - W + 1);
                   when 45 => d_out2  <= shiftreg(45 downto 45 - W + 1);
                   when 46 => d_out2  <= shiftreg(46 downto 46 - W + 1);
                   when 47 => d_out2  <= shiftreg(47 downto 47 - W + 1);
                   when 48 => d_out2  <= shiftreg(48 downto 48 - W + 1);
                   when others => null;
                end case;
                en_out2 <= '1';
             end if;
          else
             en_out2 <= '0';
          end if;
       --else
       --   en_out2 <= '0';
       --end if;

--       ---- old version ---
--       if Huf_eof2 = '0' then
--         if Huf_en = '1' then
--            if (pointer < W) then
--               out_buff(Huf_width_i-1 + pointer downto         pointer) <= Huf_coded(Huf_width_i-1 downto 0);
--               pointer  <= pointer + Huf_width_i;
--               en_out   <= '0';
--            else
--               en_out   <= '1';
--               pointer  <= pointer - W + Huf_width_i;
--               d_out    <= out_buff(W-1 downto 0);
--               if (pointer > W) then
--                 out_buff (old_tail_M downto          0) <= out_buff(pointer-1       downto W);   -- old 'tail'
--               end if;
--               out_buff( new_val_M downto  new_val_L) <= Huf_coded(Huf_width_i- 1 downto 0);   -- new value
--               out_buff(out_buff'left  downto new_val_M + 1 ) <= (others => '0');              -- MSB <- zero
--              end if;
--           else
--              en_out   <= '0';
--         end if;
--         eof_out     <= '0';
--       else
--         eof_out     <= '1';
--         if pointer /= 0 then
--           d_out <=  out_buff(W-1 downto 0);
--           out_buff <= (others => '0');
--           en_out   <= '1';
--         else
--           en_out   <= '0';
--         end if;
--      end if;
      end if;
    end process out_ctl;

d_out  <= d_out2 ; 
en_out <= en_out2;

end a;