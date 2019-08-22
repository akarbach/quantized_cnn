---------------------------------------------------------------------------
-- This VHDL file was developed by Daniel Llamocca (2014).  It may be
-- freely copied and/or distributed at no cost.  Any persons using this
-- file for any purpose do so at their own risk, and are responsible for
-- the results of such use.  Daniel Llamocca does not guarantee that
-- this file is complete, correct, or fit for any particular purpose.
-- NO WARRANTY OF ANY KIND IS EXPRESSED OR IMPLIED.  This notice must
-- accompany any copy of this file.
--------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.std_logic_arith.all;
 
 
ENTITY tb_res_div_pip IS
END tb_res_div_pip;
 
ARCHITECTURE behavior OF tb_res_div_pip IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT res_div_pip
    PORT(
         A : IN  std_logic_vector(7 downto 0);
         B : IN  std_logic_vector(3 downto 0);
         clock : IN  std_logic;
         resetn : IN  std_logic;
         E : IN  std_logic;
         Q : OUT  std_logic_vector(7 downto 0);
         R : OUT  std_logic_vector(3 downto 0);
			v: out std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal A : std_logic_vector(7 downto 0) := (others => '0');
   signal B : std_logic_vector(3 downto 0) := (others => '0');
   signal clock : std_logic := '0';
   signal resetn : std_logic := '0';
   signal E : std_logic := '0';

 	--Outputs
   signal Q : std_logic_vector(7 downto 0);
   signal R : std_logic_vector(3 downto 0);
	signal v: std_logic;

   -- Clock period definitions
   constant clock_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: res_div_pip PORT MAP (
          A => A, B => B,
          clock => clock,
          resetn => resetn,
          E => E,
          Q => Q, R => R,
			 v => v);

   -- Clock process definitions
   clock_process :process
   begin
		clock <= '0';
		wait for clock_period/2;
		clock <= '1';
		wait for clock_period/2;
   end process;
 
   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
		resetn <= '0';
      wait for 100 ns; resetn <= '1'; E <= '1';
		wait for clock_period;

      -- insert stimulus here 
		--                                                           Q    R
		A <= x"09"; B <= x"3"; wait for clock_period; --    9/3 - result:   3    0
		A <= x"FF"; B <= x"1"; wait for clock_period; --  255/1 - result: 255    0
		A <= x"00"; B <= x"5"; wait for clock_period; --    0/5 - result:   0    0
		A <= x"79"; B <= x"B"; wait for clock_period; -- 121/11 - result:  11    0
		A <= x"B4"; B <= x"C"; wait for clock_period; -- 180/12 - result:  15    0
		A <= x"BB"; B <= x"A"; wait for clock_period; -- 187/10 - result:  18    7
		A <= x"8C"; B <= x"9"; wait for clock_period; -- 140/9  - result:  15    5
		
		-- Testing E:
		E <= '0'; wait for 2*clock_period;
		A <= x"FF"; B <= x"F"; E <= '1'; wait for clock_period;
		E <= '0'; wait for clock_period;
		A <= x"FF"; B <= x"E"; E <= '1'; wait for clock_period;
		E <= '0'; wait for clock_period;
		
		-- Testing every single case:
		E <= '1'; wait for 2*clock_period;
		
		--la: for i in 0 to 255 loop				
		--		l_tb: for j in 0 to 15 loop
    la: for i in 12 to 255 loop        
        l_tb: for j in 0 to 15 loop
							A <= conv_std_logic_vector(i,8); B <= conv_std_logic_vector(j,4); wait for clock_period;
              wait for 20*clock_period;
						end loop l_tb;
				wait for clock_period;
			 end loop la;
      wait;
   end process;

END;
