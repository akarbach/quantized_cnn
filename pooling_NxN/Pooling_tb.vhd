library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;

entity Pooling_tb is
  generic (
           BP            : string := "no";  --"no"/"yes"  -- Bypass
           TP            : string := "no";  --"no"/"yes"  -- Test pattern output
           poll_criteria : string := "average"; --"max"/"average"
           Kernel_size   : integer := 5; -- 3/5
           N             : integer := 16 -- input data widtht
           );
end entity Pooling_tb;

architecture a of Pooling_tb is

component Pooling_calc is
  generic (
           --Relu          : string := "yes"; --"no"/"yes"  -- nonlinear Relu function
           BP            : string := "no";  --"no"/"yes"  -- Bypass
           TP            : string := "no";  --"no"/"yes"  -- Test pattern output
           poll_criteria : string := "max"; --"max"/"average"
           Kernel_size   : integer := 3; -- 3/5
           N             : integer := 8 -- input data widtht
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

           d_out       : out std_logic_vector (N -1 downto 0);
           en_out      : out std_logic;
           sof_out     : out std_logic);
end component;

signal clk         : std_logic;
signal rst         : std_logic;
signal data2pool1  : std_logic_vector (N-1 downto 0) := conv_std_logic_vector( 1004, N);
signal data2pool2  : std_logic_vector (N-1 downto 0) := conv_std_logic_vector( 1001, N);
signal data2pool3  : std_logic_vector (N-1 downto 0) := conv_std_logic_vector( -7, N);
signal data2pool4  : std_logic_vector (N-1 downto 0) := conv_std_logic_vector( 1003, N);
signal data2pool5  : std_logic_vector (N-1 downto 0) := conv_std_logic_vector( 6, N);
signal data2pool6  : std_logic_vector (N-1 downto 0) := conv_std_logic_vector( 8, N);
signal data2pool7  : std_logic_vector (N-1 downto 0) := conv_std_logic_vector( 2, N);
signal data2pool8  : std_logic_vector (N-1 downto 0) := conv_std_logic_vector( 1, N);
signal data2pool9  : std_logic_vector (N-1 downto 0) := conv_std_logic_vector( 9, N);

signal data2pool10 : std_logic_vector (N-1 downto 0) := conv_std_logic_vector( 6, N);
signal data2pool11 : std_logic_vector (N-1 downto 0) := conv_std_logic_vector( 1003, N);
signal data2pool12 : std_logic_vector (N-1 downto 0) := conv_std_logic_vector( 2, N);
signal data2pool13 : std_logic_vector (N-1 downto 0) := conv_std_logic_vector( 6, N);
signal data2pool14 : std_logic_vector (N-1 downto 0) := conv_std_logic_vector( 1007, N);
signal data2pool15 : std_logic_vector (N-1 downto 0) := conv_std_logic_vector( 8, N);
signal data2pool16 : std_logic_vector (N-1 downto 0) := conv_std_logic_vector( 9, N);
signal data2pool17 : std_logic_vector (N-1 downto 0) := conv_std_logic_vector( 0, N);
signal data2pool18 : std_logic_vector (N-1 downto 0) := conv_std_logic_vector( 2, N);
signal data2pool19 : std_logic_vector (N-1 downto 0) := conv_std_logic_vector( 3, N);
signal data2pool20 : std_logic_vector (N-1 downto 0) := conv_std_logic_vector( 4, N);
signal data2pool21 : std_logic_vector (N-1 downto 0) := conv_std_logic_vector( 6, N);
signal data2pool22 : std_logic_vector (N-1 downto 0) := conv_std_logic_vector( -7, N);
signal data2pool23 : std_logic_vector (N-1 downto 0) := conv_std_logic_vector( 9, N);
signal data2pool24 : std_logic_vector (N-1 downto 0) := conv_std_logic_vector( 2, N);
signal data2pool25 : std_logic_vector (N-1 downto 0) := conv_std_logic_vector( 5, N);
signal en_in       : std_logic := '0';
signal sof_in      : std_logic := '0'; -- start of frame
signal d_out       : std_logic_vector (N-1 downto 0);
signal en_out      : std_logic;
signal sof_out     : std_logic; -- start of frame

begin




DUT: Pooling_calc generic map (
           BP            => BP            ,
           TP            => TP            ,
           poll_criteria => poll_criteria ,
           Kernel_size   => Kernel_size   ,
           N             => N             
      )
port map (
           clk         => clk        ,
           rst         => rst        ,
           data2pool1  => data2pool1 ,
           data2pool2  => data2pool2 ,
           data2pool3  => data2pool3 ,
           data2pool4  => data2pool4 ,
           data2pool5  => data2pool5 ,
           data2pool6  => data2pool6 ,
           data2pool7  => data2pool7 ,
           data2pool8  => data2pool8 ,
           data2pool9  => data2pool9 ,
           data2pool10 => data2pool10,
           data2pool11 => data2pool11,
           data2pool12 => data2pool12,
           data2pool13 => data2pool13,
           data2pool14 => data2pool14,
           data2pool15 => data2pool15,
           data2pool16 => data2pool16,
           data2pool17 => data2pool17,
           data2pool18 => data2pool18,
           data2pool19 => data2pool19,
           data2pool20 => data2pool20,
           data2pool21 => data2pool21,
           data2pool22 => data2pool22,
           data2pool23 => data2pool23,
           data2pool24 => data2pool24,
           data2pool25 => data2pool25,
           en_in       => en_in      ,
           sof_in      => sof_in     ,

           d_out       => d_out      ,
           en_out      => en_out     ,
           sof_out     => sof_out               
    );

process        
   begin
     clk <= '0';    
     wait for 5 ns;
     clk <= '1';
     wait for 5 ns;
   end process;

rst <= '1', '0' after 10 ns;





process        
   begin   
     wait for  3 ns; 
     wait for 10 ns; en_in <= '0'; 
-- Line 1
     wait for 10 ns; en_in <= '1'; 
          data2pool1  <= data2pool1 (data2pool1 'left-1 downto 0) & (data2pool1 (data2pool1 'left) xor data2pool1 (data2pool1 'left-1) );
          data2pool2  <= data2pool2 (data2pool2 'left-1 downto 0) & (data2pool2 (data2pool2 'left) xor data2pool2 (data2pool2 'left-1) );
          data2pool3  <= data2pool3 (data2pool3 'left-1 downto 0) & (data2pool3 (data2pool3 'left) xor data2pool3 (data2pool3 'left-1) );
          data2pool4  <= data2pool4 (data2pool4 'left-1 downto 0) & (data2pool4 (data2pool4 'left) xor data2pool4 (data2pool4 'left-1) );
          data2pool5  <= data2pool5 (data2pool5 'left-1 downto 0) & (data2pool5 (data2pool5 'left) xor data2pool5 (data2pool5 'left-1) );
          data2pool6  <= data2pool6 (data2pool6 'left-1 downto 0) & (data2pool6 (data2pool6 'left) xor data2pool6 (data2pool6 'left-1) );
          data2pool7  <= data2pool7 (data2pool7 'left-1 downto 0) & (data2pool7 (data2pool7 'left) xor data2pool7 (data2pool7 'left-1) );
          data2pool8  <= data2pool8 (data2pool8 'left-1 downto 0) & (data2pool8 (data2pool8 'left) xor data2pool8 (data2pool8 'left-1) );
          data2pool9  <= data2pool9 (data2pool9 'left-1 downto 0) & (data2pool9 (data2pool9 'left) xor data2pool9 (data2pool9 'left-1) );
          data2pool10 <= data2pool10(data2pool10'left-1 downto 0) & (data2pool10(data2pool10'left) xor data2pool10(data2pool10'left-1) );
          data2pool11 <= data2pool11(data2pool11'left-1 downto 0) & (data2pool11(data2pool11'left) xor data2pool11(data2pool11'left-1) );
          data2pool12 <= data2pool12(data2pool12'left-1 downto 0) & (data2pool12(data2pool12'left) xor data2pool12(data2pool12'left-1) );
          data2pool13 <= data2pool13(data2pool13'left-1 downto 0) & (data2pool13(data2pool13'left) xor data2pool13(data2pool13'left-1) );
          data2pool14 <= data2pool14(data2pool14'left-1 downto 0) & (data2pool14(data2pool14'left) xor data2pool14(data2pool14'left-1) );
          data2pool15 <= data2pool15(data2pool15'left-1 downto 0) & (data2pool15(data2pool15'left) xor data2pool15(data2pool15'left-1) );
          data2pool16 <= data2pool16(data2pool16'left-1 downto 0) & (data2pool16(data2pool16'left) xor data2pool16(data2pool16'left-1) );
          data2pool17 <= data2pool17(data2pool17'left-1 downto 0) & (data2pool17(data2pool17'left) xor data2pool17(data2pool17'left-1) );
          data2pool18 <= data2pool18(data2pool18'left-1 downto 0) & (data2pool18(data2pool18'left) xor data2pool18(data2pool18'left-1) );
          data2pool19 <= data2pool19(data2pool19'left-1 downto 0) & (data2pool19(data2pool19'left) xor data2pool19(data2pool19'left-1) );
          data2pool20 <= data2pool20(data2pool20'left-1 downto 0) & (data2pool20(data2pool20'left) xor data2pool20(data2pool20'left-1) );
          data2pool21 <= data2pool21(data2pool21'left-1 downto 0) & (data2pool21(data2pool21'left) xor data2pool21(data2pool21'left-1) );
          data2pool22 <= data2pool22(data2pool22'left-1 downto 0) & (data2pool22(data2pool22'left) xor data2pool22(data2pool22'left-1) );
          data2pool23 <= data2pool23(data2pool23'left-1 downto 0) & (data2pool23(data2pool23'left) xor data2pool23(data2pool23'left-1) );
          data2pool24 <= data2pool24(data2pool24'left-1 downto 0) & (data2pool24(data2pool24'left) xor data2pool24(data2pool24'left-1) );
          data2pool25 <= data2pool25(data2pool25'left-1 downto 0) & (data2pool25(data2pool25'left) xor data2pool25(data2pool25'left-1) );
       sof_in <= '1';
     wait for 10 ns; en_in <= '0'; sof_in <= '0';
--     wait for 10 ns; en_in <= '1';
--          data2pool1  <= data2pool1 (data2pool1 'left-1 downto 0) & (data2pool1 (data2pool1 'left) xor data2pool1 (data2pool1 'left-1) );
--          data2pool2  <= data2pool2 (data2pool2 'left-1 downto 0) & (data2pool2 (data2pool2 'left) xor data2pool2 (data2pool2 'left-1) );
--          data2pool3  <= data2pool3 (data2pool3 'left-1 downto 0) & (data2pool3 (data2pool3 'left) xor data2pool3 (data2pool3 'left-1) );
--          data2pool4  <= data2pool4 (data2pool4 'left-1 downto 0) & (data2pool4 (data2pool4 'left) xor data2pool4 (data2pool4 'left-1) );
--          data2pool5  <= data2pool5 (data2pool5 'left-1 downto 0) & (data2pool5 (data2pool5 'left) xor data2pool5 (data2pool5 'left-1) );
--          data2pool6  <= data2pool6 (data2pool6 'left-1 downto 0) & (data2pool6 (data2pool6 'left) xor data2pool6 (data2pool6 'left-1) );
--          data2pool7  <= data2pool7 (data2pool7 'left-1 downto 0) & (data2pool7 (data2pool7 'left) xor data2pool7 (data2pool7 'left-1) );
--          data2pool8  <= data2pool8 (data2pool8 'left-1 downto 0) & (data2pool8 (data2pool8 'left) xor data2pool8 (data2pool8 'left-1) );
--          data2pool9  <= data2pool9 (data2pool9 'left-1 downto 0) & (data2pool9 (data2pool9 'left) xor data2pool9 (data2pool9 'left-1) );
--          data2pool10 <= data2pool10(data2pool10'left-1 downto 0) & (data2pool10(data2pool10'left) xor data2pool10(data2pool10'left-1) );
--          data2pool11 <= data2pool11(data2pool11'left-1 downto 0) & (data2pool11(data2pool11'left) xor data2pool11(data2pool11'left-1) );
--          data2pool12 <= data2pool12(data2pool12'left-1 downto 0) & (data2pool12(data2pool12'left) xor data2pool12(data2pool12'left-1) );
--          data2pool13 <= data2pool13(data2pool13'left-1 downto 0) & (data2pool13(data2pool13'left) xor data2pool13(data2pool13'left-1) );
--          data2pool14 <= data2pool14(data2pool14'left-1 downto 0) & (data2pool14(data2pool14'left) xor data2pool14(data2pool14'left-1) );
--          data2pool15 <= data2pool15(data2pool15'left-1 downto 0) & (data2pool15(data2pool15'left) xor data2pool15(data2pool15'left-1) );
--          data2pool16 <= data2pool16(data2pool16'left-1 downto 0) & (data2pool16(data2pool16'left) xor data2pool16(data2pool16'left-1) );
--          data2pool17 <= data2pool17(data2pool17'left-1 downto 0) & (data2pool17(data2pool17'left) xor data2pool17(data2pool17'left-1) );
--          data2pool18 <= data2pool18(data2pool18'left-1 downto 0) & (data2pool18(data2pool18'left) xor data2pool18(data2pool18'left-1) );
--          data2pool19 <= data2pool19(data2pool19'left-1 downto 0) & (data2pool19(data2pool19'left) xor data2pool19(data2pool19'left-1) );
--          data2pool20 <= data2pool20(data2pool20'left-1 downto 0) & (data2pool20(data2pool20'left) xor data2pool20(data2pool20'left-1) );
--          data2pool21 <= data2pool21(data2pool21'left-1 downto 0) & (data2pool21(data2pool21'left) xor data2pool21(data2pool21'left-1) );
--          data2pool22 <= data2pool22(data2pool22'left-1 downto 0) & (data2pool22(data2pool22'left) xor data2pool22(data2pool22'left-1) );
--          data2pool23 <= data2pool23(data2pool23'left-1 downto 0) & (data2pool23(data2pool23'left) xor data2pool23(data2pool23'left-1) );
--          data2pool24 <= data2pool24(data2pool24'left-1 downto 0) & (data2pool24(data2pool24'left) xor data2pool24(data2pool24'left-1) );
--          data2pool25 <= data2pool25(data2pool25'left-1 downto 0) & (data2pool25(data2pool25'left) xor data2pool25(data2pool25'left-1) );
--
--     wait for 10 ns; en_in <= '1';
--          data2pool1  <= data2pool1 (data2pool1 'left-1 downto 0) & (data2pool1 (data2pool1 'left) xor data2pool1 (data2pool1 'left-1) );
--          data2pool2  <= data2pool2 (data2pool2 'left-1 downto 0) & (data2pool2 (data2pool2 'left) xor data2pool2 (data2pool2 'left-1) );
--          data2pool3  <= data2pool3 (data2pool3 'left-1 downto 0) & (data2pool3 (data2pool3 'left) xor data2pool3 (data2pool3 'left-1) );
--          data2pool4  <= data2pool4 (data2pool4 'left-1 downto 0) & (data2pool4 (data2pool4 'left) xor data2pool4 (data2pool4 'left-1) );
--          data2pool5  <= data2pool5 (data2pool5 'left-1 downto 0) & (data2pool5 (data2pool5 'left) xor data2pool5 (data2pool5 'left-1) );
--          data2pool6  <= data2pool6 (data2pool6 'left-1 downto 0) & (data2pool6 (data2pool6 'left) xor data2pool6 (data2pool6 'left-1) );
--          data2pool7  <= data2pool7 (data2pool7 'left-1 downto 0) & (data2pool7 (data2pool7 'left) xor data2pool7 (data2pool7 'left-1) );
--          data2pool8  <= data2pool8 (data2pool8 'left-1 downto 0) & (data2pool8 (data2pool8 'left) xor data2pool8 (data2pool8 'left-1) );
--          data2pool9  <= data2pool9 (data2pool9 'left-1 downto 0) & (data2pool9 (data2pool9 'left) xor data2pool9 (data2pool9 'left-1) );
--          data2pool10 <= data2pool10(data2pool10'left-1 downto 0) & (data2pool10(data2pool10'left) xor data2pool10(data2pool10'left-1) );
--          data2pool11 <= data2pool11(data2pool11'left-1 downto 0) & (data2pool11(data2pool11'left) xor data2pool11(data2pool11'left-1) );
--          data2pool12 <= data2pool12(data2pool12'left-1 downto 0) & (data2pool12(data2pool12'left) xor data2pool12(data2pool12'left-1) );
--          data2pool13 <= data2pool13(data2pool13'left-1 downto 0) & (data2pool13(data2pool13'left) xor data2pool13(data2pool13'left-1) );
--          data2pool14 <= data2pool14(data2pool14'left-1 downto 0) & (data2pool14(data2pool14'left) xor data2pool14(data2pool14'left-1) );
--          data2pool15 <= data2pool15(data2pool15'left-1 downto 0) & (data2pool15(data2pool15'left) xor data2pool15(data2pool15'left-1) );
--          data2pool16 <= data2pool16(data2pool16'left-1 downto 0) & (data2pool16(data2pool16'left) xor data2pool16(data2pool16'left-1) );
--          data2pool17 <= data2pool17(data2pool17'left-1 downto 0) & (data2pool17(data2pool17'left) xor data2pool17(data2pool17'left-1) );
--          data2pool18 <= data2pool18(data2pool18'left-1 downto 0) & (data2pool18(data2pool18'left) xor data2pool18(data2pool18'left-1) );
--          data2pool19 <= data2pool19(data2pool19'left-1 downto 0) & (data2pool19(data2pool19'left) xor data2pool19(data2pool19'left-1) );
--          data2pool20 <= data2pool20(data2pool20'left-1 downto 0) & (data2pool20(data2pool20'left) xor data2pool20(data2pool20'left-1) );
--          data2pool21 <= data2pool21(data2pool21'left-1 downto 0) & (data2pool21(data2pool21'left) xor data2pool21(data2pool21'left-1) );
--          data2pool22 <= data2pool22(data2pool22'left-1 downto 0) & (data2pool22(data2pool22'left) xor data2pool22(data2pool22'left-1) );
--          data2pool23 <= data2pool23(data2pool23'left-1 downto 0) & (data2pool23(data2pool23'left) xor data2pool23(data2pool23'left-1) );
--          data2pool24 <= data2pool24(data2pool24'left-1 downto 0) & (data2pool24(data2pool24'left) xor data2pool24(data2pool24'left-1) );
--          data2pool25 <= data2pool25(data2pool25'left-1 downto 0) & (data2pool25(data2pool25'left) xor data2pool25(data2pool25'left-1) );
--     wait for 10 ns; en_in <= '1';
--          data2pool1  <= data2pool1 (data2pool1 'left-1 downto 0) & (data2pool1 (data2pool1 'left) xor data2pool1 (data2pool1 'left-1) );
--          data2pool2  <= data2pool2 (data2pool2 'left-1 downto 0) & (data2pool2 (data2pool2 'left) xor data2pool2 (data2pool2 'left-1) );
--          data2pool3  <= data2pool3 (data2pool3 'left-1 downto 0) & (data2pool3 (data2pool3 'left) xor data2pool3 (data2pool3 'left-1) );
--          data2pool4  <= data2pool4 (data2pool4 'left-1 downto 0) & (data2pool4 (data2pool4 'left) xor data2pool4 (data2pool4 'left-1) );
--          data2pool5  <= data2pool5 (data2pool5 'left-1 downto 0) & (data2pool5 (data2pool5 'left) xor data2pool5 (data2pool5 'left-1) );
--          data2pool6  <= data2pool6 (data2pool6 'left-1 downto 0) & (data2pool6 (data2pool6 'left) xor data2pool6 (data2pool6 'left-1) );
--          data2pool7  <= data2pool7 (data2pool7 'left-1 downto 0) & (data2pool7 (data2pool7 'left) xor data2pool7 (data2pool7 'left-1) );
--          data2pool8  <= data2pool8 (data2pool8 'left-1 downto 0) & (data2pool8 (data2pool8 'left) xor data2pool8 (data2pool8 'left-1) );
--          data2pool9  <= data2pool9 (data2pool9 'left-1 downto 0) & (data2pool9 (data2pool9 'left) xor data2pool9 (data2pool9 'left-1) );
--          data2pool10 <= data2pool10(data2pool10'left-1 downto 0) & (data2pool10(data2pool10'left) xor data2pool10(data2pool10'left-1) );
--          data2pool11 <= data2pool11(data2pool11'left-1 downto 0) & (data2pool11(data2pool11'left) xor data2pool11(data2pool11'left-1) );
--          data2pool12 <= data2pool12(data2pool12'left-1 downto 0) & (data2pool12(data2pool12'left) xor data2pool12(data2pool12'left-1) );
--          data2pool13 <= data2pool13(data2pool13'left-1 downto 0) & (data2pool13(data2pool13'left) xor data2pool13(data2pool13'left-1) );
--          data2pool14 <= data2pool14(data2pool14'left-1 downto 0) & (data2pool14(data2pool14'left) xor data2pool14(data2pool14'left-1) );
--          data2pool15 <= data2pool15(data2pool15'left-1 downto 0) & (data2pool15(data2pool15'left) xor data2pool15(data2pool15'left-1) );
--          data2pool16 <= data2pool16(data2pool16'left-1 downto 0) & (data2pool16(data2pool16'left) xor data2pool16(data2pool16'left-1) );
--          data2pool17 <= data2pool17(data2pool17'left-1 downto 0) & (data2pool17(data2pool17'left) xor data2pool17(data2pool17'left-1) );
--          data2pool18 <= data2pool18(data2pool18'left-1 downto 0) & (data2pool18(data2pool18'left) xor data2pool18(data2pool18'left-1) );
--          data2pool19 <= data2pool19(data2pool19'left-1 downto 0) & (data2pool19(data2pool19'left) xor data2pool19(data2pool19'left-1) );
--          data2pool20 <= data2pool20(data2pool20'left-1 downto 0) & (data2pool20(data2pool20'left) xor data2pool20(data2pool20'left-1) );
--          data2pool21 <= data2pool21(data2pool21'left-1 downto 0) & (data2pool21(data2pool21'left) xor data2pool21(data2pool21'left-1) );
--          data2pool22 <= data2pool22(data2pool22'left-1 downto 0) & (data2pool22(data2pool22'left) xor data2pool22(data2pool22'left-1) );
--          data2pool23 <= data2pool23(data2pool23'left-1 downto 0) & (data2pool23(data2pool23'left) xor data2pool23(data2pool23'left-1) );
--          data2pool24 <= data2pool24(data2pool24'left-1 downto 0) & (data2pool24(data2pool24'left) xor data2pool24(data2pool24'left-1) );
--          data2pool25 <= data2pool25(data2pool25'left-1 downto 0) & (data2pool25(data2pool25'left) xor data2pool25(data2pool25'left-1) );
--     wait for 10 ns; en_in <= '1';

     wait for 1000 ns; en_in <= '1';

   end process;



end a;