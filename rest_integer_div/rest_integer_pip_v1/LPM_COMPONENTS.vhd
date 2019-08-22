---------------------------------------------------------------------------
-- This VHDL file was developed by Altera Corporation.  It may be
-- freely copied and/or distributed at no cost.  Any persons using this
-- file for any purpose do so at their own risk, and are responsible for
-- the results of such use.  Altera Corporation does not guarantee that
-- this file is complete, correct, or fit for any particular purpose.
-- NO WARRANTY OF ANY KIND IS EXPRESSED OR IMPLIED.  This notice must
-- accompany any copy of this file.
--------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

package LPM_COMPONENTS is

	component LPM_SHIFTREG
		 generic (
			  -- Width of the data[] and q ports. (Required)
			  lpm_width     : natural:=8;
			  lpm_direction : string := "LEFT";
			  -- Constant value that is loaded when aset is high.
			  lpm_avalue    : string := "UNUSED";
			  -- Constant value that is loaded on the rising edge of clock when sset is high.
			  lpm_svalue    : string := "UNUSED";
	--      lpm_pvalue    : string := "UNUSED";
			  lpm_type      : string := "L_SHIFTREG";
			  lpm_hint      : string := "UNUSED"
		 );
		 port (
			  -- Data input to the shift register.
			  data : in std_logic_vector(lpm_width-1 downto 0) := (OTHERS => '0');
			  -- Positive-edge-triggered clock. (Required)
			  clock : in std_logic;
			  -- Clock enable input
			  enable : in std_logic := '1';
			  -- Serial shift data input.
			  shiftin : in std_logic := '1';
			  -- Synchronous parallel load. High (1): load operation; low (0): shift operation.
			  load : in std_logic := '0';
			  -- Asynchronous clear input.
			  aclr : in std_logic := '0';
			  -- Asynchronous set input.
			  aset : in std_logic := '0';
			  -- Synchronous clear input.
			  sclr : in std_logic := '0';
			  -- Synchronous set input.
			  sset : in std_logic := '0';
			  -- Data output from the shift register.
			  q : out std_logic_vector(lpm_width-1 downto 0);
			  -- Serial shift data output.
			  shiftout : out std_logic
		 );
	end component;

	component LPM_ADD_SUB
		 generic (
			  lpm_width          : natural:= 8;    -- MUST be greater than 0
			  lpm_representation : string := "SIGNED";
			  lpm_direction      : string := "UNUSED";
			  lpm_pipeline       : natural := 0;
			  lpm_type           : string := "LPM_ADD_SUB";
			  lpm_hint           : string := "UNUSED"
		 );
		 
		 port (
			  dataa   : in std_logic_vector(lpm_width-1 downto 0);
			  datab   : in std_logic_vector(lpm_width-1 downto 0);
			  --cin     : in std_logic := 'Z';			  
			  cin     : in std_logic := '0';
			  add_sub : in std_logic := '1';
			  clock   : in std_logic := '0';
			  aclr    : in std_logic := '0';
			  clken   : in std_logic := '1';
			  result   : out std_logic_vector(lpm_width-1 downto 0);
			  cout     : out std_logic;
			  overflow : out std_logic
		 );
	end component;

	component LPM_COUNTER
		 generic (
			  lpm_width     : natural:= 8;    -- MUST be greater than 0
			  lpm_direction : string  := "UNUSED";
			  lpm_modulus   : natural := 0;
			  lpm_avalue    : string  := "UNUSED";
			  lpm_svalue    : string  := "UNUSED";
			  lpm_port_updown : string := "PORT_CONNECTIVITY";
			  lpm_type      : string  := "LPM_COUNTER";
			  lpm_hint      : string  := "UNUSED"
		 );
		 port (
			  clock   : in std_logic;
			  clk_en  : in std_logic := '1';
			  cnt_en  : in std_logic := '1';
			  updown  : in std_logic := '1';
			  aclr    : in std_logic := '0';
			  aset    : in std_logic := '0';
			  aload   : in std_logic := '0';
			  sclr    : in std_logic := '0';
			  sset    : in std_logic := '0';
			  sload   : in std_logic := '0';
			  data    : in std_logic_vector(lpm_width-1 downto 0):= (OTHERS => '0');
			  cin     : in std_logic := '1';
			  q    : out std_logic_vector(lpm_width-1 downto 0);
			  cout : out std_logic := '0';
			  eq   : out std_logic_vector(15 downto 0) := (OTHERS => '0')
		 );
	
	end component;
	
	component LPM_FF
    generic (
        -- Width of the data[] and q[] ports. (Required)
        lpm_width  : natural:=8;
        -- Constant value that is loaded when aset is high.
        lpm_avalue : string := "UNUSED";
        -- Constant value that is loaded on the rising edge of clock when sset is high.
        lpm_svalue : string := "UNUSED";
--        lpm_pvalue : string := "UNUSED";
        -- Type of flipflop.
        lpm_fftype : string := "DFF";
        lpm_type   : string := "LPM_FF"
    );
    
    port (
        data   : in std_logic_vector(lpm_width-1 downto 0) := (OTHERS => '1');
        clock  : in std_logic;
        enable : in std_logic := '1';
        aclr   : in std_logic := '0';
        aset   : in std_logic := '0';
        aload  : in std_logic := '0';
        sclr   : in std_logic := '0';
        sset   : in std_logic := '0';
        sload  : in std_logic := '0';
        q : out std_logic_vector(lpm_width-1 downto 0)
    );
	end component;
	
	component LPM_MULT
	
	-- GENERIC DECLARATION
		 generic (
			  lpm_widtha : natural:=8;  -- Width of the dataa[] port. (Required)
			  lpm_widthb : natural:=8;  -- Width of the datab[] port. (Required)
			  lpm_widthp : natural:=16;  -- Width of the result[] port. (Required)
			  lpm_widths : natural:=16; -- Width of the sum[] port. (Required)
			  lpm_representation : string  := "UNSIGNED"; -- Type of multiplication performed
			  lpm_pipeline       : natural := 0; -- Number of clock cycles of latency
			  lpm_type           : string  := "LPM_MULT"
		 );
	
	-- PORT DECLARATION 
		 port (
			  -- Multiplicand. (Required)
			  dataa : in std_logic_vector(lpm_widtha-1 downto 0);
			  -- Multiplier. (Required)
			  datab : in std_logic_vector(lpm_widthb-1 downto 0);
			  -- Partial sum.
			  sum   : in std_logic_vector(lpm_widths-1 downto 0) := (OTHERS => '0');
			  -- Asynchronous clear for pipelined usage.
			  aclr  : in std_logic := '0';
			  -- Clock for pipelined usage.
			  clock : in std_logic := '0';
			  -- Clock enable for pipelined usage.
			  clken : in std_logic := '1';
			  -- result = dataa[] * datab[] + sum. The product LSB is aligned with the sum LSB.
			  result : out std_logic_vector(lpm_widthp-1 downto 0)
		 );
	end component;

	component lpm_abs
		 generic (
					lpm_width : natural;    -- Width of the data[] and result[] ports.
													-- MUST be greater than 0 (Required)
					lpm_type  : string := "LPM_ABS";
					lpm_hint  : string := "UNUSED"
					);
	
		 port    ( 
					data      : in std_logic_vector(lpm_width-1 downto 0); -- (Required)
					result    : out std_logic_vector(lpm_width-1 downto 0); -- (Required)
					overflow  : out std_logic
					);
	end component;
	
	component LPM_COMPARE
		 generic (
			  -- Width of the dataa[] and datab[] ports. (Required)
			  lpm_width : natural;
			  -- Type of comparison performed: "SIGNED", "UNSIGNED"
			  lpm_representation : string := "UNSIGNED";
			  -- Specifies the number of clock cycles of latency associated with the
			  -- alb, aeb, agb, ageb, aleb or aneb output.
			  lpm_pipeline : natural := 0;
			  lpm_type: string := "LPM_COMPARE";
			  lpm_hint : string := "UNUSED"
		 );
		 
		 port (
			  -- Value to be compared to datab[]. (Required)
			  dataa : in std_logic_vector(lpm_width-1 downto 0);
			  -- Value to be compared to dataa[]. (Required)
			  datab : in std_logic_vector(lpm_width-1 downto 0);
			  -- clock for pipelined usage.
			  clock : in std_logic := '0';
			  -- Asynchronous clear for pipelined usage.
			  aclr  : in std_logic := '0';
			  -- clock enable for pipelined usage.
			  clken : in std_logic := '1';
			  
			  -- One of the following ports must be present.
			  alb  : out std_logic;  -- High (1) if dataa[] < datab[].
			  aeb  : out std_logic;  -- High (1) if dataa[] == datab[].
			  agb  : out std_logic;  -- High (1) if dataa[] > datab[].
			  aleb : out std_logic;  -- High (1) if dataa[] <= datab[].
			  aneb : out std_logic;  -- High (1) if dataa[] != datab[].
			  ageb : out std_logic   -- High (1) if dataa[] >= datab[].
		 );
	end component;
	
	
	component LPM_CLSHIFT

-- GENERIC DECLARATION
    generic (
        lpm_width     : natural;    -- Width of the data[] and result[] ports.
                                    -- MUST be greater than 0 (Required)                                    
        lpm_widthdist : natural;    -- Width of the distance[] input port.
                                    -- MUST be greater than 0 (Required)
        lpm_shifttype : string := "LOGICAL"; -- Type of shifting operation to be performed.
        lpm_type      : string := "LPM_CLSHIFT";
        lpm_hint      : string := "UNUSED"
    );

-- PORT DECLARATION 
    port (
        -- data to be shifted. (Required)
        data      : in STD_LOGIC_VECTOR(lpm_width-1 downto 0); 
        -- Number of positions to shift data[] in the direction specified by the
        -- direction port. (Required)
        distance  : in STD_LOGIC_VECTOR(lpm_widthdist-1 downto 0); 
        -- direction of shift. Low = left (toward the MSB), high = right (toward the LSB). 
        direction : in STD_LOGIC := '0';
        -- Shifted data. (Required)
        result    : out STD_LOGIC_VECTOR(lpm_width-1 downto 0);
        -- Logical or arithmetic underflow.
        underflow : out STD_LOGIC;
        -- Logical or arithmetic overflow.
        overflow  : out STD_LOGIC
    );
	end component;
end;