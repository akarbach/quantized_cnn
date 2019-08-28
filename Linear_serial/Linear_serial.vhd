library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;
--USE ieee.math_real.log2;
--USE ieee.math_real.ceil;
library work;
use work.ConvLayer_types_package.all;

entity Linear_serial is
  generic (
           mult_sum      : string := "mult"; --"mult"/"sum"
           CL_inputs     : integer := 16;    -- number of inputs features (maximum = 1024)
           CL_outs       : integer := 512;    -- number of output features
           w_num_max     : integer := 512;    -- number of weights in one memory line, CL_outs > w_num_max (see below)
           N             : integer := 16;     -- input/output data width
           M             : integer := 8;     -- input weight width
           SR            : integer := 2      -- data shift right before output
  	       );
  port    (
           clk         : in std_logic;
           rst         : in std_logic;
           d_in        : in vec(0 to CL_inputs-1)(N-1 downto 0);
  	       en_in       : in std_logic;
           
           w_in        : in std_logic_vector( M-1 downto 0);  -- value
           w_en        : in std_logic;
           w_pixel_N   : in std_logic_vector(12-1 downto 0);  -- weignt of pixel number
           w_pixel_L   : in std_logic_vector(12-1 downto 0);  -- weignt of pixel line
           w_num       : in std_logic_vector( 8-1 downto 0);  -- number of weight in the line
           w_lin_rdy   : in std_logic;                        -- weigth line ready indication

           d_out       : out vec(0 to CL_outs -1)(N-1 downto 0);
           en_out      : out std_logic);
end Linear_serial;

architecture a of Linear_serial is

constant w_pixel_L_max  : integer := CL_outs/w_num_max;
--constant w_num_bits     : integer := integer(CEIL(LOG2(Real(w_num_max))));
--constant w_pixel_L_bits : integer := integer(CEIL(LOG2(Real(w_pixel_L_max))));
--constant w_pixel_N_bits : integer := 8; --integer(CEIL(LOG2(Real(CL_inputs))));

---------------------------------------------------  for ResNet18 :
---------------------------------------------------  CL_inputs = 512
------------ structure of weigth matrix              CL_outs   = 1024 (w_pixel_L_max = 64, w_num_max = 16)
---------------------------------------------------      
---------------------------------------------------
-- w_num ->        15  14  13  12  11  10   9                  ...  1  0
--            (w_num_max)_________________________________________________
-- w_pixel_N   0 |   |   |   |   |   |   |   |   |   |   |   |   |   |   |  0 w_pixel_L \ 
--               |   |   |   |   |   |   |   |   |   |   |   |   |   |   |  1 w_pixel_L  \
--               |   |   |   |   |   |   |   |   |   |   |   |   |   |   |  2 w_pixel_L   \  For each of 512 input pixels -> 16 (w_num) * 64 (lines) = 1024 weights
--               |   |   |   |   |   |   |   |   |   |   |   |   |   |   |  3 w_pixel_L   /  Total 1024*512 = 524288 memory cell of M bits
--               .   .   .   .   .   .   .   .   .   .   .   .   .   .   . ...           /
--               |   |   |   |   |   |   |   |   |   |   |   |   |   |   | 63 w_pixel_L /
--               _________________________________________________________
-- w_pixel_N   1 |   |   |   |   |   |   |   |   |   |   |   |   |   |   |  0 w_pixel_L 
--               |   |   |   |   |   |   |   |   |   |   |   |   |   |   |  1 w_pixel_L
--               |   |   |   |   |   |   |   |   |   |   |   |   |   |   |  2 w_pixel_L
--               |   |   |   |   |   |   |   |   |   |   |   |   |   |   |  3 w_pixel_L
--               .   .   .   .   .   .   .   .   .   .   .   .   .   .   . ...
--               |   |   |   |   |   |   |   |   |   |   |   |   |   |   | 63 w_pixel_L   
--               _________________________________________________________             
--               .   .   .   .   .   .   .   .   .   .   .   .   .   .   . ...         
--               _________________________________________________________             
-- w_pixel_N 511 |   |   |   |   |   |   |   |   |   |   |   |   |   |   |  0 w_pixel_L 
--    (CL_inputs)|   |   |   |   |   |   |   |   |   |   |   |   |   |   |  1 w_pixel_L
--               |   |   |   |   |   |   |   |   |   |   |   |   |   |   |  2 w_pixel_L
--               |   |   |   |   |   |   |   |   |   |   |   |   |   |   |  3 w_pixel_L
--               .   .   .   .   .   .   .   .   .   .   .   .   .   .   . ...         
--               |   |   |   |   |   |   |   |   |   |   |   |   |   |   | 63 w_pixel_L
--               _________________________________________________________


component generic_mult is
generic (N: integer; 
         M: integer
         );
port ( 
       clk    :  in  std_logic;
       rst    :  in  std_logic; 
       a      :  in  std_logic_vector(N-1 downto 0);
       b      :  in  std_logic_vector(M-1 downto 0);
       prod   :  out std_logic_vector(M+N-1 downto 0) );
end component;

constant max_input_num: integer := 256;
constant matrix_depth : integer := CL_inputs * w_pixel_L_max;
constant W            : integer := N;  -- output width
constant Np7          : integer := N+M+7;  -- output width
constant Nm1          : integer := N+M-1;  -- output width

signal negative_val: integer ; 
signal sign_chek1 : std_logic_vector(Np7- (N + SR + 1) downto 0);
signal sign_chek3 : std_logic_vector(Np7- (N + SR + 1) downto 0);
signal sign_chek5 : std_logic_vector(Np7- (N + SR + 1) downto 0);
--signal   address, address_d     : integer;

signal   weight_mat  : vec (0 to matrix_depth-1)(w_num_max * M - 1 downto 0);
signal   weight_lin  : std_logic_vector         (w_num_max * M - 1 downto 0);


signal   mult_res       : vec(0 to  w_num_max-1)(Nm1 downto 0);
--signal   mult_res_exten : vec(0 to  w_num_max-1)(N+M-1 downto 0);
--signal   mult_res_ext   : vec(0 to  w_num_max-1)(N+M+7 downto 0);  -- 8 bits added due sum of 256 values

signal acc    : vec(0 to CL_outs -1)(Np7 downto 0);
signal acc_tmp : vec(0 to w_num_max -1)(Np7 downto 0);
signal acc_mem : vec(0 to CL_outs -1)(Np7 downto 0);
--signal acc1   : vec(0 to CL_inputs -1)(Np7-1 downto 0);
--signal div_out: vec(0 to CL_inputs -1)(Np7-1 downto 0);

signal new_acc, new_acc_d   : std_logic;
signal mult_proc : std_logic;
--signal addr_wr_std: std_logic_vector (w_pixel_N_bits + w_pixel_L_bits  downto 0);

signal w_num_i   : integer range 0 to 2**16-1;
signal addr_wr   : integer range 0 to 2**16-1;
signal pixel_N, pixel_L_d, pixel_L_d2   : integer range 0 to 2**16-1;
signal pixel_L, pixel_N_d, pixel_N_d2   : integer range 0 to 2**16-1;
signal weight_mat_line1   : integer range 0 to 2**16-1;
signal weight_mat_line2   : integer range 0 to 2**16-1;
signal weight_mat_line   : integer range 0 to 2**16-1;
signal acc_min   : integer range 0 to 2**16-1;
signal acc_max   : integer range 0 to 2**16-1;
----------------------

--signal   mult_res4      : mat(0 to CL_outs-1)(0 to              4-1)(N+M+7 downto 0);
--signal   mult_res16     : mat(0 to CL_outs-1)(0 to             16-1)(N+M+7 downto 0);
--signal   mult_res64     : mat(0 to CL_outs-1)(0 to             64-1)(N+M+7 downto 0);

--signal   mult_sum01     : vec(0 to CL_outs-1)           (N+M+7 downto 0);  -- current result (by input pixels)
--signal   mult_sum4      : mat(0 to CL_outs-1)(0 to  4-1)(N+M+7 downto 0);  -- last   stage of sum ( 4 values)
--signal   mult_sum16     : mat(0 to CL_outs-1)(0 to 16-1)(N+M+7 downto 0);  -- middle stage of sum (16 values)
--signal   mult_sum64     : mat(0 to CL_outs-1)(0 to 64-1)(N+M+7 downto 0);  -- first  stage of sum (64 values)



--constant                                                         accM : integer  := N+M+7;
--signal   acc         : vec                     (0 to CL_outs -1)(accM downto 0);
----signal   mult_value  : vec                     (0 to CL_outs -1)(N+7  downto 0);
--signal   d_relu      : vec                     (0 to CL_outs -1)(accM  downto 0);
--signal   d_ovf       : vec                     (0 to CL_outs -1)(accM  downto 0);
--
--signal  en_acc , en_relu , en_ovf                        : std_logic;
--signal  en_tmp , en_64 , en_16 , en_4 , en_01 , en_mult  : std_logic;
--signal  sof_tmp, sof_64, sof_16, sof_4, sof_01, sof_mult : std_logic;
--signal  eof_tmp, eof_64, eof_16, eof_4, eof_01, eof_mult : std_logic;

begin

------------------------------------------------------------------
---------------     Weight matrix initialization   ---------------
------------------------------------------------------------------
--                  line 1 values      load line 1     line 2 values  load line 2   ...
--                                      of pixel 1                     of pixel 1

-- w_en      ____  1   1   1   ... 1  ______________1   1   1   ... 1  ___________  ...
-- w_num     ----  V1  V2  V3  ... Vn ______________V1  V2  V3  ... Vn ___________  ...
-- w_in      ----  V1  V2  V3  ... Vn ______________V1  V2  V3  ... Vn ___________  ...
-- w_lin_rdy _____________________________   1     ______________________   1       ...
-- w_pixel_L -----------------------------   L1    ----------------------   L2
-- w_pixel_N -----------------------------   P1    ----------------------   P1   

w_num_i <= conv_integer(unsigned('0' & w_num));

w_en_p : process (clk)
begin
   if rising_edge(clk) then
      if w_en = '1' then
         if w_lin_rdy = '1' then
            weight_lin <=  (others => '0');
         else
            weight_lin(w_num_i * M + M - 1 downto w_num_i * M ) <=  w_in;

         end if;
      end if;
   end if;
end process w_en_p;

--addr_wr <= conv_integer(unsigned('0' & w_pixel_N(w_pixel_N_bits downto 0) & w_pixel_L(w_pixel_L_bits downto 0)));
--addr_wr_std <= '0' & w_pixel_N(w_pixel_N_bits - 1 downto 0) & w_pixel_L(w_pixel_L_bits - 1 downto 0);
addr_wr <= conv_integer(unsigned('0' & w_pixel_N))*w_pixel_L_max + conv_integer(unsigned('0' & w_pixel_L));
w_lin_p : process (clk)
begin
   if rising_edge(clk) then
         if w_lin_rdy = '1' then
            weight_mat(addr_wr) <=  weight_lin;
         end if;
   end if;
end process w_lin_p;

------------------------------------------------------------------
---------------     Operational part   ---------------------------
------------------------------------------------------------------
-- Processing sequence:
-- 1. start if input en_in = 1
-- 2. multiply d_in(0) pixel by memory lines number 0-63 (addresses 0..63), each clk cycle 16 weights
-- 3. sample 1024 product values
-- 4  multiply d_in(1) pixel by memory lines number 0-63 (addresses 64..127), each clk cycle 16 weights
-- 5. sum and accululate 1024 product values
-- 6. execute 4' and 5' for 2-511 d_in pixels (addresses 64x..64(x+1)-1)
-- 7. indicate end of processing by en_out = 1


mem_ctl_p: process (clk,rst)
begin
  if rst = '1' then
     --address   <= 0;
     --address_d <= 0;
     pixel_N   <=  0;
     pixel_L   <=  0;
     mult_proc <= '0';
     new_acc   <= '0';
  elsif rising_edge(clk) then
     if en_in = '1' then
        mult_proc <= '1';
        pixel_N   <=  0;
        pixel_L   <=  0;
     end if;

     if mult_proc = '1' then
        if pixel_N = (CL_inputs -1)  and pixel_L = (w_pixel_L_max - 1) then
           mult_proc <= '0';
           new_acc <= '1';
        else
           if pixel_L = (w_pixel_L_max - 1) then
              pixel_N <= pixel_N + 1;
              pixel_L <=  0;
              new_acc <= '0';
           else
              pixel_L <=  pixel_L + 1;
              new_acc <= '0';
           end if;
        end if;
     else
        new_acc <= '0';
     end if;
  end if;
end process mem_ctl_p;


--weight_mat_line1 <= pixel_N*w_pixel_L_max ;
--weight_mat_line2 <= pixel_L;
--weight_mat_line <= weight_mat_line1 + weight_mat_line2;
weight_mat_line <= pixel_N*w_pixel_L_max + pixel_L;
gen_Mults: if mult_sum = "mult" generate 
   p_mult_mat : process (clk)
   begin
     if rising_edge(clk) then
        mult_in_for: for i in 0 to w_num_max-1 loop
           mult_res(i) <= d_in(pixel_N) * weight_mat(weight_mat_line)((i+1)*M-1 downto i*M);
        end loop mult_in_for;
     end if;
   end process p_mult_mat;
end generate;


gen_Adds: if mult_sum = "sum" generate 
      mult_in_for: for i in 0 to w_num_max-1 generate
        sum: generic_mult generic map (N => N,M => M) port map ( clk => clk,rst => rst, a => d_in(pixel_N) ,  b  => weight_mat(weight_mat_line)((i+1)*M-1 downto i*M),  prod => mult_res(i));
      end generate mult_in_for;

end generate;

--------------------------------------------
----- extention of 0 values to maximum size
--------------------------------------------
--input_copyI: for i in 0 to w_num_max-1 generate          
--   mult_res_exten(i) <= mult_res(i);
--end generate input_copyI;
--    
--externtopn_zeroI: for i in CL_inputs to max_input_num-1 generate           
--   mult_res_exten(i) <= (others => '0'); --conv_std_logic_vector( 0, N+M-1); --(others => '0');
--end generate externtopn_zeroI;

------------------------------------------
--- extention 0 MSBits
------------------------------------------
--add_j_0:   for i in 0 to w_num_max-1 generate
--   mult_res_ext(i)(N+M-1 downto   0) <=            mult_res(i)(N+M-1 downto 0);
--   mult_res_ext(i)(N+M+7 downto N+M) <= (others => mult_res(i)(N+M-1)); 
--end generate add_j_0;


----------------------------------
---     Adder
----------------------------------
-- Frame accumulator
acc_min <=  pixel_N     * pixel_L;
acc_max <= (pixel_N +1) * pixel_L;
  p_acc : process (clk,rst)
  variable sign_ext  : std_logic_vector(Np7-Nm1-1 downto 0);
  variable sign_chek : std_logic_vector(Np7- (N + SR + 1) downto 0);
  begin
    if rst = '1' then
      acc        <= (others => (others => '0'));
      pixel_L_d  <= 0;
      pixel_N_d  <= 0;
      pixel_L_d2 <= 0;
      pixel_N_d2 <= 0;
      new_acc_d  <= '0';
      en_out     <= '0';
      d_out      <= (others => (others => '0'));
    elsif rising_edge(clk) then
       pixel_L_d <= pixel_L;
       pixel_N_d <= pixel_N;
       new_acc_d <= new_acc;
       --if new_acc = '1' then
       --if pixel_N_d2 = 0 then
       --   acc_mem()
       --end if;

       if en_in = '1' then 
          acc       <= (others => (others => '0'));
       elsif pixel_N_d = 0 then 
          cp_mult2acc: for i in 0 to w_num_max-1 loop
             --acc(i+pixel_L_d*w_num_max)(N+M-1 downto 0) <=  mult_res(i);
             sign_ext := (others => mult_res(i)(Nm1));
             acc(i+pixel_L_d*w_num_max) <=  sign_ext & mult_res(i);
             acc_tmp(i) <=  sign_ext & mult_res(i);
          end loop cp_mult2acc;
       else
          acc_loop: for i in 0 to w_num_max-1 loop
             sign_ext := (others => mult_res(i)(Nm1));
             acc(i+pixel_L_d*w_num_max) <= acc(i+pixel_L_d*w_num_max) + (sign_ext & mult_res(i));
          end loop acc_loop;
       end if;
       if new_acc_d = '1' then
          dout_loop: for i in 0 to CL_outs -1 loop
             sign_chek := acc(i)(Np7 downto N + SR + 1);
             if (sign_chek = 0                                                                   and acc(i)(N + SR -1) = '0') or 
                (sign_chek = conv_std_logic_vector(2**(Np7 - (N + SR + 1)+1)-1 , sign_chek'length) and acc(i)(N + SR -1) = '1') then  -- no over/under-flow
                d_out(i) <= acc(i)(N + SR -1 downto SR);
             else  -- 
                if acc(i)(Np7) = '0' then  -- overflow
                    d_out(i)(N-1)          <= acc(i)(Np7);     -- positive number 
                    d_out(i)(N-2 downto 0) <= (others => '1'); -- maximum value
                else                       -- underflow
                    d_out(i)(N-1)          <= acc(i)(Np7);     -- negative number 
                    d_out(i)(N-2 downto 0) <= (others => '0'); -- minimum value
                end if;
             end if;
          end loop dout_loop;
          en_out <= '1';
       else
          en_out <= '0';
       end if;
    end if;
  end process p_acc;
sign_chek1 <= acc(1)(Np7 downto N + SR + 1);
sign_chek3 <= acc(3)(Np7 downto N + SR + 1);
sign_chek5 <= acc(5)(Np7 downto N + SR + 1);
negative_val <= 2**(Np7 - (N + SR + 1)+1)-1;

end a;