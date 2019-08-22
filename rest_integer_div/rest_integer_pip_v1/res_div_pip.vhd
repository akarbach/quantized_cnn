---------------------------------------------------------------------------
-- This VHDL file was developed by Daniel Llamocca (2014).  It may be
-- freely copied and/or distributed at no cost.  Any persons using this
-- file for any purpose do so at their own risk, and are responsible for
-- the results of such use.  Daniel Llamocca does not guarantee that
-- this file is complete, correct, or fit for any particular purpose.
-- NO WARRANTY OF ANY KIND IS EXPRESSED OR IMPLIED.  This notice must
-- accompany any copy of this file.
--------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.lpm_components.all;

-- Pipelined Array Divider: A/B: A = Q*B + R
-- Latency: N cycles
-- It divides positive integers represented as unsigned
-- The case B=0 should NOT be allowed (include a flag later)
--     A/0: --> Q = 11...1, R = A(M-1 downto 0)
entity res_div_pip is
	generic (N: INTEGER:= 16; -- N >= M
	         M: INTEGER:= 8);
	port( A: in std_logic_vector(N-1 downto 0);
		   B: in std_logic_vector(M-1 downto 0);
			clock, resetn: in std_logic;
			E: in std_logic;
         Q: out std_logic_vector (N-1 downto 0);
			R: out std_logic_vector(M-1 downto 0);
			v: out std_logic);
end res_div_pip;

architecture structure of res_div_pip is

	component unit_proc
		port( a, b, s, cin: in std_logic;
				r, cout: out std_logic);
	end component;
		
	component dffe
		 Port ( d : in  STD_LOGIC;
				  clrn: in std_logic:= '1';
				  prn: in std_logic:= '1';
				  clk : in  STD_LOGIC;
				  ena: in std_logic;
				  q : out  STD_LOGIC);
	end component;

	type chunk is array (natural range <>) of std_logic_vector (N-1 downto 0);
	signal BQ: chunk(M-1 downto 0);

	type my_array is array (natural range <>, natural range <>) of std_logic;
	signal x, y: my_array (N-1 downto 0, M downto 0);
	signal c: my_array(N-1 downto 0, M+1 downto 0);	
	signal rst: std_logic;
		
begin

rst <= not (resetn);

a1: assert (N >= M)
    report "Error: N can not be lower than M!!!"
    severity error;
	
	-- This just assigns zeros to the unused variables
	gz: for i in 0 to M-1 generate
				x(i,M) <= '0'; y(i,M) <= '0';
				c(i,M+1) <= '0';
	    end generate;

   -- Row 0: all values of x (input to the units at level 0) are zero
   g0: for j in M-1 downto 1 generate
				 x(0,j) <= '0';
	     end generate;
	
	-- Diagonal shift registers for B:
	shB: for j in 0 to M-1 generate
			  gBi: lpm_shiftreg generic map (lpm_width => N, lpm_direction => "RIGHT")
	              port map (clock => clock, enable => '1', shiftin => B(j), aclr => rst, q => BQ(j));
					  -- shift from BQ(j)(N-1) to BQ(j)(0)
	     end generate;

	gi: for i in 0 to N-1 generate -- along rows	
	       -- Shift registers for A:
	       -- x(i,0) <= shifted A(N-1-i); -- for all i and for j = 0:
			 gAi: lpm_shiftreg generic map (lpm_width => i+1, lpm_direction => "RIGHT")
			      port map (clock => clock, enable => '1', shiftin => A(N-1-i), aclr => rst, shiftout => x(i,0));
			 
			 c(i,0) <= '1';
			 
	       fa: if i < M generate -- i: 0 to M-1
						gja: for j in M-1 downto 0 generate -- along columns
									ra: if i /= 0 and j /= 0 generate									
												--x(i,j) <= y(i-1,j-1);
												pa: dffe port map (d => y(i-1,j-1), clrn => resetn, prn => '1', clk => clock, ena => '1', q => x(i,j));
										 end generate;
				 
									--gsa: unit_proc port map (a => x(i,j) , b => xB(j), s => c(i,M), cin => c(i,j), r => y(i,j), cout => c(i,j+1));
									gsa: unit_proc port map (a => x(i,j) , b => BQ(j)(N-1-i), s => c(i,M), cin => c(i,j), r => y(i,j), cout => c(i,j+1));
							 end generate;
							 
					  	--Q(N-1-i) <= c(i,M);
						gs1: lpm_shiftreg generic map (lpm_width => N-i-1, lpm_direction => "RIGHT")
			              port map (clock => clock, enable => '1', shiftin => c(i,M), aclr => rst, shiftout => Q(N-1-i));
			    end generate;
			 
			 fb: if i >= M generate -- i: M to N-1
			 			 gjb: for j in M downto 0 generate -- along columns
									rb: if i /= 0 and j /= 0 generate
												--x(i,j) <= y(i-1,j-1);
												pb: dffe port map (d => y(i-1,j-1), clrn => resetn, prn => '1', clk => clock, ena => '1', q => x(i,j));												
										 end generate;
										 
							      --gsb: unit_proc port map (a => x(i,j) , b => xB(j), s => c(i,M+1), cin => c(i,j), r => y(i,j), cout => c(i,j+1));
									gsb: if j /= M generate
												gsba: unit_proc port map (a => x(i,j) , b => BQ(j)(N-1-i), s => c(i,M+1), cin => c(i,j), r => y(i,j), cout => c(i,j+1));									
									    end generate;

									gsbM: if j = M generate
												gsbb: unit_proc port map (a => x(i,j) , b => '0', s => c(i,M+1), cin => c(i,j), r => y(i,j), cout => c(i,j+1));									
									    end generate;
					        end generate;
					  
					     --Q(N-1-i) <= c(i,M+1);
						  gQi: if i /= N-1 generate
									 gs2: lpm_shiftreg generic map (lpm_width => N-i-1, lpm_direction => "RIGHT")
									      port map (clock => clock, enable => '1', shiftin => c(i,M+1), aclr => rst, shiftout => Q(N-1-i));
								 end generate;
                    gQN: if i = N-1 generate
								    Q(N-1-i) <= c(i,M+1);
								 end generate;
			     end generate;
				  
		 end generate;	 
	
	gR: for i in 0 to M-1 generate
				R(i) <= y(N-1,i);
	    end generate;

-- Shift register for E:
	gs1: lpm_shiftreg generic map (lpm_width => N, lpm_direction => "RIGHT")
	     port map (clock => clock, enable => '1', shiftin => E, aclr => rst, shiftout => v);
		 
end structure;
