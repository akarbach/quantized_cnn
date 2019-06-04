library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;

entity ConvLayer_weight_gen is
  generic (
           BP            : string := "no";  --"no"/"yes"  -- Bypass
           M             : integer := 8 -- input weight width
  	       );
  port    (
           clk         : in std_logic;
           rst         : in std_logic;

           w_in        : in  std_logic_vector(M-1 downto 0);
           w_num       : in  std_logic_vector(  3 downto 0);
           w_en        : in  std_logic;

          w1           : out std_logic_vector(M-1 downto 0); -- weight matrix
          w2           : out std_logic_vector(M-1 downto 0); -- weight matrix
          w3           : out std_logic_vector(M-1 downto 0); -- weight matrix
          w4           : out std_logic_vector(M-1 downto 0); -- weight matrix
          w5           : out std_logic_vector(M-1 downto 0); -- weight matrix
          w6           : out std_logic_vector(M-1 downto 0); -- weight matrix
          w7           : out std_logic_vector(M-1 downto 0); -- weight matrix
          w8           : out std_logic_vector(M-1 downto 0); -- weight matrix
          w9           : out std_logic_vector(M-1 downto 0)  -- weight matrix
           );
end ConvLayer_weight_gen;

architecture a of ConvLayer_weight_gen is

begin

gen_no_BP: if BP = "no" generate 
-- weight update

  p_weight : process (clk)
  begin
    if rising_edge(clk) then
       if w_en = '1' then
          case w_num is
            when x"1"      =>  w1 <= w_in;
            when x"2"      =>  w2 <= w_in;
            when x"3"      =>  w3 <= w_in;
            when x"4"      =>  w4 <= w_in;
            when x"5"      =>  w5 <= w_in;
            when x"6"      =>  w6 <= w_in;
            when x"7"      =>  w7 <= w_in;
            when x"8"      =>  w8 <= w_in;
            when x"9"      =>  w9 <= w_in;
            when others    =>  null;
          end case;
       end if;
    end if;
  end process p_weight;

end generate; -- BP = yes

gen_BP: if BP = "yes" generate 

          w1(w1'left) <= '1'; w1(w1'left - 1 downto 0) <= (others => '0');
          w2(w1'left) <= '1'; w2(w1'left - 1 downto 0) <= (others => '0');
          w3(w1'left) <= '1'; w3(w1'left - 1 downto 0) <= (others => '0');
          w4(w1'left) <= '1'; w4(w1'left - 1 downto 0) <= (others => '0');
          w5(w1'left) <= '1'; w5(w1'left - 1 downto 0) <= (others => '0');
          w6(w1'left) <= '1'; w6(w1'left - 1 downto 0) <= (others => '0');
          w7(w1'left) <= '1'; w7(w1'left - 1 downto 0) <= (others => '0');
          w8(w1'left) <= '1'; w8(w1'left - 1 downto 0) <= (others => '0');
          w9(w1'left) <= '1'; w9(w1'left - 1 downto 0) <= (others => '0');

end generate;


end a;