library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;

entity generic_mult is
generic (
       N: integer; 
       M: integer
       );
port ( 
       clk    :  in  std_logic;
       rst    :  in  std_logic; 
       a      :  in  std_logic_vector(N-1 downto 0);
       b      :  in  std_logic_vector(M-1 downto 0);
       prod   :  out std_logic_vector(M+N-1 downto 0) );
end entity generic_mult;

architecture behavioral of generic_mult is

-- Components
component mult is
port (
    a    :  in std_logic;
    b    :  in std_logic;
    pin  :  in std_logic;
    cin  :  in std_logic;
    pout :  out std_logic;
    cout :  out std_logic );
end component;

-- Signals
type mem_word is array (0 to M-1) of std_logic_vector(N-1 downto 0);
signal cin  : mem_word;
signal cout : mem_word;
signal pin  : mem_word;
signal pout : mem_word;

signal a_magn   : std_logic_vector(N-1 downto 0);
signal b_magn   : std_logic_vector(M-1 downto 0);
signal a_sign   : std_logic;
signal b_sign   : std_logic;

signal prod_magn: std_logic_vector(M+N-1 downto 0);

begin


p_conv2mag_n_sign : process (clk)
--variable vparity           : std_logic;
begin
    if rising_edge(clk) then
      a_sign  <= a(a'left);
      b_sign  <= b(b'left);
  
      if a(a'left) = '1' then
        a_magn <= (not a) + 1;
      else
        a_magn <= a;
      end if;

      if b(b'left) = '1' then
        b_magn <= (not b) + 1;
      else
        b_magn <= b;
      end if;
    end if;
end process p_conv2mag_n_sign;



    m_loop: for i in 0 to M-1 generate
        n_loop: for j in 0 to N-1 generate
            mult_inst : mult
            port map (
                a    => a_magn(j), --a(j),
                b    => b_magn(i), --b(i),
                pin  => pin(i)(j),
                cin  => cin(i)(j),
                pout => pout(i)(j),
                cout => cout(i)(j) );
        end generate;
    end generate;

    cin_init: for j in 0 to N-1 generate 
        cin(0)(j) <= '0'; 
    end generate;

    cin_mloop: for i in 1 to M-1 generate
        cin_nloop: for j in 0 to N-2 generate 
            cin(i)(j) <= pout(i-1)(j+1); 
        end generate;
        cin(i)(N-1) <= cout(i-1)(N-1);
    end generate;

    pin_mloop: for i in 0 to M-1 generate 
        pin(i)(0) <= '0'; 
        pin_nloop: for j in 1 to N-1 generate 
            pin(i)(j) <= cout(i)(j-1); 
        end generate;
    end generate;

    prod_loop: for j in 0 to M-1 generate
        prod_magn(j) <= pout(j)(0);
    end generate;

    prod_magn(M+N-2 downto M) <= pout(M-1)(N-1 downto 1);
    prod_magn(M+N-1) <= cout(M-1)(N-1);

p_conv2_2compl : process (clk)
--variable vparity           : std_logic;
begin
    if rising_edge(clk) then
      if a_sign = b_sign then
        prod <= prod_magn;
      else
        prod <= (not prod_magn) + 1;
      end if;
    end if;
end process p_conv2_2compl;

end behavioral;