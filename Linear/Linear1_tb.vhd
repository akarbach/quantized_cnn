library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;
library work;
use work.ConvLayer_types_package.all;

entity Linear1_tb is
  generic (
           Relu          : string := "yes"; --"no"/"yes"  -- nonlinear Relu function
           BP            : string := "no";  --"no"/"yes"  -- Bypass
           TP            : string := "no";  --"no"/"yes"  -- Test pattern output
           mult_sum      : string := "mult"; --"mult"/"sum"
           CL_inputs     : integer := 3;    -- number of inputs features (maximum = 256)
           CL_outs       : integer := 2;    -- number of output features
           N             : integer := 4;    -- input/output data width
           M             : integer := 4;    -- input weight width
           SR            : integer := 2;    -- data shift right before output
           addr_w        : integer := 12;   -- number of address bits in weight matrix
           line_w        : integer :=  8;   -- number of address bits in weight line
           in_row        : integer :=  2;
           in_col        : integer :=  2
  	       );
end Linear1_tb;

architecture a of Linear1_tb is

component Linear1 is
  generic (
           Relu          : string := "yes"; --"no"/"yes"  -- nonlinear Relu function
           BP            : string := "no";  --"no"/"yes"  -- Bypass
           TP            : string := "no";  --"no"/"yes"  -- Test pattern output
           mult_sum      : string := "sum"; --"mult"/"sum"
           CL_inputs     : integer := 2;    -- number of inputs features (maximum = 256)
           CL_outs       : integer := 3;    -- number of output features
           N             : integer := 8;    -- input/output data width
           M             : integer := 8;    -- input weight width
           SR            : integer := 2;    -- data shift right before output
           addr_w        : integer := 12;   -- number of address bits in weight matrix
           line_w        : integer :=  8;   -- number of address bits in weight line
           in_row        : integer :=  2;
           in_col        : integer :=  2
           );
  port    (
           clk         : in std_logic;
           rst         : in std_logic;
           d_in        : in vec(0 to CL_inputs-1)(N-1 downto 0);

            en_in       : in std_logic;
            sof_in      : in std_logic; -- start of frame
           
           w_in        : in std_logic_vector( M-1 downto 0);  -- value
           w_en        : in std_logic;
           w_addr      : in std_logic_vector(12-1 downto 0);  -- address of weight table
           w_num       : in std_logic_vector( 8-1 downto 0);  -- number of weight in the line
           w_lin_rdy   : in std_logic;                        -- weigth line ready indication

           d_out       : out vec(0 to CL_outs -1)(N-1 downto 0);
           en_out      : out std_logic);
end component;

constant matrix_depth : integer := CL_inputs * in_row * in_col;
constant W            : integer := N;  -- output width

signal    clk         : std_logic := '0';
signal    rst         : std_logic;
signal    d_in        : vec(0 to CL_inputs-1)(N-1 downto 0);
signal    en_in       : std_logic;
signal    sof_in      : std_logic; -- start of frame
signal    w_in        : std_logic_vector( M-1 downto 0);  -- value
signal    w_en        : std_logic;
signal    w_addr      : std_logic_vector(12-1 downto 0);  -- address of weight table
signal    w_num       : std_logic_vector( 8-1 downto 0);  -- number of weight in the line
signal    w_lin_rdy   : std_logic;                        -- weigth line ready indication
signal    d_out       : vec(0 to CL_outs -1)(N-1 downto 0);
signal    en_out      : std_logic;

signal    w_val       : integer := 1;
signal    sign_p      : integer := 1;
signal    sign_w      : integer := 1;

begin

------------------------------------------------------------------
---------------     Weight matrix initialization   ---------------
------------------------------------------------------------------
--                  line 1 values      load line 1     line 2 values  load line 2   ...
-- w_en      ____  1   1   1   ... 1  ______________1   1   1   ... 1  ___________  ...
-- w_num     ----  V1  V2  V3  ... Vn ______________V1  V2  V3  ... Vn ___________  ...
-- w_in      ----  V1  V2  V3  ... Vn ______________V1  V2  V3  ... Vn ___________  ...
-- w_lin_rdy _____________________________   1     ______________________   1       ...
-- w_addr    -----------------------------   A1    ----------------------   A2   



process        
   begin   
     wait for 13 ns; 
     wait for 10 ns; w_en  <= '0'; en_in <= '0';  sof_in <= '0'; w_lin_rdy <= '0';
--     wait for 10 ns; w_en  <= '1'; w_num <= conv_std_logic_vector( 0, w_num'length); w_in<= conv_std_logic_vector( 1, w_in'length);
--     wait for 10 ns; w_en  <= '1'; w_num <= conv_std_logic_vector( 1, w_num'length); w_in<= conv_std_logic_vector( 2, w_in'length);
--     wait for 10 ns; w_en  <= '1'; w_num <= conv_std_logic_vector( 2, w_num'length); w_in<= conv_std_logic_vector( 3, w_in'length);
--     wait for 10 ns; w_en  <= '1'; w_num <= conv_std_logic_vector( 3, w_num'length); w_in<= conv_std_logic_vector( 4, w_in'length);
--     wait for 10 ns; w_en  <= '1'; w_num <= conv_std_logic_vector( 4, w_num'length); w_in<= conv_std_logic_vector( 5, w_in'length);
--     wait for 10 ns; w_en  <= '1'; w_num <= conv_std_logic_vector( 5, w_num'length); w_in<= conv_std_logic_vector( 6, w_in'length);
--     wait for 10 ns; w_en  <= '0';       w_lin_rdy <= '1';  w_addr <= conv_std_logic_vector( 0, w_addr'length);
--     wait for 10 ns;                     w_lin_rdy <= '0'; 
--     wait for 10 ns; w_en  <= '1'; w_num <= conv_std_logic_vector( 0, w_num'length); w_in<= conv_std_logic_vector( 7, w_in'length);
--     wait for 10 ns; w_en  <= '1'; w_num <= conv_std_logic_vector( 1, w_num'length); w_in<= conv_std_logic_vector( 8, w_in'length);
--     wait for 10 ns; w_en  <= '1'; w_num <= conv_std_logic_vector( 2, w_num'length); w_in<= conv_std_logic_vector( 9, w_in'length);
--     wait for 10 ns; w_en  <= '1'; w_num <= conv_std_logic_vector( 3, w_num'length); w_in<= conv_std_logic_vector(10, w_in'length);
--     wait for 10 ns; w_en  <= '1'; w_num <= conv_std_logic_vector( 4, w_num'length); w_in<= conv_std_logic_vector(11, w_in'length);
--     wait for 10 ns; w_en  <= '1'; w_num <= conv_std_logic_vector( 5, w_num'length); w_in<= conv_std_logic_vector(12, w_in'length);
--     wait for 10 ns; w_en  <= '0';       w_lin_rdy <= '1';  w_addr <= conv_std_logic_vector( 1, w_addr'length);
--     wait for 10 ns;                     w_lin_rdy <= '0'; 
--     wait for 10 ns; w_en  <= '1'; w_num <= conv_std_logic_vector( 0, w_num'length); w_in<= conv_std_logic_vector(13, w_in'length);
--     wait for 10 ns; w_en  <= '1'; w_num <= conv_std_logic_vector( 1, w_num'length); w_in<= conv_std_logic_vector(14, w_in'length);
--     wait for 10 ns; w_en  <= '1'; w_num <= conv_std_logic_vector( 2, w_num'length); w_in<= conv_std_logic_vector(15, w_in'length);
--     wait for 10 ns; w_en  <= '1'; w_num <= conv_std_logic_vector( 3, w_num'length); w_in<= conv_std_logic_vector(16, w_in'length);
--     wait for 10 ns; w_en  <= '1'; w_num <= conv_std_logic_vector( 4, w_num'length); w_in<= conv_std_logic_vector(17, w_in'length);
--     wait for 10 ns; w_en  <= '1'; w_num <= conv_std_logic_vector( 5, w_num'length); w_in<= conv_std_logic_vector(18, w_in'length);
--     wait for 10 ns; w_en  <= '0';       w_lin_rdy <= '1';  w_addr <= conv_std_logic_vector( 2, w_addr'length);
--     wait for 10 ns;                     w_lin_rdy <= '0'; 
--     wait for 10 ns; w_en  <= '1'; w_num <= conv_std_logic_vector( 0, w_num'length); w_in<= conv_std_logic_vector(19, w_in'length);
--     wait for 10 ns; w_en  <= '1'; w_num <= conv_std_logic_vector( 1, w_num'length); w_in<= conv_std_logic_vector(20, w_in'length);
--     wait for 10 ns; w_en  <= '1'; w_num <= conv_std_logic_vector( 2, w_num'length); w_in<= conv_std_logic_vector(21, w_in'length);
--     wait for 10 ns; w_en  <= '1'; w_num <= conv_std_logic_vector( 3, w_num'length); w_in<= conv_std_logic_vector(22, w_in'length);
--     wait for 10 ns; w_en  <= '1'; w_num <= conv_std_logic_vector( 4, w_num'length); w_in<= conv_std_logic_vector(23, w_in'length);
--     wait for 10 ns; w_en  <= '1'; w_num <= conv_std_logic_vector( 5, w_num'length); w_in<= conv_std_logic_vector(24, w_in'length);
--     wait for 10 ns; w_en  <= '0';       w_lin_rdy <= '1';  w_addr <= conv_std_logic_vector( 3, w_addr'length);
--     wait for 10 ns;                     w_lin_rdy <= '0'; 


     gen_w1: for j in 0 to in_row * in_col -1 loop
        wait for 10 ns;                     w_lin_rdy <= '0';
        gen_w: for i in 0 to CL_inputs * CL_outs -1 loop
           wait for 10 ns; w_en  <= '1'; w_num <= conv_std_logic_vector( i, w_num'length); w_in<= conv_std_logic_vector(w_val*sign_w, w_in'length);  
                           w_val <= w_val + 1; sign_w <= (-1)* sign_w;
        end loop gen_w;
        wait for 10 ns; w_en  <= '0';       w_lin_rdy <= '1';  w_addr <= conv_std_logic_vector( j, w_addr'length);
     end loop gen_w1;

     wait for 10 ns;                     w_lin_rdy <= '0'; 

-- Frame 1
    data_fr: for k in 0 to 5 loop
    en_in <= '1';
    --sign_p <= (-1) * sign_p;
    data_cl: for j in 0 to in_row * in_col -1 loop
      data_ch: for i in 0 to CL_inputs-1 loop
        d_in(i) <= conv_std_logic_vector((i+j+k+1)*sign_p, N);
      end loop data_ch;
    wait for 10 ns;
    end loop data_cl;
    en_in <= '0';
    --data_0: for i in 0 to CL_inputs-1 loop
    --  d_in(i) <= conv_std_logic_vector(0, N);
    --end loop data_0;
    wait for 10 ns; 
    wait for 10 ns;
    wait for 10 ns; 
    wait for 10 ns;
    end loop data_fr;



---     wait for 10 ns; en_in <= '1'; d_in(0) <= conv_std_logic_vector( 12, N); d_in(1) <= conv_std_logic_vector( 132, N); --d_in(2) <= conv_std_logic_vector( 52, N);  sof_in <= '1';
---     wait for 10 ns; en_in <= '1'; d_in(0) <= conv_std_logic_vector( 11, N); d_in(1) <= conv_std_logic_vector( 131, N); --d_in(2) <= conv_std_logic_vector( 51, N);  sof_in <= '0';
---     wait for 10 ns; en_in <= '1'; d_in(0) <= conv_std_logic_vector( 10, N); d_in(1) <= conv_std_logic_vector( 130, N); --d_in(2) <= conv_std_logic_vector( 50, N);  
---     wait for 10 ns; en_in <= '1'; d_in(0) <= conv_std_logic_vector(  9, N); d_in(1) <= conv_std_logic_vector( 129, N); --d_in(2) <= conv_std_logic_vector( 49, N);  
---     wait for 10 ns; en_in <= '1'; d_in(0) <= conv_std_logic_vector(  8, N); d_in(1) <= conv_std_logic_vector( 128, N); --d_in(2) <= conv_std_logic_vector( 48, N);  
---     wait for 10 ns; en_in <= '1'; d_in(0) <= conv_std_logic_vector(  7, N); d_in(1) <= conv_std_logic_vector( 127, N); --d_in(2) <= conv_std_logic_vector( 47, N);  
---     wait for 10 ns; en_in <= '1'; d_in(0) <= conv_std_logic_vector(  6, N); d_in(1) <= conv_std_logic_vector( 126, N); --d_in(2) <= conv_std_logic_vector( 46, N);  
---     wait for 10 ns; en_in <= '1'; d_in(0) <= conv_std_logic_vector(  5, N); d_in(1) <= conv_std_logic_vector( 125, N); --d_in(2) <= conv_std_logic_vector( 45, N);  
---     wait for 10 ns; en_in <= '1'; d_in(0) <= conv_std_logic_vector(  4, N); d_in(1) <= conv_std_logic_vector( 124, N); --d_in(2) <= conv_std_logic_vector( 44, N);  
---     wait for 10 ns; en_in <= '1'; d_in(0) <= conv_std_logic_vector(  3, N); d_in(1) <= conv_std_logic_vector( 123, N); --d_in(2) <= conv_std_logic_vector( 43, N);  
---     wait for 10 ns; en_in <= '1'; d_in(0) <= conv_std_logic_vector(  2, N); d_in(1) <= conv_std_logic_vector( 122, N); --d_in(2) <= conv_std_logic_vector( 42, N);  
---     wait for 10 ns; en_in <= '1'; d_in(0) <= conv_std_logic_vector(  1, N); d_in(1) <= conv_std_logic_vector( 121, N); --d_in(2) <= conv_std_logic_vector( 41, N);  
---     wait for 10 ns; en_in <= '0';
---
----- Frame 2
---     wait for 10 ns; en_in <= '1'; d_in(0) <= conv_std_logic_vector( 52, N); d_in(1) <= conv_std_logic_vector( 62, N); --d_in(2) <= conv_std_logic_vector( 52, N); sof_in <= '1';
---     wait for 10 ns; en_in <= '1'; d_in(0) <= conv_std_logic_vector( 51, N); d_in(1) <= conv_std_logic_vector( 61, N); --d_in(2) <= conv_std_logic_vector( 51, N); sof_in <= '0';
---     wait for 10 ns; en_in <= '1'; d_in(0) <= conv_std_logic_vector( 50, N); d_in(1) <= conv_std_logic_vector( 60, N); --d_in(2) <= conv_std_logic_vector( 50, N); 
---     wait for 10 ns; en_in <= '1'; d_in(0) <= conv_std_logic_vector( 49, N); d_in(1) <= conv_std_logic_vector( 59, N); --d_in(2) <= conv_std_logic_vector( 49, N); 
---     wait for 10 ns; en_in <= '1'; d_in(0) <= conv_std_logic_vector( 48, N); d_in(1) <= conv_std_logic_vector( 58, N); --d_in(2) <= conv_std_logic_vector( 48, N); 
---     wait for 10 ns; en_in <= '1'; d_in(0) <= conv_std_logic_vector( 47, N); d_in(1) <= conv_std_logic_vector( 57, N); --d_in(2) <= conv_std_logic_vector( 47, N); 
---     wait for 10 ns; en_in <= '1'; d_in(0) <= conv_std_logic_vector( 46, N); d_in(1) <= conv_std_logic_vector( 56, N); --d_in(2) <= conv_std_logic_vector( 46, N); 
---     wait for 10 ns; en_in <= '1'; d_in(0) <= conv_std_logic_vector( 45, N); d_in(1) <= conv_std_logic_vector( 55, N); --d_in(2) <= conv_std_logic_vector( 45, N); 
---     wait for 10 ns; en_in <= '1'; d_in(0) <= conv_std_logic_vector( 44, N); d_in(1) <= conv_std_logic_vector( 54, N); --d_in(2) <= conv_std_logic_vector( 44, N); 
---     wait for 10 ns; en_in <= '1'; d_in(0) <= conv_std_logic_vector( 43, N); d_in(1) <= conv_std_logic_vector( 53, N); --d_in(2) <= conv_std_logic_vector( 43, N); 
---     wait for 10 ns; en_in <= '1'; d_in(0) <= conv_std_logic_vector( 42, N); d_in(1) <= conv_std_logic_vector( 52, N); --d_in(2) <= conv_std_logic_vector( 42, N); 
---     wait for 10 ns; en_in <= '1'; d_in(0) <= conv_std_logic_vector( 41, N); d_in(1) <= conv_std_logic_vector( 51, N); --d_in(2) <= conv_std_logic_vector( 41, N); 
---     wait for 10 ns; en_in <= '0';
---
---
---     wait for 10 ns; en_in <= '1'; d_in(0) <= conv_std_logic_vector( 12, N); d_in(1) <= conv_std_logic_vector( 32, N); --d_in(2) <= conv_std_logic_vector( 52, N); sof_in <= '1';
---     wait for 10 ns; en_in <= '1'; d_in(0) <= conv_std_logic_vector( 11, N); d_in(1) <= conv_std_logic_vector( 31, N); --d_in(2) <= conv_std_logic_vector( 51, N); sof_in <= '0';
---     wait for 10 ns; en_in <= '1'; d_in(0) <= conv_std_logic_vector( 10, N); d_in(1) <= conv_std_logic_vector( 30, N); --d_in(2) <= conv_std_logic_vector( 50, N); 
---     wait for 10 ns; en_in <= '1'; d_in(0) <= conv_std_logic_vector(  9, N); d_in(1) <= conv_std_logic_vector( 29, N); --d_in(2) <= conv_std_logic_vector( 49, N); 
---     wait for 10 ns; en_in <= '1'; d_in(0) <= conv_std_logic_vector(  8, N); d_in(1) <= conv_std_logic_vector( 28, N); --d_in(2) <= conv_std_logic_vector( 48, N); 
---     wait for 10 ns; en_in <= '1'; d_in(0) <= conv_std_logic_vector(  7, N); d_in(1) <= conv_std_logic_vector( 27, N); --d_in(2) <= conv_std_logic_vector( 47, N); 
---     wait for 10 ns; en_in <= '1'; d_in(0) <= conv_std_logic_vector(  6, N); d_in(1) <= conv_std_logic_vector( 26, N); --d_in(2) <= conv_std_logic_vector( 46, N); 
---     wait for 10 ns; en_in <= '1'; d_in(0) <= conv_std_logic_vector(  5, N); d_in(1) <= conv_std_logic_vector( 25, N); --d_in(2) <= conv_std_logic_vector( 45, N); 
---     wait for 10 ns; en_in <= '1'; d_in(0) <= conv_std_logic_vector(  4, N); d_in(1) <= conv_std_logic_vector( 24, N); --d_in(2) <= conv_std_logic_vector( 44, N); 
---     wait for 10 ns; en_in <= '1'; d_in(0) <= conv_std_logic_vector(  3, N); d_in(1) <= conv_std_logic_vector( 23, N); --d_in(2) <= conv_std_logic_vector( 43, N); 
---     wait for 10 ns; en_in <= '1'; d_in(0) <= conv_std_logic_vector(  2, N); d_in(1) <= conv_std_logic_vector( 22, N); --d_in(2) <= conv_std_logic_vector( 42, N); 
---     wait for 10 ns; en_in <= '1'; d_in(0) <= conv_std_logic_vector(  1, N); d_in(1) <= conv_std_logic_vector( 21, N); --d_in(2) <= conv_std_logic_vector( 41, N);      wait for 10 ns; en_in <= '0';

   end process;

    clk_proc: process
    begin
        wait for 5 ns;
        clk <= not clk;
    end process clk_proc;

    rst <= '1', '0' after 10 ns;

dut: Linear1 generic map(
           Relu        => Relu     ,
           BP          => BP       ,
           TP          => TP       ,
           mult_sum    => mult_sum ,
           CL_inputs   => CL_inputs,
           CL_outs     => CL_outs  ,
           N           => N        ,
           M           => M        , 
           SR          => SR       ,
           addr_w      => addr_w   ,
           line_w      => line_w   ,
           in_row      => in_row   ,
           in_col      => in_col   
           )
  port map   (
           clk         => clk,
           rst         => rst,
           d_in        => d_in,
           en_in       => en_in,
           sof_in      => sof_in,
           w_in        => w_in,
           w_en        => w_en,
           w_addr      => w_addr,
           w_num       => w_num,
           w_lin_rdy   => w_lin_rdy,
           d_out       => d_out,
           en_out      => en_out
           );

end a;