library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;
use ieee.math_real.all;
library work;
use work.ConvLayer_types_package.all;

entity Pooling_serial is
  generic (
           CL_inputs     : integer := 3; -- number of inputs features
           N             : integer := 8;  -- data width (maxinum 8 bit)
  	       in_row        : integer := 7;
  	       in_col        : integer := 7
  	       );
  port    (
           clk     : in  std_logic;
           rst     : in  std_logic;
           d_in    : in  vec(0 to CL_inputs -1)(N-1 downto 0);
  	       en_in   : in  std_logic;
  	       sof_in  : in  std_logic; -- start of frame
           d_out   : out vec(0 to CL_inputs -1)(N-1 downto 0);
           en_out  : out std_logic);
end Pooling_serial;

architecture a of Pooling_serial is

constant EN_BIT  : integer range 0 to 1 := 0;
constant SOF_BIT : integer range 0 to 1 := 1;
constant Np7     : integer range 0 to 31 := N+7;
constant pix_num : integer range 0 to 65536 := in_row * in_col;
--constant max_mult: integer range 0 to 16 ; -- maximum multiply bits
constant max_div : integer range 0 to 15 :=8  ; -- maximum dividend bits
signal dividend :  std_logic_vector(max_div-1 downto 0);

component res_div_pip is
  generic (N: INTEGER:= 16; -- N >= M
           M: INTEGER:= 8);
  port( A     : in  std_logic_vector(N-1 downto 0);
        B     : in  std_logic_vector(M-1 downto 0);
        clock : in  std_logic;
        resetn   : in  std_logic;
        E     : in  std_logic;
        Q     : out std_logic_vector (N-1 downto 0);
        R     : out std_logic_vector(M-1 downto 0);
        v     : out std_logic);
end component;

-->> bin2dec('10100111001011')/2^19 ans =  0.0204 (1/49)


signal d_in_s : vec(0 to CL_inputs -1)(N-1 downto 0);
signal d_ext  : vec(0 to CL_inputs -1)(Np7-1 downto 0);
signal acc    : vec(0 to CL_inputs -1)(Np7-1 downto 0);
signal acc1   : vec(0 to CL_inputs -1)(Np7-1 downto 0);
signal div_out: vec(0 to CL_inputs -1)(Np7-1 downto 0);


signal resetn    : std_logic;
signal en_in_d   : std_logic;
signal en_shift  : std_logic_vector (15 downto 0);
signal div_start : std_logic;

--signal shift00 : vec(0 to CL_inputs -1)(Np7-1 + max_mult downto 0);
--signal shift01 : vec(0 to CL_inputs -1)(Np7-1 + max_mult downto 0);
--signal shift02 : vec(0 to CL_inputs -1)(Np7-1 + max_mult downto 0);
--signal shift03 : vec(0 to CL_inputs -1)(Np7-1 + max_mult downto 0);
--signal shift04 : vec(0 to CL_inputs -1)(Np7-1 + max_mult downto 0);
--signal shift05 : vec(0 to CL_inputs -1)(Np7-1 + max_mult downto 0);
--signal shift06 : vec(0 to CL_inputs -1)(Np7-1 + max_mult downto 0);
--signal shift07 : vec(0 to CL_inputs -1)(Np7-1 + max_mult downto 0);
--signal shift08 : vec(0 to CL_inputs -1)(Np7-1 + max_mult downto 0);
--signal shift09 : vec(0 to CL_inputs -1)(Np7-1 + max_mult downto 0);
--signal shift10 : vec(0 to CL_inputs -1)(Np7-1 + max_mult downto 0);
--signal shift11 : vec(0 to CL_inputs -1)(Np7-1 + max_mult downto 0);
--signal shift12 : vec(0 to CL_inputs -1)(Np7-1 + max_mult downto 0);
--signal shift13 : vec(0 to CL_inputs -1)(Np7-1 + max_mult downto 0);
--signal shift14 : vec(0 to CL_inputs -1)(Np7-1 + max_mult downto 0);
--signal shift15 : vec(0 to CL_inputs -1)(Np7-1 + max_mult downto 0);


---constant fifo_depth : integer := in_col/(P+1);
---type t_Memory is array (0 to fifo_depth) of std_logic_vector(N-1 downto 0);
---signal mem_line1 : t_Memory;
-----signal mem_line2 : t_Memory;




--signal Head : natural range 0 to fifo_depth ;
--signal Tail : natural range 0 to fifo_depth ;

constant row_bits: integer := integer(CEIL(LOG2(Real(in_row))));
constant col_bits: integer := integer(CEIL(LOG2(Real(in_col))));
--constant row_bits: integer := integer(LOG2(Real(in_row)));
--constant col_bits: integer := integer(LOG2(Real(in_col)));

signal row_num, row_num_d, row_num_d2  : std_logic_vector (row_bits-1 downto 0);
signal col_num, col_num_d, col_num_d2  : std_logic_vector (col_bits-1 downto 0);
signal addr_wr                         : std_logic_vector (col_bits   downto 0); --P);
signal addr_rd                         : std_logic_vector (col_bits   downto 0); --P);

-----signal row_pol           : natural range 0 to in_row/P;
-----signal col_pol           : natural range 0 to in_col/P;
---
---signal read_old_max      : std_logic;
---signal write_new_max     : std_logic;
---signal write_new_max_d   : std_logic;
---signal max_old           : std_logic_vector (N-1 downto 0);
---signal max_new           : std_logic_vector (N-1 downto 0);
---signal max_line          : std_logic_vector (N-1 downto 0);
---signal max_2mem          : std_logic_vector (N-1 downto 0);
---signal max_2mem_d        : std_logic_vector (N-1 downto 0);
---
---signal col_num_cluster   : std_logic_vector (P-1 downto 0);
-----signal p_index           : integer;

begin

-- input pixel counter
  p_sample : process (clk)
  begin
    if rising_edge(clk) then
       if en_in = '1' then
          d_in_s <= d_in;
       end if;
    end if;
  end process p_sample;

-- input pixel counter
  p_mem_ctr : process (clk,rst)
  begin
    if rst = '1' then
        row_num      <= (others => '0');
        col_num      <= (others => '0');
        --row_pol      <= 0;
        --col_pol      <= 0;
        --read_old_max <= '0';
        row_num_d     <= (others => '0');
        col_num_d     <= (others => '0');
        row_num_d2    <= (others => '0');
        col_num_d2    <= (others => '0');
    elsif rising_edge(clk) then
       if en_in = '1' then
          if sof_in = '1' then
             row_num      <= (others => '0');
             col_num      <= (others => '0');
             --row_pol      <= 0;
             --col_pol      <= 0;
            -- read_old_max <= '0';
          else
             if col_num =  in_col -1 then
                col_num <= (others => '0');
               -- read_old_max <= '1';
                if row_num = in_row - 1 then
                   row_num   <= (others => '0');
                else
                   row_num <= row_num + 1;
                end if;
             else
                col_num <= col_num + 1;
             --   read_old_max <= '1';
             end if;
          end if;
       --else
       end if;
    row_num_d  <= row_num  ;
    col_num_d  <= col_num  ;
    row_num_d2 <= row_num_d;
    col_num_d2 <= col_num_d;
    end if;
  end process p_mem_ctr;

                        -- sign extention
   gen_exten:   for i in 0 to CL_inputs -1 generate
      d_ext(i)(N-1 downto 0) <=            d_in_s(i)      ;
      d_ext(i)(Np7-1 downto N) <= (others => d_in_s(i)(N-1)); 
   end generate gen_exten;


-- Frame accumulator
  p_acc : process (clk,rst)
  begin
    if rst = '1' then
      acc       <= (others => (others => '0'));
      acc1      <= (others => (others => '0'));
      en_in_d   <= '0';
      en_shift  <= (others => '0');
      div_start <= '0';
    elsif rising_edge(clk) then
       en_in_d  <= en_in;
       en_shift <= en_shift(en_shift'left -1 downto 0) & div_start;
       if en_in_d = '1' then
          --if (row_num = (in_row-1)) and (col_num = (in_col-1)) then
          if (row_num_d = (in_row-1)) and (col_num_d = (in_col-1)) then
             acc    <= (others => (others => '0'));
             d_last_ch: for i in 0 to CL_inputs-1 loop
                acc1(i)   <= acc(i) + d_ext(i);
             end loop d_last_ch;
             div_start <= '1';
          else
             data_ch: for i in 0 to CL_inputs-1 loop
                acc(i) <= acc(i) + d_ext(i); 
             end loop data_ch;
             div_start <= '0';
          end if;
       else
          div_start <= '0';
       end if;
    end if;
  end process p_acc;


dividend <= conv_std_logic_vector(in_row * in_col, dividend'length);
resetn <= not rst;

gen_mul_bits :  for i in 0 to CL_inputs -1 generate
div: res_div_pip
  generic map (N     => Np7     , --: INTEGER:= 16; -- N >= M
               M     => max_div ) --: INTEGER:= 8)
  port map(    A     => acc1(i)  , --: in std_logic_vector(N-1 downto 0);
               B     => dividend, --: in std_logic_vector(M-1 downto 0);
               clock => clk     , --: in std_logic;
               resetn   => resetn     , --: in std_logic;
               E     => en_in    , --: in std_logic;
               Q     => div_out(i)   , --: out std_logic_vector (N-1 downto 0);
               R     => open    , --: out std_logic_vector(M-1 downto 0);
               v     => open      --: out std_logic
               );

  d_out(i) <= div_out(i)(N-1 downto 0);
end generate gen_mul_bits;
en_out <= en_shift(en_shift'left);



end a;