library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;
library work;
use work.ConvLayer_types_package.all;

entity Linear_serial_tb is
  generic (
           mult_sum      : string := "mult"; --"mult"/"sum"
           CL_inputs     : integer := 512;    -- number of inputs features (maximum = 1024)
           CL_outs       : integer := 1000;    -- number of output features
           w_num_max     : integer := 16;    -- number of weights in one memory line, CL_outs > w_num_max (see below)
           N             : integer := 8;     -- input/output data width
           M             : integer := 8;     -- input weight width
           SR            : integer := 2      -- data shift right before output
  	       );
end Linear_serial_tb;

architecture a of Linear_serial_tb is

component Linear_serial is
  generic (
           mult_sum      : string := "mult"; --"mult"/"sum"
           CL_inputs     : integer := 16;    -- number of inputs features (maximum = 1024)
           CL_outs       : integer := 100;    -- number of output features
           w_num_max     : integer := 16;    -- number of weights in one memory line, CL_outs > w_num_max (see below)
           N             : integer := 8;     -- input/output data width
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
end component;

constant W            : integer := N;  -- output width

signal    clk         : std_logic := '0';
signal    rst         : std_logic;
signal    d_in        : vec(0 to CL_inputs-1)(N-1 downto 0);
signal    en_in       : std_logic;
signal    w_in        : std_logic_vector( M-1 downto 0);  -- value
signal    w_en        : std_logic;
signal    w_pixel_N   : std_logic_vector(12-1 downto 0);  -- weignt of pixel number
signal    w_pixel_L   : std_logic_vector(12-1 downto 0);  -- weignt of pixel line
signal    w_num       : std_logic_vector( 8-1 downto 0);  -- number of weight in the line
signal    w_lin_rdy   : std_logic;                        -- weigth line ready indication
signal    d_out       : vec(0 to CL_outs -1)(N-1 downto 0);
signal    en_out      : std_logic;

signal    w_val       : integer := 3;
signal    sign_p      : integer := 1;
signal    sign_w      : integer := 1;

constant w_pixel_L_max  : integer := CL_outs/w_num_max;

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


process        
   begin   
     wait for 13 ns; 
     wait for 10 ns; w_en  <= '0'; en_in <= '0';  w_lin_rdy <= '0';

     gen_pixNum: for k in 0 to CL_inputs -1 loop
        gen_pixLin: for j in 0 to w_pixel_L_max -1 loop
           wait for 10 ns;                     w_lin_rdy <= '0';
           gen_w: for i in 0 to w_num_max -1 loop
              wait for 10 ns; w_en  <= '1'; w_num <= conv_std_logic_vector( i, w_num'length); w_in<= conv_std_logic_vector(w_val*sign_w, w_in'length);  
                              w_val <= w_val + 1; sign_w <= (-1)* sign_w;
           end loop gen_w;
           wait for 10 ns; w_en  <= '0';       w_lin_rdy <= '1';  w_pixel_L <= conv_std_logic_vector( j, w_pixel_L'length);
                                                                  w_pixel_N <= conv_std_logic_vector( K, w_pixel_N'length);
        end loop gen_pixLin;
     end loop gen_pixNum;

     wait for 10 ns;                     w_lin_rdy <= '0'; 
     wait for 10 ns;  
-- Frame 1
    data_fr: for k in 0 to 5 loop

    en_in <= '1';
      data_ch: for i in 0 to CL_inputs-1 loop
        d_in(i) <= conv_std_logic_vector((2*i+k+1)*sign_p, N);
        --d_in(i) <= conv_std_logic_vector((2*i+1)*sign_p, N);
      end loop data_ch;
    wait for 10 ns;
    en_in <= '0';
    ws_loop: for i in 0 to CL_inputs*CL_inputs/w_num_max loop
       wait for 10 ns;
    end loop ws_loop;
    wait for 10 ns; 
    wait for 10 ns;
    wait for 10 ns; 
    wait for 10 ns; 
    wait for 10 ns;
    wait for 10 ns; 
    wait for 10 ns;
    end loop data_fr;




   end process;

    clk_proc: process
    begin
        wait for 5 ns;
        clk <= not clk;
    end process clk_proc;

    rst <= '1', '0' after 10 ns;

dut: Linear_serial generic map(
           mult_sum    => mult_sum , --"mult"/"sum"
           CL_inputs   => CL_inputs, -- number of inputs features (maximum = 1024)
           CL_outs     => CL_outs  , -- number of output features
           w_num_max   => w_num_max, -- number of weights in one memory line, CL_outs > w_num_max (see below)
           N           => N        , -- input/output data width
           M           => M        , -- input weight width
           SR          => SR         -- data shift right before output
           )
  port map   (
           clk         => clk      ,
           rst         => rst      ,
           d_in        => d_in     ,
           en_in       => en_in    ,
           w_in        => w_in     ,
           w_en        => w_en     ,
           w_pixel_N   => w_pixel_N,
           w_pixel_L   => w_pixel_L,
           w_num       => w_num    ,
           w_lin_rdy   => w_lin_rdy,
           d_out       => d_out    ,
           en_out      => en_out
           );

end a;