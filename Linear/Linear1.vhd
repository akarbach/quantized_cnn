library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;
library work;
use work.ConvLayer_types_package.all;

entity Linear1 is
  generic (
           Relu          : string := "yes"; --"no"/"yes"  -- nonlinear Relu function
           BP            : string := "no";  --"no"/"yes"  -- Bypass
           TP            : string := "no";  --"no"/"yes"  -- Test pattern output
           mult_sum      : string := "mult"; --"mult"/"sum"
           CL_inputs     : integer := 4;    -- number of inputs features (maximum = 256)
           CL_outs       : integer := 4;    -- number of output features
           N             : integer := 8;    -- input/output data width
           M             : integer := 8;    -- input weight width
           SR            : integer := 2;    -- data shift right before output
           addr_w        : integer := 12;   -- number of address bits in weight matrix
           line_w        : integer :=  8;   -- number of address bits in weight line
           in_row        : integer :=  5;   -- max value in_row * in_col = 256
           in_col        : integer :=  5    -- max value in_row * in_col = 256
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
end Linear1;

architecture a of Linear1 is


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
constant matrix_depth : integer := in_row * in_col;
constant W            : integer := N;  -- output width

signal   address     : integer := 0;

signal   weight_mat  : mat(0 to matrix_depth-1)(0 to CL_outs * CL_inputs -1)(M-1 downto 0);
--signal   weight_mat  : mat(0 to CL_outs * CL_inputs-1)(0 to CL_outs * CL_inputs -1)(M-1 downto 0);
signal   weight_lin  : vec                     (0 to CL_outs * CL_inputs -1)(M-1 downto 0);

signal   mult_res       : mat(0 to CL_outs-1)(0 to  CL_inputs    -1)(N+M-1 downto 0);
signal   mult_res_exten : mat(0 to CL_outs-1)(0 to  max_input_num-1)(N+M-1 downto 0);
signal   mult_res_ext   : mat(0 to CL_outs-1)(0 to  max_input_num-1)(N+M+7 downto 0);  -- 8 bits added due sum of 256 values
--signal   mult_res4      : mat(0 to CL_outs-1)(0 to              4-1)(N+M+7 downto 0);
--signal   mult_res16     : mat(0 to CL_outs-1)(0 to             16-1)(N+M+7 downto 0);
--signal   mult_res64     : mat(0 to CL_outs-1)(0 to             64-1)(N+M+7 downto 0);

signal   mult_sum01     : vec(0 to CL_outs-1)           (N+M+7 downto 0);  -- current result (by input pixels)
signal   mult_sum4      : mat(0 to CL_outs-1)(0 to  4-1)(N+M+7 downto 0);  -- last   stage of sum ( 4 values)
signal   mult_sum16     : mat(0 to CL_outs-1)(0 to 16-1)(N+M+7 downto 0);  -- middle stage of sum (16 values)
signal   mult_sum64     : mat(0 to CL_outs-1)(0 to 64-1)(N+M+7 downto 0);  -- first  stage of sum (64 values)



constant                                                         accM : integer  := N+M+7;
signal   acc         : vec                     (0 to CL_outs -1)(accM downto 0);
--signal   mult_value  : vec                     (0 to CL_outs -1)(N+7  downto 0);
signal   d_relu      : vec                     (0 to CL_outs -1)(accM  downto 0);
signal   d_ovf       : vec                     (0 to CL_outs -1)(accM  downto 0);

signal  en_acc , en_relu , en_ovf                        : std_logic;
signal  en_tmp , en_64 , en_16 , en_4 , en_01 , en_mult  : std_logic;
signal  sof_tmp, sof_64, sof_16, sof_4, sof_01, sof_mult : std_logic;
signal  eof_tmp, eof_64, eof_16, eof_4, eof_01, eof_mult : std_logic;

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

w_en_p : process (clk)
begin
   if rising_edge(clk) then
      if w_en = '1' then
         if w_lin_rdy = '1' then
            weight_lin <=  (others => (others => '0'));
         else
            weight_lin(conv_integer(unsigned('0' & w_num))) <=  w_in;
            ---weight_lin(conv_integer(unsigned('0' & w_num)) <=  w_in;
         end if;
      end if;
   end if;
end process w_en_p;

w_lin_p : process (clk)
begin
   if rising_edge(clk) then
         if w_lin_rdy = '1' then
            weight_mat(conv_integer(unsigned('0' & w_addr))) <=  weight_lin;
         end if;
   end if;
end process w_lin_p;

------------------------------------------------------------------
---------------     Operational part   ---------------------------
------------------------------------------------------------------

fifo_ctl_p: process (clk,rst)
begin
  if rst = '1' then
     address  <= 0;
  elsif rising_edge(clk) then
     if en_in = '1' then
        if conv_integer(address) = matrix_depth - 1 then
           address <= 0;
        else
           address <= address + 1;
        end if;
     end if;
  end if;
end process fifo_ctl_p;


gen_Mults: if mult_sum = "mult" generate 

   p_mult_mat : process (clk)
   begin
     if rising_edge(clk) then
        mult_out_for: for j in 0 to CL_outs-1 loop
           mult_in_for: for i in 0 to CL_inputs-1 loop
              mult_res(j)(i) <= d_in(i) * weight_mat(address)(j*CL_inputs + i);
           end loop mult_in_for;
        end loop mult_out_for;
     end if;
   end process p_mult_mat;

   en_mult_p: process (clk,rst)
   begin
     if rst = '1' then
        en_mult  <= '0';
        sof_mult <= '0';
        eof_mult <= '0';
     elsif rising_edge(clk) then
        en_mult  <= en_in;
        sof_mult <= sof_in;
        if conv_integer(address) = matrix_depth - 1 then
           eof_mult <= '1';
        else
           eof_mult <= '0';
        end if;
     end if;
   end process en_mult_p;

end generate;

gen_Adds: if mult_sum = "sum" generate 

   mult_out_for: for j in 0 to CL_outs-1 generate
      mult_in_for: for i in 0 to CL_inputs-1 generate
        sum: generic_mult generic map (N => N,M => M) port map ( clk => clk,rst => rst, a => d_in(i) ,  b  => weight_mat(address)(j*CL_inputs + i),  prod => mult_res(j)(i));
      end generate mult_in_for;
   end generate mult_out_for;

   en_mult_p: process (clk,rst)
   begin
     if rst = '1' then
        en_mult  <= '0'; 
        sof_mult <= '0';
        eof_mult <= '0';
        en_tmp   <= '0';
        sof_tmp  <= '0';
        eof_tmp  <= '0';
     elsif rising_edge(clk) then
        en_tmp   <= en_in;
        en_mult  <= en_tmp;
        sof_tmp  <= sof_in;
        sof_mult <= sof_tmp;
        if conv_integer(address) = matrix_depth - 1 then
           eof_tmp <= '1';
        else
           eof_tmp <= '0';
        end if;
        eof_mult <= eof_tmp;
     end if;
   end process en_mult_p;

end generate;

------------------------------------------
--- extention of 0 values to maximum size
------------------------------------------
input_copyO: for j in 0 to CL_outs-1 generate 
   input_copyI: for i in 0 to CL_inputs-1 generate          
      mult_res_exten(j)(i) <= mult_res(j)(i);
   end generate input_copyI;
end generate input_copyO;

externtopn_zeroO: for j in 0 to CL_outs-1 generate    
   externtopn_zeroI: for i in CL_inputs to max_input_num-1 generate           
      mult_res_exten(j)(i) <= (others => '0'); --conv_std_logic_vector( 0, N+M-1); --(others => '0');
   end generate externtopn_zeroI;
end generate externtopn_zeroO;

------------------------------------------
--- extention 0 MSBits
------------------------------------------
add_i_0: for j in 0 to CL_outs-1 generate                         -- sign extention
   add_j_0:   for i in 0 to max_input_num-1 generate
      mult_res_ext(j)(i)(N+M-1 downto   0) <=            mult_res_exten(j)(i)(N+M-1 downto 0);
      mult_res_ext(j)(i)(N+M+7 downto N+M) <= (others => mult_res_exten(j)(i)(N+M-1)); 
   end generate add_j_0;
end generate add_i_0;

----------------------------------
---     Adder
----------------------------------

------------------------------------
-----     Fast stage
------------------------------------
--
--add4: if CL_inputs <= 4 generate
--   p_mult_add : process (clk)
--   begin
--     if rising_edge(clk) then
--        --if en_in = '1' then
--           input_mult_for: for i in 0 to CL_outs-1 loop
--              acc(i) <= mult_res_ext(i)(0) + mult_res_ext(i)(1) + mult_res_ext(i)(2) + mult_res_ext(i)(3);
--           end loop input_mult_for;
--        --end if;
--     end if;
--   end process p_mult_add;
--end generate add4;


------------------------------------
-----     Firt stage
------------------------------------

add64p: if CL_inputs <= 256 and CL_inputs > 64 generate
   p_mult_add : process (clk)
   begin
     if rising_edge(clk) then
        --if en_in = '1' then
           input_mult_for: for i in 0 to CL_outs-1 loop
              mult_sum64(i)( 0) <= mult_res_ext(i)( 0) + mult_res_ext(i)( 64) + mult_res_ext(i)(128) + mult_res_ext(i)(192);
              mult_sum64(i)( 1) <= mult_res_ext(i)( 1) + mult_res_ext(i)( 65) + mult_res_ext(i)(129) + mult_res_ext(i)(193);
              mult_sum64(i)( 2) <= mult_res_ext(i)( 2) + mult_res_ext(i)( 66) + mult_res_ext(i)(130) + mult_res_ext(i)(194);
              mult_sum64(i)( 3) <= mult_res_ext(i)( 3) + mult_res_ext(i)( 67) + mult_res_ext(i)(131) + mult_res_ext(i)(195);
              mult_sum64(i)( 4) <= mult_res_ext(i)( 4) + mult_res_ext(i)( 68) + mult_res_ext(i)(132) + mult_res_ext(i)(196);
              mult_sum64(i)( 5) <= mult_res_ext(i)( 5) + mult_res_ext(i)( 69) + mult_res_ext(i)(133) + mult_res_ext(i)(197);
              mult_sum64(i)( 6) <= mult_res_ext(i)( 6) + mult_res_ext(i)( 70) + mult_res_ext(i)(134) + mult_res_ext(i)(198);
              mult_sum64(i)( 7) <= mult_res_ext(i)( 7) + mult_res_ext(i)( 71) + mult_res_ext(i)(135) + mult_res_ext(i)(199);
              mult_sum64(i)( 8) <= mult_res_ext(i)( 8) + mult_res_ext(i)( 72) + mult_res_ext(i)(136) + mult_res_ext(i)(200);
              mult_sum64(i)( 9) <= mult_res_ext(i)( 9) + mult_res_ext(i)( 73) + mult_res_ext(i)(137) + mult_res_ext(i)(201);
              mult_sum64(i)(10) <= mult_res_ext(i)(10) + mult_res_ext(i)( 74) + mult_res_ext(i)(138) + mult_res_ext(i)(202);
              mult_sum64(i)(11) <= mult_res_ext(i)(11) + mult_res_ext(i)( 75) + mult_res_ext(i)(139) + mult_res_ext(i)(203);
              mult_sum64(i)(12) <= mult_res_ext(i)(12) + mult_res_ext(i)( 76) + mult_res_ext(i)(140) + mult_res_ext(i)(204);
              mult_sum64(i)(13) <= mult_res_ext(i)(13) + mult_res_ext(i)( 77) + mult_res_ext(i)(141) + mult_res_ext(i)(205);
              mult_sum64(i)(14) <= mult_res_ext(i)(14) + mult_res_ext(i)( 78) + mult_res_ext(i)(142) + mult_res_ext(i)(206);
              mult_sum64(i)(15) <= mult_res_ext(i)(15) + mult_res_ext(i)( 79) + mult_res_ext(i)(143) + mult_res_ext(i)(207);
              mult_sum64(i)(16) <= mult_res_ext(i)(16) + mult_res_ext(i)( 80) + mult_res_ext(i)(144) + mult_res_ext(i)(208);
              mult_sum64(i)(17) <= mult_res_ext(i)(17) + mult_res_ext(i)( 81) + mult_res_ext(i)(145) + mult_res_ext(i)(209);
              mult_sum64(i)(18) <= mult_res_ext(i)(18) + mult_res_ext(i)( 82) + mult_res_ext(i)(146) + mult_res_ext(i)(210);
              mult_sum64(i)(19) <= mult_res_ext(i)(19) + mult_res_ext(i)( 83) + mult_res_ext(i)(147) + mult_res_ext(i)(211);
              mult_sum64(i)(20) <= mult_res_ext(i)(20) + mult_res_ext(i)( 84) + mult_res_ext(i)(148) + mult_res_ext(i)(212);
              mult_sum64(i)(21) <= mult_res_ext(i)(21) + mult_res_ext(i)( 85) + mult_res_ext(i)(149) + mult_res_ext(i)(213);
              mult_sum64(i)(22) <= mult_res_ext(i)(22) + mult_res_ext(i)( 86) + mult_res_ext(i)(150) + mult_res_ext(i)(214);
              mult_sum64(i)(23) <= mult_res_ext(i)(23) + mult_res_ext(i)( 87) + mult_res_ext(i)(151) + mult_res_ext(i)(215);
              mult_sum64(i)(24) <= mult_res_ext(i)(24) + mult_res_ext(i)( 88) + mult_res_ext(i)(152) + mult_res_ext(i)(216);
              mult_sum64(i)(25) <= mult_res_ext(i)(25) + mult_res_ext(i)( 89) + mult_res_ext(i)(153) + mult_res_ext(i)(217);
              mult_sum64(i)(26) <= mult_res_ext(i)(26) + mult_res_ext(i)( 90) + mult_res_ext(i)(154) + mult_res_ext(i)(218);
              mult_sum64(i)(27) <= mult_res_ext(i)(27) + mult_res_ext(i)( 91) + mult_res_ext(i)(155) + mult_res_ext(i)(219);
              mult_sum64(i)(28) <= mult_res_ext(i)(28) + mult_res_ext(i)( 92) + mult_res_ext(i)(156) + mult_res_ext(i)(220);
              mult_sum64(i)(29) <= mult_res_ext(i)(29) + mult_res_ext(i)( 93) + mult_res_ext(i)(157) + mult_res_ext(i)(221);
              mult_sum64(i)(30) <= mult_res_ext(i)(30) + mult_res_ext(i)( 94) + mult_res_ext(i)(158) + mult_res_ext(i)(222);
              mult_sum64(i)(31) <= mult_res_ext(i)(31) + mult_res_ext(i)( 95) + mult_res_ext(i)(159) + mult_res_ext(i)(223);
              mult_sum64(i)(32) <= mult_res_ext(i)(32) + mult_res_ext(i)( 96) + mult_res_ext(i)(160) + mult_res_ext(i)(224);
              mult_sum64(i)(33) <= mult_res_ext(i)(33) + mult_res_ext(i)( 97) + mult_res_ext(i)(161) + mult_res_ext(i)(225);
              mult_sum64(i)(34) <= mult_res_ext(i)(34) + mult_res_ext(i)( 98) + mult_res_ext(i)(162) + mult_res_ext(i)(226);
              mult_sum64(i)(35) <= mult_res_ext(i)(35) + mult_res_ext(i)( 99) + mult_res_ext(i)(163) + mult_res_ext(i)(227);
              mult_sum64(i)(36) <= mult_res_ext(i)(36) + mult_res_ext(i)(100) + mult_res_ext(i)(164) + mult_res_ext(i)(228);
              mult_sum64(i)(37) <= mult_res_ext(i)(37) + mult_res_ext(i)(101) + mult_res_ext(i)(165) + mult_res_ext(i)(229);
              mult_sum64(i)(38) <= mult_res_ext(i)(38) + mult_res_ext(i)(102) + mult_res_ext(i)(166) + mult_res_ext(i)(230);
              mult_sum64(i)(39) <= mult_res_ext(i)(39) + mult_res_ext(i)(103) + mult_res_ext(i)(167) + mult_res_ext(i)(231);
              mult_sum64(i)(40) <= mult_res_ext(i)(40) + mult_res_ext(i)(104) + mult_res_ext(i)(168) + mult_res_ext(i)(232);
              mult_sum64(i)(41) <= mult_res_ext(i)(41) + mult_res_ext(i)(105) + mult_res_ext(i)(169) + mult_res_ext(i)(233);
              mult_sum64(i)(42) <= mult_res_ext(i)(42) + mult_res_ext(i)(106) + mult_res_ext(i)(170) + mult_res_ext(i)(234);
              mult_sum64(i)(43) <= mult_res_ext(i)(43) + mult_res_ext(i)(107) + mult_res_ext(i)(171) + mult_res_ext(i)(235);
              mult_sum64(i)(44) <= mult_res_ext(i)(44) + mult_res_ext(i)(108) + mult_res_ext(i)(172) + mult_res_ext(i)(236);
              mult_sum64(i)(45) <= mult_res_ext(i)(45) + mult_res_ext(i)(109) + mult_res_ext(i)(173) + mult_res_ext(i)(237);
              mult_sum64(i)(46) <= mult_res_ext(i)(46) + mult_res_ext(i)(110) + mult_res_ext(i)(174) + mult_res_ext(i)(238);
              mult_sum64(i)(47) <= mult_res_ext(i)(47) + mult_res_ext(i)(111) + mult_res_ext(i)(175) + mult_res_ext(i)(239);
              mult_sum64(i)(48) <= mult_res_ext(i)(48) + mult_res_ext(i)(112) + mult_res_ext(i)(176) + mult_res_ext(i)(240);
              mult_sum64(i)(49) <= mult_res_ext(i)(49) + mult_res_ext(i)(113) + mult_res_ext(i)(177) + mult_res_ext(i)(241);
              mult_sum64(i)(50) <= mult_res_ext(i)(50) + mult_res_ext(i)(114) + mult_res_ext(i)(178) + mult_res_ext(i)(242);
              mult_sum64(i)(51) <= mult_res_ext(i)(51) + mult_res_ext(i)(115) + mult_res_ext(i)(179) + mult_res_ext(i)(243);
              mult_sum64(i)(52) <= mult_res_ext(i)(52) + mult_res_ext(i)(116) + mult_res_ext(i)(180) + mult_res_ext(i)(244);
              mult_sum64(i)(53) <= mult_res_ext(i)(53) + mult_res_ext(i)(117) + mult_res_ext(i)(181) + mult_res_ext(i)(245);
              mult_sum64(i)(54) <= mult_res_ext(i)(54) + mult_res_ext(i)(118) + mult_res_ext(i)(182) + mult_res_ext(i)(246);
              mult_sum64(i)(55) <= mult_res_ext(i)(55) + mult_res_ext(i)(119) + mult_res_ext(i)(183) + mult_res_ext(i)(247);
              mult_sum64(i)(56) <= mult_res_ext(i)(56) + mult_res_ext(i)(120) + mult_res_ext(i)(184) + mult_res_ext(i)(248);
              mult_sum64(i)(57) <= mult_res_ext(i)(57) + mult_res_ext(i)(121) + mult_res_ext(i)(185) + mult_res_ext(i)(249);
              mult_sum64(i)(58) <= mult_res_ext(i)(58) + mult_res_ext(i)(122) + mult_res_ext(i)(186) + mult_res_ext(i)(250);
              mult_sum64(i)(59) <= mult_res_ext(i)(59) + mult_res_ext(i)(123) + mult_res_ext(i)(187) + mult_res_ext(i)(251);
              mult_sum64(i)(60) <= mult_res_ext(i)(60) + mult_res_ext(i)(124) + mult_res_ext(i)(188) + mult_res_ext(i)(252);
              mult_sum64(i)(61) <= mult_res_ext(i)(61) + mult_res_ext(i)(125) + mult_res_ext(i)(189) + mult_res_ext(i)(253);
              mult_sum64(i)(62) <= mult_res_ext(i)(62) + mult_res_ext(i)(126) + mult_res_ext(i)(190) + mult_res_ext(i)(254);
              mult_sum64(i)(63) <= mult_res_ext(i)(63) + mult_res_ext(i)(127) + mult_res_ext(i)(191) + mult_res_ext(i)(255);
           end loop input_mult_for;
        --end if;
     end if;
   end process p_mult_add;

   en_mult_p: process (clk,rst)
   begin
     if rst = '1' then
        en_64  <= '0'; 
        sof_64 <= '0';
        eof_64 <= '0';
     elsif rising_edge(clk) then
        en_64  <= en_mult;
        sof_64 <= sof_mult;
        eof_64 <= eof_mult;
     end if;
   end process en_mult_p;

end generate add64p;

add64c: if CL_inputs <= 64 generate
      input_mult_for: for i in 0 to CL_outs-1 generate
         mult_sum64(i)( 0) <= mult_res_ext(i)( 0);
         mult_sum64(i)( 1) <= mult_res_ext(i)( 1);
         mult_sum64(i)( 2) <= mult_res_ext(i)( 2);
         mult_sum64(i)( 3) <= mult_res_ext(i)( 3);
         mult_sum64(i)( 4) <= mult_res_ext(i)( 4);
         mult_sum64(i)( 5) <= mult_res_ext(i)( 5);
         mult_sum64(i)( 6) <= mult_res_ext(i)( 6);
         mult_sum64(i)( 7) <= mult_res_ext(i)( 7);
         mult_sum64(i)( 8) <= mult_res_ext(i)( 8);
         mult_sum64(i)( 9) <= mult_res_ext(i)( 9);
         mult_sum64(i)(10) <= mult_res_ext(i)(10);
         mult_sum64(i)(11) <= mult_res_ext(i)(11);
         mult_sum64(i)(12) <= mult_res_ext(i)(12);
         mult_sum64(i)(13) <= mult_res_ext(i)(13);
         mult_sum64(i)(14) <= mult_res_ext(i)(14);
         mult_sum64(i)(15) <= mult_res_ext(i)(15);
         mult_sum64(i)(16) <= mult_res_ext(i)(16);
         mult_sum64(i)(17) <= mult_res_ext(i)(17);
         mult_sum64(i)(18) <= mult_res_ext(i)(18);
         mult_sum64(i)(19) <= mult_res_ext(i)(19);
         mult_sum64(i)(20) <= mult_res_ext(i)(20);
         mult_sum64(i)(21) <= mult_res_ext(i)(21);
         mult_sum64(i)(22) <= mult_res_ext(i)(22);
         mult_sum64(i)(23) <= mult_res_ext(i)(23);
         mult_sum64(i)(24) <= mult_res_ext(i)(24);
         mult_sum64(i)(25) <= mult_res_ext(i)(25);
         mult_sum64(i)(26) <= mult_res_ext(i)(26);
         mult_sum64(i)(27) <= mult_res_ext(i)(27);
         mult_sum64(i)(28) <= mult_res_ext(i)(28);
         mult_sum64(i)(29) <= mult_res_ext(i)(29);
         mult_sum64(i)(30) <= mult_res_ext(i)(30);
         mult_sum64(i)(31) <= mult_res_ext(i)(31);
         mult_sum64(i)(32) <= mult_res_ext(i)(32);
         mult_sum64(i)(33) <= mult_res_ext(i)(33);
         mult_sum64(i)(34) <= mult_res_ext(i)(34);
         mult_sum64(i)(35) <= mult_res_ext(i)(35);
         mult_sum64(i)(36) <= mult_res_ext(i)(36);
         mult_sum64(i)(37) <= mult_res_ext(i)(37);
         mult_sum64(i)(38) <= mult_res_ext(i)(38);
         mult_sum64(i)(39) <= mult_res_ext(i)(39);
         mult_sum64(i)(40) <= mult_res_ext(i)(40);
         mult_sum64(i)(41) <= mult_res_ext(i)(41);
         mult_sum64(i)(42) <= mult_res_ext(i)(42);
         mult_sum64(i)(43) <= mult_res_ext(i)(43);
         mult_sum64(i)(44) <= mult_res_ext(i)(44);
         mult_sum64(i)(45) <= mult_res_ext(i)(45);
         mult_sum64(i)(46) <= mult_res_ext(i)(46);
         mult_sum64(i)(47) <= mult_res_ext(i)(47);
         mult_sum64(i)(48) <= mult_res_ext(i)(48);
         mult_sum64(i)(49) <= mult_res_ext(i)(49);
         mult_sum64(i)(50) <= mult_res_ext(i)(50);
         mult_sum64(i)(51) <= mult_res_ext(i)(51);
         mult_sum64(i)(52) <= mult_res_ext(i)(52);
         mult_sum64(i)(53) <= mult_res_ext(i)(53);
         mult_sum64(i)(54) <= mult_res_ext(i)(54);
         mult_sum64(i)(55) <= mult_res_ext(i)(55);
         mult_sum64(i)(56) <= mult_res_ext(i)(56);
         mult_sum64(i)(57) <= mult_res_ext(i)(57);
         mult_sum64(i)(58) <= mult_res_ext(i)(58);
         mult_sum64(i)(59) <= mult_res_ext(i)(59);
         mult_sum64(i)(60) <= mult_res_ext(i)(60);
         mult_sum64(i)(61) <= mult_res_ext(i)(61);
         mult_sum64(i)(62) <= mult_res_ext(i)(62);
         mult_sum64(i)(63) <= mult_res_ext(i)(63);
      end generate input_mult_for;

      en_64  <= en_mult;
      sof_64 <= sof_mult;
      eof_64 <= eof_mult;

end generate add64c;


----------------------------------
---     Middle stage
----------------------------------

add16p: if CL_inputs > 16 generate
   p_mult_add : process (clk)
   begin
     if rising_edge(clk) then
           input_mult_for: for i in 0 to CL_outs-1 loop
              mult_sum16(i)( 0) <= mult_sum64(i)( 0) + mult_sum64(i)(16) + mult_sum64(i)(32) + mult_sum64(i)(48); 
              mult_sum16(i)( 1) <= mult_sum64(i)( 1) + mult_sum64(i)(17) + mult_sum64(i)(33) + mult_sum64(i)(49); 
              mult_sum16(i)( 2) <= mult_sum64(i)( 2) + mult_sum64(i)(18) + mult_sum64(i)(34) + mult_sum64(i)(50); 
              mult_sum16(i)( 3) <= mult_sum64(i)( 3) + mult_sum64(i)(19) + mult_sum64(i)(35) + mult_sum64(i)(51);
              mult_sum16(i)( 4) <= mult_sum64(i)( 4) + mult_sum64(i)(20) + mult_sum64(i)(36) + mult_sum64(i)(52); 
              mult_sum16(i)( 5) <= mult_sum64(i)( 5) + mult_sum64(i)(21) + mult_sum64(i)(37) + mult_sum64(i)(53); 
              mult_sum16(i)( 6) <= mult_sum64(i)( 6) + mult_sum64(i)(22) + mult_sum64(i)(38) + mult_sum64(i)(54); 
              mult_sum16(i)( 7) <= mult_sum64(i)( 7) + mult_sum64(i)(23) + mult_sum64(i)(39) + mult_sum64(i)(55);
              mult_sum16(i)( 8) <= mult_sum64(i)( 8) + mult_sum64(i)(24) + mult_sum64(i)(40) + mult_sum64(i)(56); 
              mult_sum16(i)( 9) <= mult_sum64(i)( 9) + mult_sum64(i)(25) + mult_sum64(i)(41) + mult_sum64(i)(57); 
              mult_sum16(i)(10) <= mult_sum64(i)(10) + mult_sum64(i)(26) + mult_sum64(i)(42) + mult_sum64(i)(58); 
              mult_sum16(i)(11) <= mult_sum64(i)(11) + mult_sum64(i)(27) + mult_sum64(i)(43) + mult_sum64(i)(59);
              mult_sum16(i)(12) <= mult_sum64(i)(12) + mult_sum64(i)(28) + mult_sum64(i)(44) + mult_sum64(i)(60); 
              mult_sum16(i)(13) <= mult_sum64(i)(13) + mult_sum64(i)(29) + mult_sum64(i)(45) + mult_sum64(i)(61); 
              mult_sum16(i)(14) <= mult_sum64(i)(14) + mult_sum64(i)(30) + mult_sum64(i)(46) + mult_sum64(i)(62); 
              mult_sum16(i)(15) <= mult_sum64(i)(15) + mult_sum64(i)(31) + mult_sum64(i)(47) + mult_sum64(i)(63);
           end loop input_mult_for;
     end if;
   end process p_mult_add;

   en_mult_p: process (clk,rst)
   begin
     if rst = '1' then
        en_16  <= '0'; 
        sof_16 <= '0';
        eof_16 <= '0';
     elsif rising_edge(clk) then
        en_16  <= en_64  ;
        sof_16 <= sof_64 ;
        eof_16 <= eof_64 ;
     end if;
   end process en_mult_p;

end generate add16p;


add16c: if CL_inputs <= 16 generate
      input_mult_for: for i in 0 to CL_outs-1 generate
         mult_sum16(i)( 0) <= mult_res_ext(i)( 0); 
         mult_sum16(i)( 1) <= mult_res_ext(i)( 1); 
         mult_sum16(i)( 2) <= mult_res_ext(i)( 2); 
         mult_sum16(i)( 3) <= mult_res_ext(i)( 3);
         mult_sum16(i)( 4) <= mult_res_ext(i)( 4); 
         mult_sum16(i)( 5) <= mult_res_ext(i)( 5); 
         mult_sum16(i)( 6) <= mult_res_ext(i)( 6); 
         mult_sum16(i)( 7) <= mult_res_ext(i)( 7);
         mult_sum16(i)( 8) <= mult_res_ext(i)( 8); 
         mult_sum16(i)( 9) <= mult_res_ext(i)( 9); 
         mult_sum16(i)(10) <= mult_res_ext(i)(10); 
         mult_sum16(i)(11) <= mult_res_ext(i)(11);
         mult_sum16(i)(12) <= mult_res_ext(i)(12); 
         mult_sum16(i)(13) <= mult_res_ext(i)(13); 
         mult_sum16(i)(14) <= mult_res_ext(i)(14); 
         mult_sum16(i)(15) <= mult_res_ext(i)(15);
      end generate input_mult_for;
      en_16  <= en_64  ;
      sof_16 <= sof_64 ;
      eof_16 <= eof_64 ;
end generate add16c;

------------------------------------
-----     Last stage
------------------------------------
add4b: if CL_inputs > 4 generate
   p_mult_add : process (clk)
   begin
     if rising_edge(clk) then
           input_mult_for: for i in 0 to CL_outs-1 loop
              mult_sum4(i)(0) <= mult_sum16(i)(0) + mult_sum16(i)(4) + mult_sum16(i)( 8) + mult_sum16(i)(12); 
              mult_sum4(i)(1) <= mult_sum16(i)(1) + mult_sum16(i)(5) + mult_sum16(i)( 9) + mult_sum16(i)(13); 
              mult_sum4(i)(2) <= mult_sum16(i)(2) + mult_sum16(i)(6) + mult_sum16(i)(10) + mult_sum16(i)(14); 
              mult_sum4(i)(3) <= mult_sum16(i)(3) + mult_sum16(i)(7) + mult_sum16(i)(11) + mult_sum16(i)(15);
           end loop input_mult_for;
     end if;
   end process p_mult_add;

   en_mult_p: process (clk,rst)
   begin
     if rst = '1' then
        en_4  <= '0'; 
        sof_4 <= '0';
        eof_4 <= '0';
     elsif rising_edge(clk) then
        en_4  <= en_16  ;
        sof_4 <= sof_16 ;
        eof_4 <= eof_16 ;
     end if;
   end process en_mult_p;
end generate add4b;


add4l: if CL_inputs <= 4 generate
      input_mult_for: for i in 0 to CL_outs-1 generate
         mult_sum4(i)(0) <= mult_res_ext(i)(0); 
         mult_sum4(i)(1) <= mult_res_ext(i)(1); 
         mult_sum4(i)(2) <= mult_res_ext(i)(2); 
         mult_sum4(i)(3) <= mult_res_ext(i)(3);
      end generate input_mult_for;
      en_4  <= en_16  ;
      sof_4 <= sof_16 ;
      eof_4 <= eof_16 ;
end generate add4l;



   p_mult_add16 : process (clk)
   begin
     if rising_edge(clk) then
        --if en_in = '1' then
           input_mult_for: for i in 0 to CL_outs-1 loop
              mult_sum01(i) <= mult_sum4(i)(0) + mult_sum4(i)(1) + mult_sum4(i)(2) + mult_sum4(i)(3);
              --acc(i) <= mult_sum4(i)(0) + mult_sum4(i)(1) + mult_sum4(i)(2) + mult_sum4(i)(3);
           end loop input_mult_for;
        --end if;
     end if;
   end process p_mult_add16;

   en_mult_p: process (clk,rst)
   begin
     if rst = '1' then
        en_01    <= '0';
        sof_01   <= '0';        
        eof_01   <= '0';          
     elsif rising_edge(clk) then
        en_01    <= en_4  ;
        sof_01   <= sof_4 ;
        eof_01   <= eof_4 ;
     end if;
   end process en_mult_p;

   acc_p: process (clk,rst)
   begin
     if rst = '1' then
        en_acc  <= '0';    
        acc     <= (others => (others => '0'));
     elsif rising_edge(clk) then
        en_acc  <= eof_01; 
        input_mult_for: for i in 0 to CL_outs-1 loop
           if en_acc = '1' then
              if en_01 = '0' then                 -- wait state after enf of current state
                 acc(i) <= (others => '0');
              else                                -- new frame immediately after the current
                 acc(i) <= mult_sum01(i);
              end if; 
           else
              if en_01 = '1' then
                 acc(i) <= acc(i) + mult_sum01(i);
              end if;
           end if; 
        end loop input_mult_for;
     end if;
   end process acc_p;


-----------------------------------------
---------- Generic FOR (one stage) ------
-----------------------------------------
---   p_mult_add : process (clk, rst)
---   variable tmp : vec(0 to CL_outs -1)(N+M+7 downto 0);
---   begin
---     if rst = '1' then
---        acc  <= (others => (others => '0'));  
---     elsif rising_edge(clk) then
---        if en_in = '1' then
---           input_mult_for: for j in 0 to CL_outs-1 loop
---            tmp(j) := (others => '0');
---              mult_in_for: for i in 0 to CL_inputs-1 loop
---                   tmp(j) := tmp(j) + mult_res_ext(j)(i);
---              end loop mult_in_for;
---              acc(j) <= tmp(j);
---           end loop input_mult_for;
---        end if;
---     end if;
---   end process p_mult_add;


------------ extention total adder
---process (clk)
---
---variable tmp : vec(0 to CL_outs -1)(N-1 downto 0);
---
---begin
---   if rising_edge(clk) then
---      gen_inCL: for J in 0 to max_input_num-1 loop
---      gen_CL: for I in 0 to CL_outs-1 loop
---         tmp(I) := tmp(I) + d_exten(J)(I);
---      end loop gen_CL;
---      end loop gen_inCL;
---      
---      d_sum <= tmp;
---   end if;
---
---end process;

p_relu : process (clk)
begin
  if rising_edge(clk) then
    if Relu = "yes" then
       relu_outs_for: for i in 0 to CL_outs-1 loop
          relu_bits_for: for j in 0 to accM loop
             d_relu(i)(j) <= acc(i)(j) and not acc(i)(accM);    -- if MSB=1 (negative) thwen all bits are 0
          end loop relu_bits_for;
       end loop relu_outs_for;
    else
       d_relu <= acc;
    end if;
  end if;
end process p_relu;

en_p: process (clk,rst)
begin
  if rst = '1' then
     en_relu  <= '0'     ;
     en_out   <= '0'     ;
  elsif rising_edge(clk) then
     en_relu  <= en_acc  ;
     en_out   <= en_relu ;
  end if;
end process en_p;

 -- check overflow before shift and change value to maximum if overflow occurs
   p_ovf : process (clk)
  begin
    if rising_edge(clk) then
       ovf_for: for i in 0 to CL_outs-1 loop
          if d_relu(i)(d_relu'left  downto W + SR -2) = 0  then
             d_ovf(i) <= d_relu(i);
          else
             d_ovf(i)( d_relu'left  downto W + SR -2 ) <= (others => '0'); 
             d_ovf(i)( W + SR - 3   downto         0 ) <= (others => '1'); 
          end if;
       end loop ovf_for;
    end if;
  end process p_ovf;

out_cut_for: for i in 0 to CL_outs-1 generate
   d_out(i) <= d_ovf(i)(W + SR - 1 downto SR);
end generate out_cut_for;


end a;