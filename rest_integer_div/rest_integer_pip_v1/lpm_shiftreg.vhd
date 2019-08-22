---START_ENTITY_HEADER---------------------------------------------------------
--
-- Entity Name     :  lpm_shiftreg
--
-- Description     :  Parameterized shift register megafunction.
--
-- Limitation      :  n/a 
--
-- Results Expected:  data output from the shift register and the Serial shift data output.
--
---END_ENTITY_HEADER-----------------------------------------------------------

-- LIBRARY USED----------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
--use work.LPM_COMPONENTS.all;
use work.LPM_COMMON_CONVERSION.all;

-- ENTITY DECLARATION
entity LPM_SHIFTREG is
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
end LPM_SHIFTREG;
-- END OF ENTITY

-- BEGINNING OF ARCHITECTURE
architecture LPM_SYN of LPM_SHIFTREG is

-- SIGNAL DECLARATION
signal i_q : std_logic_vector(lpm_width-1 downto 0) := (OTHERS => '0');
--signal init : std_logic := '0';
--signal tmp_init : std_logic := '0';
signal i_shiftout_pos : natural := lpm_width-1;

begin

-- PROCESS DECLARATION

    -- basic error checking for invalid parameters
--    MSG: process
--    begin
--        if (lpm_width <= 0) then
--            ASSERT FALSE
--            REPORT "Value of lpm_width parameter must be greater than 0!"
--            SEVERITY ERROR;
--        end if;
--        wait;
--    end process MSG;

--    process (tmp_init)
--    begin
--        if (tmp_init = '1') then
--        init <= '1';
--        end if;
--    end process;

    process (clock, aclr, aset)
    variable iavalue : integer := 0;
    variable isvalue : integer := 0;
    begin
        -- initIALIZE TO PVALUE --
--        if (init = '0') then
--            if (lpm_pvalue /= "UNUSED") then
--                i_q <= conv_std_logic_vector(STR_TO_INT(lpm_pvalue), lpm_width);
--            end if;
              if ((lpm_direction = "LEFT") or (lpm_direction = "UNUSED")) then
                  i_shiftout_pos <= lpm_width-1;
              elsif (lpm_direction = "RIGHT") then
                  i_shiftout_pos <= 0;
				  end if;
--            else
--                ASSERT FALSE
--                REPORT "Illegal lpm_direction property value for LPM_SHIFTREG!"
--                SEVERITY ERROR;
--            end if;
--            tmp_init <= '1';
--      elsif (aclr =  '1') then
        if (aclr =  '1') then
            i_q <= (OTHERS => '0');
        elsif (aset = '1') then
            if (lpm_avalue = "UNUSED") then
                i_q <= (OTHERS => '1');
            else
                iavalue := STR_TO_INT(lpm_avalue);
                i_q <= conv_std_logic_vector(iavalue, lpm_width);
            end if;
        elsif (rising_edge(clock)) then
            if (enable = '1') then
                if (sclr = '1') then
                    i_q <= (OTHERS => '0');
                elsif (sset = '1') then
                    if (lpm_svalue = "UNUSED") then
                        i_q <= (OTHERS => '1');
                    else
                        isvalue := STR_TO_INT(lpm_svalue);
                        i_q <= conv_std_logic_vector(isvalue, lpm_width);
                    end if;
                elsif (load = '1') then
                    i_q <= data;
                else
                    if (lpm_width < 2) then
                        i_q(0) <= shiftin;
                    elsif (lpm_direction = "LEFT") then
                        i_q <= (i_q(lpm_width-2 downto 0) & shiftin);
                    else
                        i_q <= (shiftin & i_q(lpm_width-1 downto 1));
                    end if;
                end if;
            end if;
        end if;
    end process;

    q <= i_q;
    shiftout <= i_q(i_shiftout_pos);

end LPM_SYN;
-- END OF ARCHITECTURE
--
--
--
--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.STD_LOGIC_ARITH.ALL;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;
--
--entity lpm_shiftreg is
--		generic (lpm_WIDTH: INTEGER:= 8;
--					lpm_DIRECTION: STRING := "LEFT");
--		port (	data 				: in std_logic_vector(lpm_width-1 downto 0) := (others => '0');
--					clock				: in std_logic;
--					enable			: in std_logic := '1'; -- default value
--					shiftin			: in std_logic;					
--					load				: in std_logic := '0';
--					sclr				: in std_logic := '0';
--					sset				: in std_logic := '0';
--					aclr				: in std_logic := '0';
--					aset				: in std_logic := '0';
--					Q					: out std_logic_vector (lpm_WIDTH-1 downto 0);
--					shiftout			: out std_logic);
--end lpm_shiftreg;
--
--architecture behaviour of lpm_shiftreg is
--	signal shiftout_pos : natural;
--	signal iq: std_logic_vector (lpm_WIDTH-1 downto 0);
--begin
--
--	process (clock, aclr, aset)
--	begin
--		if lpm_DIRECTION = "RIGHT" then
--			shiftout_pos <= 0;
--		elsif lpm_DIRECTION = "LEFT" then
--			shiftout_pos <= lpm_width -1;
--		end if;
--	
--		if aclr = '1' then
--			iq <= (others => '0');
--		elsif aset = '1' then
--			iq <= (others => '1');
--		elsif clock'event and clock = '1' then
--			if enable = '1' then
--				if sclr = '1' then
--					iq <= (others => '0');
--				elsif sset = '1' then
--					iq <= (others => '1');
--				elsif load = '1' then
--					iq <= data;
--				else
--					if lpm_DIRECTION = "RIGHT" then
--						iq <= (shiftin & iq(lpm_width-1 downto 1));
--					elsif lpm_DIRECTION = "LEFT" then
--						iq <= iq(lpm_width-2 downto 0)&shiftin;
--					end if;
--				end if;
--			end if;
--		end if;
--	end process;
--	shiftout <= iq(shiftout_pos);
--	q <= iq;
--end behaviour;