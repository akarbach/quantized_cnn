library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;




entity Avalon_IF is
    generic (
           N             : integer := 4; -- input data width
           M             : integer := 8; -- max code width
           W             : integer := 16 -- output data width
           );
end entity Avalon_IF;

architecture a of Avalon_IF is

component Huffman is
  generic (
           N             : integer := 4; -- input data width
           M             : integer := 8; -- max code width
           W             : integer := 64 -- output data width
           );
  port    (
           clk           : in  std_logic;
           rst           : in  std_logic; 

           init_en       : in  std_logic;                         -- initialising convert table
           alpha_data    : in  std_logic_vector(N-1 downto 0);    
           alpha_code    : in  std_logic_vector(M-1 downto 0);    
           alpha_width   : in  std_logic_vector(  3 downto 0);

           d_in          : in  std_logic_vector (N-1 downto 0);   -- data to convert
           en_in         : in  std_logic;
           sof_in           : in  std_logic;                         -- start of frame
           eof_in           : in  std_logic;                         -- end of frame

           d_out         : out std_logic_vector (W-1 downto 0);
           en_out        : out std_logic;
           eof_out       : out std_logic);                        -- huffman codde output
end component;

signal clk           : std_logic;
signal rst           : std_logic;
signal init_en       : std_logic;                         -- initialising convert table
signal alpha_data    : std_logic_vector(N-1 downto 0);    
signal alpha_code    : std_logic_vector(M-1 downto 0);    
signal alpha_width   : std_logic_vector(  3 downto 0);
signal d_in          : std_logic_vector (N-1 downto 0);   -- data to convert
signal en_in         : std_logic;
signal sof_in        : std_logic;                         -- start of frame
signal eof_in        : std_logic;                         -- end of frame
signal d_out         : std_logic_vector (W-1 downto 0);
signal en_out        : std_logic;                         -- huffman codde output
signal eof_out       : std_logic;

begin

DUT: Huffman generic map (
      N             => N          ,
      M             => M          ,
      W             => W          
      )
port map (     
      clk           => clk        ,
      rst           => rst        ,
      init_en       => init_en    ,
      alpha_data    => alpha_data , 
      alpha_code    => alpha_code ,   
      alpha_width   => alpha_width,
      d_in          => d_in       ,
      en_in         => en_in      ,
      sof_in        => sof_in     ,
      eof_in        => eof_in     ,
      d_out         => d_out      ,
      en_out        => en_out     ,
      eof_out       => eof_out
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
     wait for  5 ns; en_in <= '0'; init_en <= '0'; eof_in <= '0';
     wait for 14 ns; 

-- Init
wait for 10 ns; init_en <= '1'; 
                alpha_data <= conv_std_logic_vector( 1, alpha_data'length); alpha_width<= x"1"; alpha_code<= conv_std_logic_vector(255, alpha_code'length);
wait for 10 ns; alpha_data <= conv_std_logic_vector( 2, alpha_data'length); alpha_width<= x"2"; alpha_code<= conv_std_logic_vector(255, alpha_code'length);
wait for 10 ns; alpha_data <= conv_std_logic_vector( 3, alpha_data'length); alpha_width<= x"3"; alpha_code<= conv_std_logic_vector(255, alpha_code'length);
wait for 10 ns; alpha_data <= conv_std_logic_vector( 4, alpha_data'length); alpha_width<= x"4"; alpha_code<= conv_std_logic_vector(255, alpha_code'length);
wait for 10 ns; alpha_data <= conv_std_logic_vector( 5, alpha_data'length); alpha_width<= x"5"; alpha_code<= conv_std_logic_vector( 16, alpha_code'length);
wait for 10 ns; alpha_data <= conv_std_logic_vector( 6, alpha_data'length); alpha_width<= x"3"; alpha_code<= conv_std_logic_vector(  4, alpha_code'length);
wait for 10 ns; alpha_data <= conv_std_logic_vector( 7, alpha_data'length); alpha_width<= x"4"; alpha_code<= conv_std_logic_vector(  8, alpha_code'length);
wait for 10 ns; alpha_data <= conv_std_logic_vector( 8, alpha_data'length); alpha_width<= x"4"; alpha_code<= conv_std_logic_vector(255, alpha_code'length);
wait for 10 ns; alpha_data <= conv_std_logic_vector( 9, alpha_data'length); alpha_width<= x"4"; alpha_code<= conv_std_logic_vector(255, alpha_code'length);
wait for 10 ns; alpha_data <= conv_std_logic_vector(10, alpha_data'length); alpha_width<= x"5"; alpha_code<= conv_std_logic_vector(255, alpha_code'length);
wait for 10 ns; alpha_data <= conv_std_logic_vector(11, alpha_data'length); alpha_width<= x"4"; alpha_code<= conv_std_logic_vector(255, alpha_code'length);
wait for 10 ns; alpha_data <= conv_std_logic_vector(12, alpha_data'length); alpha_width<= x"4"; alpha_code<= conv_std_logic_vector(255, alpha_code'length);
wait for 10 ns; alpha_data <= conv_std_logic_vector(13, alpha_data'length); alpha_width<= x"4"; alpha_code<= conv_std_logic_vector(255, alpha_code'length);
wait for 10 ns; alpha_data <= conv_std_logic_vector(14, alpha_data'length); alpha_width<= x"4"; alpha_code<= conv_std_logic_vector(255, alpha_code'length);
wait for 10 ns; alpha_data <= conv_std_logic_vector(15, alpha_data'length); alpha_width<= x"4"; alpha_code<= conv_std_logic_vector(255, alpha_code'length);
wait for 10 ns; init_en <= '0';
wait for 10 ns; 

wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 1, d_in'length);
wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 2, d_in'length);
wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 3, d_in'length);
wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 4, d_in'length);
wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 5, d_in'length);
wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 6, d_in'length);
wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 7, d_in'length);
wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 8, d_in'length);eof_in <= '1';
wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 9, d_in'length);eof_in <= '0';
wait for 10 ns; en_in <= '1'; d_in <= conv_std_logic_vector( 3, d_in'length);eof_in <= '1';


     
wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);eof_in <= '0';
wait for 10 ns; en_in <= '0'; d_in <= conv_std_logic_vector( 0, d_in'length);

   end process;

end a;