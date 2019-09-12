library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;


entity Pooling_calc is
  generic (
           --Relu          : string := "yes"; --"no"/"yes"  -- nonlinear Relu function
           BP            : string := "no";  --"no"/"yes"  -- Bypass
           TP            : string := "no";  --"no"/"yes"  -- Test pattern output
           poll_criteria : string := "max"; --"max"/"average" -                    average -> TBD!!!! !
           Kernel_size   : integer := 3; -- 3/5
           N             : integer := 8 -- input data width
  	       );
  port    (
           clk         : in std_logic;
           rst         : in std_logic;
           data2pool1  : in std_logic_vector (N-1 downto 0);
           data2pool2  : in std_logic_vector (N-1 downto 0);
           data2pool3  : in std_logic_vector (N-1 downto 0);
           data2pool4  : in std_logic_vector (N-1 downto 0);
           data2pool5  : in std_logic_vector (N-1 downto 0);
           data2pool6  : in std_logic_vector (N-1 downto 0);
           data2pool7  : in std_logic_vector (N-1 downto 0);
           data2pool8  : in std_logic_vector (N-1 downto 0);
           data2pool9  : in std_logic_vector (N-1 downto 0);
           data2pool10 : in std_logic_vector (N-1 downto 0);
           data2pool11 : in std_logic_vector (N-1 downto 0);
           data2pool12 : in std_logic_vector (N-1 downto 0);
           data2pool13 : in std_logic_vector (N-1 downto 0);
           data2pool14 : in std_logic_vector (N-1 downto 0);
           data2pool15 : in std_logic_vector (N-1 downto 0);
           data2pool16 : in std_logic_vector (N-1 downto 0);
           data2pool17 : in std_logic_vector (N-1 downto 0);
           data2pool18 : in std_logic_vector (N-1 downto 0);
           data2pool19 : in std_logic_vector (N-1 downto 0);
           data2pool20 : in std_logic_vector (N-1 downto 0);
           data2pool21 : in std_logic_vector (N-1 downto 0);
           data2pool22 : in std_logic_vector (N-1 downto 0);
           data2pool23 : in std_logic_vector (N-1 downto 0);
           data2pool24 : in std_logic_vector (N-1 downto 0);
           data2pool25 : in std_logic_vector (N-1 downto 0);
  	       en_in       : in std_logic;
  	       sof_in      : in std_logic; -- start of frame
  	       --sol     : in std_logic; -- start of line
  	       --eof     : in std_logic; -- end of frame

           d_out       : out std_logic_vector (N -1 downto 0);
           en_out      : out std_logic;
           sof_out     : out std_logic);
end Pooling_calc;

architecture a of Pooling_calc is

component Max3 is
  generic (
           N             : integer := 8 -- input data width
           );
  port    (
           d_in1  : in std_logic_vector (N-1 downto 0);
           d_in2  : in std_logic_vector (N-1 downto 0);
           d_in3  : in std_logic_vector (N-1 downto 0);

           d_out       : out std_logic_vector (N-1 downto 0));
end component;

constant EN_BIT  : integer range 0 to 1 := 0;
constant SOF_BIT : integer range 0 to 1 := 1;

--- >> bin2dec('111000111')/2^12              (    455) 
--- >> bin2dec('111000111000111')/2^18        (  29127)
--- >> bin2dec('111000111000111000111')/2^24  (1864135)

constant One_div_9_dividend : std_logic_vector(9-1 downto 0):= "111000111";
constant One_div_9_divisor  : integer := 12;

--  >> bin2dec('1010001111010111')/2^20
--    ans = 0.0400
constant One_div_25_dividend : std_logic_vector(16-1 downto 0):= "1010001111010111";
constant One_div_25_divisor  : integer := 20;


signal     en_in1, en_in2, en_in3, en_in4 : std_logic_vector(1 downto 0) ;

signal data2pool25_d : std_logic_vector (N -1 downto 0);

signal c01         : std_logic_vector (N -1 downto 0);
signal c02         : std_logic_vector (N -1 downto 0);
signal c03         : std_logic_vector (N -1 downto 0);
signal c04         : std_logic_vector (N -1 downto 0);
signal c05         : std_logic_vector (N -1 downto 0);
signal c06         : std_logic_vector (N -1 downto 0);
signal c07         : std_logic_vector (N -1 downto 0);
signal c08         : std_logic_vector (N -1 downto 0);

signal c01_d       : std_logic_vector (N -1 downto 0);
signal c02_d       : std_logic_vector (N -1 downto 0);
signal c03_d       : std_logic_vector (N -1 downto 0);
signal c04_d       : std_logic_vector (N -1 downto 0);
signal c05_d       : std_logic_vector (N -1 downto 0);
signal c06_d       : std_logic_vector (N -1 downto 0);
signal c07_d       : std_logic_vector (N -1 downto 0);
signal c08_d       : std_logic_vector (N -1 downto 0);

signal d01         : std_logic_vector (N -1 downto 0);
signal d02         : std_logic_vector (N -1 downto 0);
signal d03         : std_logic_vector (N -1 downto 0);
signal d01_d       : std_logic_vector (N -1 downto 0);
signal d02_d       : std_logic_vector (N -1 downto 0);
signal d03_d       : std_logic_vector (N -1 downto 0);

signal m25         : std_logic_vector (N -1 downto 0);

signal s1         : std_logic_vector (N +1 downto 0);
signal s2         : std_logic_vector (N +1 downto 0);
signal s3         : std_logic_vector (N +1 downto 0);
signal s4         : std_logic_vector (N +1 downto 0);
signal s5         : std_logic_vector (N +1 downto 0);
signal s6         : std_logic_vector (N +1 downto 0);
signal s7         : std_logic_vector (N +1 downto 0);

signal sum9       : std_logic_vector (N +3 downto 0);
signal sum9plus   : std_logic_vector (N +3 downto 0);

signal sum25       : std_logic_vector (N +4 downto 0);

signal div9m       : std_logic_vector (N +4+24 downto 0);
signal div25m      : std_logic_vector (N +4+24 downto 0);

signal div9        : std_logic_vector (N +4+24 downto 0);
signal div25       : std_logic_vector (N +4+24 downto 0);

begin

gen_no_BP: if BP = "no" and TP = "no" generate 

gen_Max: if poll_criteria = "max" generate 

   max_1_3 : Max3 generic map (N) port map (data2pool1, data2pool2, data2pool3, c01);
   max_4_6 : Max3 generic map (N) port map (data2pool4, data2pool5, data2pool6, c02);
   max_7_9 : Max3 generic map (N) port map (data2pool7, data2pool8, data2pool9, c03);
   max_1_9 : Max3 generic map (N) port map (c01_d     , c02_d     , c03_d     , d01);
   
     p_max_sample : process (clk)
     begin
       if rising_edge(clk) then
          c01_d <= c01;
          c02_d <= c02;
          c03_d <= c03;
          d01_d <= d01;
       end if;
     end process p_max_sample;
   
   
   Ks5max: if Kernel_size = 5 generate
      max_10_12 : Max3 generic map (N) port map (data2pool10, data2pool11, data2pool12, c04);
      max_13_15 : Max3 generic map (N) port map (data2pool13, data2pool14, data2pool15, c05);
      max_16_18 : Max3 generic map (N) port map (data2pool16, data2pool17, data2pool18, c06);
      max_19_21 : Max3 generic map (N) port map (data2pool19, data2pool20, data2pool21, c07);
      max_22_24 : Max3 generic map (N) port map (data2pool22, data2pool23, data2pool24, c08);
      
      max_10_18 : Max3 generic map (N) port map (c04_d     , c05_d     , c06_d        , d02);
      max_19_25 : Max3 generic map (N) port map (c07_d     , c08_d     , data2pool25_d, d03);
      
      max_01_25 : Max3 generic map (N) port map (d01_d     , d02_d     , d03_d        , m25);
        p_max_sample : process (clk)
        begin
          if rising_edge(clk) then
             c04_d <= c04;
             c05_d <= c05;
             c06_d <= c06;
             c07_d <= c07;
             c08_d <= c08;
             data2pool25_d <= data2pool25;
             d02_d <= d02;
             d03_d <= d03;
          end if;
        end process p_max_sample;
   
   end generate; -- Kernel_size = 5
   
     p_en : process (clk,rst)
     begin
       if rst = '1' then
          en_in1  <= (others => '0');
          en_in2  <= (others => '0');
          en_in3  <= (others => '0');
          --en_in4  <= (others => '0');
       elsif rising_edge(clk) then
          en_in1(EN_BIT)  <= en_in;    
          en_in1(SOF_BIT) <= sof_in;
          en_in2 <= en_in1;
          en_in3 <= en_in2;
          --en_in4 <= en_in3;
       end if;
     end process p_en;
   
   Ks3: if Kernel_size = 3 generate
      d_out   <= d01;    
      en_out  <= en_in2(EN_BIT );    
      sof_out <= en_in2(SOF_BIT);    
   end generate;
   
   Ks5: if Kernel_size = 5 generate
      d_out   <= m25;    
      en_out  <= en_in3(EN_BIT );    
      sof_out <= en_in3(SOF_BIT);    
   end generate;

end generate;  --gen_Max   , mult_sum = "mult"

gen_Average: if poll_criteria = "average" generate 

   p_sum1 : process (clk)
   begin
     if rising_edge(clk) then
        s1 <= (data2pool1 (data2pool1 'left) & data2pool1 (data2pool1 'left) & data2pool1 ) + 
              (data2pool2 (data2pool2 'left) & data2pool2 (data2pool2 'left) & data2pool2 ) + 
              (data2pool3 (data2pool3 'left) & data2pool3 (data2pool3 'left) & data2pool3 ) ;
        s2 <= (data2pool4 (data2pool4 'left) & data2pool4 (data2pool4 'left) & data2pool4 ) + 
              (data2pool5 (data2pool5 'left) & data2pool5 (data2pool5 'left) & data2pool5 ) + 
              (data2pool6 (data2pool6 'left) & data2pool6 (data2pool6 'left) & data2pool6 ) ;  
        s3 <= (data2pool7 (data2pool7 'left) & data2pool7 (data2pool7 'left) & data2pool7 ) + 
              (data2pool8 (data2pool8 'left) & data2pool8 (data2pool8 'left) & data2pool8 ) + 
              (data2pool9 (data2pool9 'left) & data2pool9 (data2pool9 'left) & data2pool9 ) ;  
        if  Kernel_size = 5 then
          s4 <= (data2pool10(data2pool10'left) & data2pool10(data2pool10'left) & data2pool10) + 
                (data2pool11(data2pool11'left) & data2pool11(data2pool11'left) & data2pool11) + 
                (data2pool12(data2pool12'left) & data2pool12(data2pool12'left) & data2pool12) + 
                (data2pool13(data2pool13'left) & data2pool13(data2pool13'left) & data2pool13) ; 
          s5 <= (data2pool14(data2pool14'left) & data2pool14(data2pool14'left) & data2pool14) + 
                (data2pool15(data2pool15'left) & data2pool15(data2pool15'left) & data2pool15) + 
                (data2pool16(data2pool16'left) & data2pool16(data2pool16'left) & data2pool16) + 
                (data2pool17(data2pool17'left) & data2pool17(data2pool17'left) & data2pool17) ; 
          s6 <= (data2pool18(data2pool18'left) & data2pool18(data2pool18'left) & data2pool18) + 
                (data2pool19(data2pool19'left) & data2pool19(data2pool19'left) & data2pool19) + 
                (data2pool20(data2pool20'left) & data2pool20(data2pool20'left) & data2pool20) + 
                (data2pool21(data2pool21'left) & data2pool21(data2pool21'left) & data2pool21) ; 
          s7 <= (data2pool22(data2pool22'left) & data2pool22(data2pool22'left) & data2pool22) + 
                (data2pool23(data2pool23'left) & data2pool23(data2pool23'left) & data2pool23) + 
                (data2pool24(data2pool24'left) & data2pool24(data2pool24'left) & data2pool24) + 
                (data2pool25(data2pool25'left) & data2pool25(data2pool25'left) & data2pool25) ; 
        end if;

        sum9    <= (s1(s1'left) & s1(s1'left) & s1) + 
                   (s2(s2'left) & s2(s2'left) & s2) + 
                   (s3(s3'left) & s3(s3'left) & s3) ; 
        if  Kernel_size = 5 then
           sum9plus <=(s4(s4'left) & s4(s4'left) & s4) + 
                      (s5(s5'left) & s5(s5'left) & s5) + 
                      (s6(s6'left) & s6(s6'left) & s6) + 
                      (s7(s7'left) & s7(s7'left) & s7) ; 
           sum25 <=   (sum9    (sum9    'left) & sum9    ) +
                      (sum9plus(sum9plus'left) & sum9plus) ;
        end if;

        --div9m   <= sum9  * 1864135 + 1;
        --div25m  <= sum25 *   41943 + 1;
        div9   <= div9;
        div25  <= div25;
     end if;
   end process p_sum1;



end generate;  -- gen_Average:  poll_criteria = "average" 

end generate;  -- gen_no_BP, BP = "no" and TP = "no"


gen_TP_out: if BP = "no" and TP = "yes" generate 
  
end generate; -- TP = "yes"

gen_BP: if BP = "yes" generate 


end generate; --  BP = "yes"

end a;