
-------------------------------------------------------------------
--                                                               --
-- Copyright (c) 2003 Synopsys, Inc.  All Rights Reserved        --
-- This information is provided pursuant to a license agreement  --
-- that grants limited rights of access/use and requires that    --
-- the information be treated as confidential.                   --
--                                                               --
-------------------------------------------------------------------

------------------------Revision History--------------------------------------
--   New model  1.0  created by stask.
--   23-jun-00  1.1  Separate output delay for each                    
--                   bit(D/E #19284) added and enhancement of vital    
--                   setup/hold for back-annotation by pavlov. 
--   07-jul-00  1.2  Wrong type for bankIsGood_dx in delaySelectBlock        
--                   bankIsGood_dX is MEMV, so instead bankIsGood_dX <= `1`   
--                   better : bankIsGood_dX <= (others => '1') by pmahe     
--                   Remove edge specification on tpd_CLOCK_OUT (no SDF from
--                   our library have an edge specifier in IOPATH)
--   22-May-02  1.3  D/E:45912 : correct output to perform pre-charge on 
--                   output port as Clock works , done by Haimin Hua
--   13-Aug-02  1.4  D/E:49367 : add function X_judge and update data_output
--                   process , done by Haimin Hua
--   03-Mar-03  1.5  DE#57575: added read/write, write/write conflicts by pavlov.
--   04 Mar-03  1.6  'noedge' generics replaced by posedge/negedge pairs  
--                   by pavlov.
------------------------------------------------------------------------------

LIBRARY IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.VITAL_timing.all;

LIBRARY STD;
  use STD.textio.all;

PACKAGE dpram4096x36P is
  type Char_Array is array (Std_Ulogic range <>) of character;
  constant Std_Ulogic_To_Char : Char_Array :=
           ('U', 'X', '0', '1', 'Z', 'W', 'L', 'H', '-');

  constant DF        : REAL    := 1.0;
  constant numAddr   : integer := 12;
  constant numOut    : integer := 36;
  constant wordDepth : integer := 4096;

  subtype X01_vector  is Std_Logic_Vector;
  subtype MEMV is std_logic_vector(numOut-1 downto 0);
  type MEM is array (wordDepth-1 downto 0) of MEMV;
  
  function X01toI (X : X01) return integer;
  function X01toI (X : X01_vector) return integer;
  function X_judge (X : X01_vector) return integer;
  function max2 (constant t1,t2 : in time) return time;
  function isTrue (constant A : BOOLEAN) return X01;

  procedure Write_Message(msg : string);

  procedure Warn (msg       : string;
                  INSTANCE  : string;
                  REF_TIME  : time;
                  EXP1_TIME : time;
                  EXP2_TIME : time;
                  ERR_TIME  : time);

  procedure Warn (msg       : string;
                  INSTANCE  : string;
                  REF_TIME  : time;
                  EXP_TIME  : time;
                  ERR_TIME  : time);

  procedure Warn (msg       : string;
                  INSTANCE  : string;
                  REF_TIME  : time);

  procedure Warn (msg       : string;
                  adr       : integer;
                  INSTANCE  : string;
                  REF_TIME  : time);

  procedure Warn (msg       : string;
                  INSTANCE  : string;
                  REF_TIME  : time;
                  v_lvl     : integer);


  procedure Info (msg       : string;
                  adr       : integer;
                  val       : std_logic_vector;
                  INSTANCE  : string;
                  REF_TIME  : time);

  procedure Info (msg       : string;
                  val       : std_logic_vector;
                  INSTANCE  : string;
                  REF_TIME  : time);

  PROCEDURE rep_timing(VALUE          : time;
                       TIMING_NAME    : string;
                       REF_TIME       : time);

  PROCEDURE rep_timing(VALUE          : time;
                       TIMING_NAME    : string;
                       DEFAULT        : string;
                       REF_TIME       : time);

END dpram4096x36P;

PACKAGE BODY dpram4096x36P is

    function X01toI (X : X01) return integer is
        variable RESULT : integer := 0;
    begin                      
        case X is                     
            when '1' => RESULT := 1;
            when '0' => RESULT := 0;
            when others => return(-1);
        end case;
        return(RESULT);
    end X01toI;

    function X01toI (X : X01_vector) return integer is
        variable RESULT : integer := 0;
    begin                      
        for I in X'range loop
            case X(I) is                     
                when '1' => RESULT := 2*RESULT + 1;
                when '0' => RESULT := 2*RESULT;
                when others => return(-1);
            end case;
        end loop;
        return(RESULT);
    end X01toI;
    
    function X_judge (X : X01_vector) return integer is
        variable RESULT : integer := 0;
    begin
        for I in X'range loop
            case X(I) is
                when '1' => RESULT := 1;
                when '0' => RESULT := 0;
                when others => return(-1);
            end case;
        end loop;
        return(RESULT);
    end X_judge;

    function max2 (constant t1,t2 : in time) return time is
    begin
       if (t1 > t2) then return (t1); 
       else return (t2);
       end if;
    end max2;
    function isTrue(constant A : BOOLEAN) return X01 is
    begin
      if(A) then return '1';
      else return '0';
      end if;
    end isTrue;

   procedure Write_Message(msg : string) is
     variable STR : line;
   begin
     write (STR, msg);
     writeLine(OUTPUT,STR);
   end Write_Message;

   procedure Warn (msg       : string;
                   INSTANCE  : string;
                   REF_TIME  : time;
                   EXP1_TIME : time;
                   EXP2_TIME : time;
                   ERR_TIME  : time) is
     variable STR : line;
   begin
     if (REF_TIME > 0 ns) then 
       write (STR, REF_TIME);
       write (STR, string'(" Warning for "));
       write (STR, INSTANCE);
       write (STR, string'(" : "));
       write (STR, msg);
       writeLine(OUTPUT,STR);
       deallocate (STR);
       write (STR, string'("             ( "));
       write (STR, REF_TIME - ERR_TIME + EXP1_TIME);
       write (STR, string'(" and "));
       write (STR, REF_TIME - ERR_TIME + EXP2_TIME);
       write (STR, string'(" )"));
       writeLine(OUTPUT,STR);
       deallocate (STR);
     end if;
   end Warn;

   procedure Warn (msg      : string;
                   INSTANCE : string;
                   REF_TIME : time;
                   EXP_TIME : time;
                   ERR_TIME : time) is
     variable STR : line;
   begin
     if (REF_TIME > 0 ns) then 
       write (STR, REF_TIME);
       write (STR, string'(" Warning for "));
       write (STR, INSTANCE);
       write (STR, string'(" : "));
       write (STR, msg);
       writeLine(OUTPUT,STR);
       deallocate (STR);
       write (STR, string'("             ( Should be "));
       write (STR, EXP_TIME);
       write (STR, string'(" is "));
       write (STR, ERR_TIME);
       write (STR, string'(" )"));
       writeLine(OUTPUT,STR);
       deallocate (STR);
     end if;
   end Warn;

   procedure Warn (msg      : string;
                   INSTANCE : string;
                   REF_TIME : time) is
     variable STR : line;
   begin
     if (REF_TIME > 0 ns) then 
       write (STR, REF_TIME);
       write (STR, string'(" Warning for "));
       write (STR, INSTANCE);
       write (STR, string'(" : "));
       write (STR, msg);
       writeLine(OUTPUT,STR);
       deallocate (STR);
     end if;
   end Warn;

   procedure Warn (msg       : string;
                   adr       : integer;
                   INSTANCE  : string;
                   REF_TIME  : time) is
     variable STR : line;
   begin
     if (REF_TIME > 0 ns) then
       write (STR, REF_TIME);
       write (STR, string'(" Warning for "));
       write (STR, INSTANCE);
       write (STR, string'(" : "));
       write (STR, msg);
       write (STR, string'(" memory["));
       write (STR, adr);
       write (STR, string'("]"));
       writeLine(OUTPUT,STR);
     end if;
   end Warn;

   procedure Warn (msg      : string;
                   INSTANCE : string;
                   REF_TIME : time;
                   v_lvl    : integer) is
     variable STR : line;
   begin
     if (REF_TIME > 0 ns and v_lvl /= 0 and v_lvl /= 2) then 
       write (STR, REF_TIME);
       write (STR, string'(" Warning for "));
       write (STR, INSTANCE);
       write (STR, string'(" : "));
       write (STR, msg);
       writeLine(OUTPUT,STR);
       deallocate (STR);
     end if;
   end Warn;


   procedure Info (msg       : string;
                   adr       : integer;
                   val       : std_logic_vector;
                   INSTANCE  : string;
                   REF_TIME  : time) is
     variable STR : line;
     alias LV     : Std_Logic_Vector (val'length-1 downto 0) is val;
   begin
     if (REF_TIME > 0 ns) then
       write (STR, REF_TIME);
       write (STR, string'(" Info    for "));
       write (STR, INSTANCE);
       write (STR, string'(" : "));
       write (STR, msg);
       write (STR, string'(" memory["));
       write (STR, adr);
       write (STR, string'("] = "));
       for j in LV'range loop
         write (STR, Std_Ulogic_To_Char(LV(j)));
       end loop;
       writeLine(OUTPUT,STR);
     end if;
   end Info;

   procedure Info (msg       : string;
                   val       : std_logic_vector;
                   INSTANCE  : string;
                   REF_TIME  : time) is
     variable STR : line;
     alias LV     : Std_Logic_Vector (val'length-1 downto 0) is val;
   begin
     if (REF_TIME > 0 ns) then
       write (STR, REF_TIME);
       write (STR, string'(" Info    for "));
       write (STR, INSTANCE);
       write (STR, string'(" : "));
       write (STR, msg);
       for j in LV'range loop
         write (STR, Std_Ulogic_To_Char(LV(j)));
       end loop;
       writeLine(OUTPUT,STR);
     end if;
   end Info;

   PROCEDURE rep_timing(VALUE          : time;
                        TIMING_NAME    : string;
                        REF_TIME       : time ) is
     variable STR : line;
   BEGIN 
     write (STR, REF_TIME);
     write (STR, string'("  "));
     write (STR, TIMING_NAME);
     write (STR, string'(" : "));
     write (STR, VALUE);
     writeLine(OUTPUT,STR);
     deallocate (STR);
   END rep_timing;

   PROCEDURE rep_timing(VALUE          : time;
                        TIMING_NAME    : string;
                        DEFAULT        : string;
                        REF_TIME       : time ) is
     variable STR : line;
   BEGIN 
     write (STR, REF_TIME);
     write (STR, string'("  "));
     write (STR, TIMING_NAME);
     write (STR, string'(" : "));
     write (STR, VALUE);
     write (STR, string'("  (default: "));
     write (STR, DEFAULT);
     write (STR, string'(")"));
     writeLine(OUTPUT,STR);
     deallocate (STR);
   END rep_timing;

END dpram4096x36P;

LIBRARY IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.VITAL_timing.all;

LIBRARY STD;
  use STD.textio.all;

LIBRARY WORK;
  use WORK.dpram4096x36P.all;


ENTITY dpram4096x36 is
  GENERIC(
     display_header: BOOLEAN := TRUE;
     verbose       : integer := 3;
     debug         : integer := 0;

     tpd_CEB1_O1   : VitalDelayArrayType01(0 to numOut-1)
                   := (others=>(1.023 ns*DF,2.29 ns*DF));    -- access time to port 1
     tpd_CEB2_O2   : VitalDelayArrayType01(0 to numOut-1)
                   := (others=>(1.023 ns*DF,2.29 ns*DF));      -- access time to port 2

     tpd_OEB1_O1   : VitalDelayArrayType01Z(0 to numOut-1)
                   := (others=>(0 ns,0 ns,0.784 ns*DF,0.744 ns*DF,0.784 ns*DF,0.744 ns*DF));
     tpd_OEB2_O2   : VitalDelayArrayType01Z(0 to numOut-1)
                   := (others=>(0 ns,0 ns,0.784 ns*DF,0.744 ns*DF,0.784 ns*DF,0.744 ns*DF));

     tperiod_CEB1     : VitalDelayType
                       := 2.809 ns*DF;                                 -- cycle time for port1
     tperiod_CEB2     : VitalDelayType
                       := 2.809 ns*DF;                                 -- cycle time for port2
     tpw_CEB1_negedge : VitalDelayType
                       := 0.363 ns*DF;                                -- min clock high for port1
     tpw_CEB1_posedge : VitalDelayType
                       := 0.198 ns*DF;                                -- min clock low for port1
     tpw_CEB2_negedge : VitalDelayType
                       := 0.363 ns*DF;                                -- min clock high for port2
     tpw_CEB2_posedge : VitalDelayType
                       := 0.198 ns*DF;                                -- min clock low for port2

     trecovery_CEB1_CEB2_negedge_negedge : VitalDelayType := 1.676 ns*DF;
     trecovery_CEB2_CEB1_negedge_negedge : VitalDelayType := 1.676 ns*DF;
     
     tsetup_WEB1_CEB1_negedge_negedge : VitalDelayType
                                     := 0 ns*DF;                    -- WEB setup time for port1
     tsetup_WEB1_CEB1_posedge_negedge : VitalDelayType
                                     := 0 ns*DF;                    -- WEB setup time for port1
     tsetup_WEB2_CEB2_negedge_negedge : VitalDelayType
                                     := 0 ns*DF;                    -- WEB setup time for port2
     tsetup_WEB2_CEB2_posedge_negedge : VitalDelayType
                                     := 0 ns*DF;                    -- WEB setup time for port2
     thold_WEB1_CEB1_posedge_negedge  : VitalDelayType
                                     := 0.329 ns*DF;                    -- WEB hold time for port1
     thold_WEB1_CEB1_negedge_negedge  : VitalDelayType
                                     := 0.329 ns*DF;                    -- WEB hold time for port1
     thold_WEB2_CEB2_posedge_negedge  : VitalDelayType
                                     := 0.329 ns*DF;                    -- WEB hold time for port2
     thold_WEB2_CEB2_negedge_negedge  : VitalDelayType
                                     := 0.329 ns*DF;                    -- WEB hold time for port2
     tsetup_A1_CEB1_negedge_negedge   : VitalDelayArrayType(0 to numAddr-1)
                                     := (others=>0 ns*DF);          -- Address setup time for port1
     tsetup_A1_CEB1_posedge_negedge   : VitalDelayArrayType(0 to numAddr-1)
                                     := (others=>0 ns*DF);          -- Address setup time for port1
     tsetup_A2_CEB2_negedge_negedge   : VitalDelayArrayType(0 to numAddr-1)
                                     := (others=>0 ns*DF);          -- Address setup time for port2
     tsetup_A2_CEB2_posedge_negedge   : VitalDelayArrayType(0 to numAddr-1)
                                     := (others=>0 ns*DF);          -- Address setup time for port2
     thold_A1_CEB1_posedge_negedge    : VitalDelayArrayType(0 to numAddr-1)
                                     := (others=>0.403 ns*DF);          -- Address hold time for port1
     thold_A1_CEB1_negedge_negedge    : VitalDelayArrayType(0 to numAddr-1)
                                     := (others=>0.403 ns*DF);          -- Address hold time for port1
     thold_A2_CEB2_posedge_negedge    : VitalDelayArrayType(0 to numAddr-1)
                                     := (others=>0.403 ns*DF);          -- Address hold time for port2
     thold_A2_CEB2_negedge_negedge    : VitalDelayArrayType(0 to numAddr-1)
                                     := (others=>0.403 ns*DF);          -- Address hold time for port2


     tsetup_I1_CEB1_negedge_negedge   : VitalDelayArrayType(0 to numOut-1)
                                     := (others=>0.053 ns*DF);         -- Data setup time for port1
     tsetup_I1_CEB1_posedge_negedge   : VitalDelayArrayType(0 to numOut-1)
                                     := (others=>0.053 ns*DF);         -- Data setup time for port1
     tsetup_I2_CEB2_negedge_negedge   : VitalDelayArrayType(0 to numOut-1)
                                     := (others=>0.053 ns*DF);         -- Data setup time for port2
     tsetup_I2_CEB2_posedge_negedge   : VitalDelayArrayType(0 to numOut-1)
                                     := (others=>0.053 ns*DF);         -- Data setup time for port2
     thold_I1_CEB1_negedge_negedge    : VitalDelayArrayType(0 to numOut-1)
                                     := (others=>0.408 ns*DF);         -- Data hold time for port1
     thold_I1_CEB1_posedge_negedge    : VitalDelayArrayType(0 to numOut-1)
                                     := (others=>0.408 ns*DF);         -- Data hold time for port1
     thold_I2_CEB2_negedge_negedge    : VitalDelayArrayType(0 to numOut-1)
                                     := (others=>0.408 ns*DF);         -- Data hold time for port2
     thold_I2_CEB2_posedge_negedge    : VitalDelayArrayType(0 to numOut-1)
                                     := (others=>0.408 ns*DF);         -- Data hold time for port2
     tsetup_CSB1_CEB1_negedge_negedge : VitalDelayType
                                     := 0.294 ns*DF;                   -- CSB setup time for port1
     tsetup_CSB1_CEB1_posedge_negedge : VitalDelayType
                                     := 0.294 ns*DF;                   -- CSB setup time for port1
     tsetup_CSB2_CEB2_negedge_negedge : VitalDelayType
                                     := 0.294 ns*DF;                   -- CSB setup time for port2
     tsetup_CSB2_CEB2_posedge_negedge : VitalDelayType
                                     := 0.294 ns*DF;                   -- CSB setup time for port2
     thold_CSB1_CEB1_negedge_negedge  : VitalDelayType
                                     := 0.053 ns*DF;                       -- CSB hold time for port1
     thold_CSB1_CEB1_posedge_negedge  : VitalDelayType
                                     := 0.053 ns*DF;                       -- CSB hold time for port1
     thold_CSB2_CEB2_negedge_negedge  : VitalDelayType
                                     := 0.053 ns*DF;                      -- CSB hold time for port2
     thold_CSB2_CEB2_posedge_negedge  : VitalDelayType
                                     := 0.053 ns*DF;                      -- CSB hold time for port2


     -- Timing Generics to backannotate interconnect path delays

     tipd_A1    : VitalDelayArrayType01Z((numAddr-1) downto 0)
                   := (others => (0 ns,0 ns,0 ns,0 ns,0 ns,0 ns));
     tipd_A2    : VitalDelayArrayType01Z((numAddr-1) downto 0)
                   := (others => (0 ns,0 ns,0 ns,0 ns,0 ns,0 ns));
     tipd_CEB1  : VitalDelayType01Z
                   := (0 ps,0 ps,0 ps,0 ps,0 ps,0 ps);
     tipd_CEB2  : VitalDelayType01Z
                   := (0 ps,0 ps,0 ps,0 ps,0 ps,0 ps);
     tipd_WEB1  : VitalDelayType01Z
                   := (0 ps,0 ps,0 ps,0 ps,0 ps,0 ps);
     tipd_WEB2  : VitalDelayType01Z
                   := (0 ps,0 ps,0 ps,0 ps,0 ps,0 ps);


     tipd_OEB1  : VitalDelayType01Z
                   := (0 ps,0 ps,0 ps,0 ps,0 ps,0 ps);
     tipd_OEB2  : VitalDelayType01Z
                   := (0 ps,0 ps,0 ps,0 ps,0 ps,0 ps);
     tipd_CSB1  : VitalDelayType01Z
                   := (0 ps,0 ps,0 ps,0 ps,0 ps,0 ps);
     tipd_CSB2  : VitalDelayType01Z
                   := (0 ps,0 ps,0 ps,0 ps,0 ps,0 ps);


     tipd_I1    : VitalDelayArrayType01Z((numOut-1) downto 0)
                   := (others => (0 ns,0 ns,0 ns,0 ns,0 ns,0 ns));
     tipd_I2    : VitalDelayArrayType01Z((numOut-1) downto 0)
                   := (others => (0 ns,0 ns,0 ns,0 ns,0 ns,0 ns));

     InstancePath       : STRING        := "*"     );

  PORT (A1   : in  std_logic_vector(numAddr-1 downto 0);
        A2   : in  std_logic_vector(numAddr-1 downto 0);
        CEB1 : in std_logic;
        CEB2 : in std_logic;
        WEB1 : in std_logic;
        WEB2 : in std_logic;
        OEB1 : in std_logic;
        OEB2 : in std_logic;
        CSB1 : in std_logic;
        CSB2 : in std_logic;
        I1   : in  std_logic_vector((numOut-1) downto 0);
        O1   : out std_logic_vector((numOut-1) downto 0);
        I2   : in  std_logic_vector((numOut-1) downto 0);
        O2   : out std_logic_vector((numOut-1) downto 0) );

  ATTRIBUTE VITAL_LEVEL0 of dpram4096x36 : entity is True;

END dpram4096x36;

ARCHITECTURE dpram4096x36_behave of dpram4096x36 is

  signal A1_ipd       : std_logic_vector((numAddr-1) downto 0) := (others => 'X');
  signal A2_ipd       : std_logic_vector((numAddr-1) downto 0) := (others => 'X');
  signal CEB1_ipd     : std_logic := 'X';
  signal CEB2_ipd     : std_logic := 'X';
  signal WEB1_ipd     : std_logic := 'X';
  signal WEB2_ipd     : std_logic := 'X';
  signal OEB1_ipd     : std_logic := 'X';
  signal OEB2_ipd     : std_logic := 'X';
  signal CSB1_ipd     : std_logic := 'X';
  signal CSB2_ipd     : std_logic := 'X';
  signal I1_ipd       : std_logic_vector((numOut-1) downto 0) := (others => 'X');
  signal I2_ipd       : std_logic_vector((numOut-1) downto 0) := (others => 'X');
  signal OEB1State    : X01 := 'X';
  signal OEB2State    : X01 := 'X';
  signal IN1State     : X01_vector((numOut-1) downto 0) := (others => 'X');
  signal IN2State     : X01_vector((numOut-1) downto 0) := (others => 'X');
  signal CSB1State : X01 := 'X';
  signal CSB2State : X01 := 'X';
  signal CEB1State : X01 := 'X';
  signal CEB2State : X01 := 'X';
  signal WEB1State : X01 := 'X';
  signal WEB2State : X01 := 'X';
  signal A1State   : X01_vector((numAddr-1) downto 0) := (others => 'X');
  signal A2State   : X01_vector((numAddr-1) downto 0) := (others => 'X');

  signal enable1           : MEMV := (others => 'X');
  signal enable2           : MEMV := (others => 'X');
  signal bankIsGood_d1     : MEMV := (others => 'X');
  signal bankIsGood_d2     : MEMV := (others => 'X');
  signal bankIsSelected1   : X01 := 'X';
  signal bankIsSelected2   : X01 := 'X';
  signal oebDelayed1       : MEMV := (others => 'X');
  signal oebDelayed2       : MEMV := (others => 'X');
  signal intBus1           : MEMV := (others => 'X');
  signal intBus2           : MEMV := (others => 'X');
  signal address1          : integer := -1;
  signal address2          : integer := -1;
  signal active_addr1      : integer := -1;
  signal active_addr2      : integer := -1;
  signal memory            : MEM := (others => (others => 'X'));
  signal buff1             : MEMV := (others => 'X');
  signal buff2             : MEMV := (others => 'X');
  signal go_out1       : boolean := false;
  signal go_out2       : boolean := false;
  
  signal en_read1write2 : std_logic := '1';
  signal en_write1read2 : std_logic := '1';
  signal en_write1write2 : std_logic := '1';
  signal setOut1toX : BOOLEAN := FALSE;
  signal setOut2toX : BOOLEAN := FALSE;
  
  signal rwc : X01 := 'X';
  signal A1eqA2 : X01 := 'X';
  signal BA1_int : X01 := 'X';
  signal BA2_int : X01 := 'X';
  
  signal start             : boolean := FALSE;

  attribute VITAL_LEVEL0 of dpram4096x36_behave : architecture is True;

BEGIN

  ----------------------------------------------------------------------
  -- print_header:
  --
  -- Printing copyright header if generic is set to true (default).
  ----------------------------------------------------------------------

  start <= TRUE;

  print_header: process (start)
    variable header_printed: boolean := FALSE;
  begin
    if (NOW = 0 ns and display_header = TRUE and header_printed = FALSE) then
      Write_Message ("                                                          ");
      Write_Message ("            SYNCHRONOUS RAM VHDL BEHAVIOURAL MODEL        ");
      Write_Message ("                                                          ");
      Write_Message ("                     Synopsys Inc.                       ");
      Write_Message ("                                                          ");
      Write_Message ("                                                          ");
      Write_Message (" ");
      Write_Message (" ");
      case verbose is
        when 0 => Write_Message ("  Simulation running in verbose level 0:");
                  Write_Message ("     - NO checks done,");
                  Write_Message ("     - memory core NOT touched in case of violations,");
                  Write_Message ("     - internal output latch NOT touched in case of violations,");
                  Write_Message ("     - NO unknown when reading unknown or not existing address,");
                  Write_Message ("     - NO output messages generated.");
        when 1 => Write_Message ("  Simulation running in verbose level 1:");
                  Write_Message ("     - checks done,");
                  Write_Message ("     - memory core NOT touched in case of violations,");
                  Write_Message ("     - internal output latch NOT touched in case of violations,");
                  Write_Message ("     - NO unknown when reading unknown or not existing address,");
                  Write_Message ("     - output messages generated.");
        when 2 => Write_Message ("  Simulation running in verbose level 2:");
                  Write_Message ("     - checks done,");
                  Write_Message ("     - memory core touched in case of violations,");
                  Write_Message ("     - internal output latch touched in case of violations,");
                  Write_Message ("     - unknown when reading unknown or not existing address,");
                  Write_Message ("     - NO output messages generated.");
        when 3 => Write_Message ("  Simulation running in verbose level 3: (default)");
                  Write_Message ("     - checks done,");
                  Write_Message ("     - memory core touched in case of violations,");
                  Write_Message ("     - internal output latch touched in case of violations,");
                  Write_Message ("     - unknown when reading unknown or not existing address,");
                  Write_Message ("     - output messages generated.");
        when others => 
                  Write_Message ("  Simulation running in verbose level 3: (default)");
                  Write_Message ("     - checks done,");
                  Write_Message ("     - memory core touched in case of violations,");
                  Write_Message ("     - internal output latch touched in case of violations,");
                  Write_Message ("     - unknown when reading unknown or not existing address,");
                  Write_Message ("     - output messages generated.");
      end case;
      Write_Message (" ");
      Write_Message (" ");

      if ((debug = 1 or debug = 2) and verbose /= 0 and verbose /= 1 and verbose /= 2) then
        rep_timing(tpd_CEB1_O1(35)(tr10), "tpd_CEB1_O1(35)", "2.29 ns*1.0",NOW);
        rep_timing(tpd_CEB1_O1(34)(tr10), "tpd_CEB1_O1(34)", "2.29 ns*1.0",NOW);
        rep_timing(tpd_CEB1_O1(33)(tr10), "tpd_CEB1_O1(33)", "2.29 ns*1.0",NOW);
        rep_timing(tpd_CEB1_O1(32)(tr10), "tpd_CEB1_O1(32)", "2.29 ns*1.0",NOW);
        rep_timing(tpd_CEB1_O1(31)(tr10), "tpd_CEB1_O1(31)", "2.29 ns*1.0",NOW);
        rep_timing(tpd_CEB1_O1(30)(tr10), "tpd_CEB1_O1(30)", "2.29 ns*1.0",NOW);
        rep_timing(tpd_CEB1_O1(29)(tr10), "tpd_CEB1_O1(29)", "2.29 ns*1.0",NOW);
        rep_timing(tpd_CEB1_O1(28)(tr10), "tpd_CEB1_O1(28)", "2.29 ns*1.0",NOW);
        rep_timing(tpd_CEB1_O1(27)(tr10), "tpd_CEB1_O1(27)", "2.29 ns*1.0",NOW);
        rep_timing(tpd_CEB1_O1(26)(tr10), "tpd_CEB1_O1(26)", "2.29 ns*1.0",NOW);
        rep_timing(tpd_CEB1_O1(25)(tr10), "tpd_CEB1_O1(25)", "2.29 ns*1.0",NOW);
        rep_timing(tpd_CEB1_O1(24)(tr10), "tpd_CEB1_O1(24)", "2.29 ns*1.0",NOW);
        rep_timing(tpd_CEB1_O1(23)(tr10), "tpd_CEB1_O1(23)", "2.29 ns*1.0",NOW);
        rep_timing(tpd_CEB1_O1(22)(tr10), "tpd_CEB1_O1(22)", "2.29 ns*1.0",NOW);
        rep_timing(tpd_CEB1_O1(21)(tr10), "tpd_CEB1_O1(21)", "2.29 ns*1.0",NOW);
        rep_timing(tpd_CEB1_O1(20)(tr10), "tpd_CEB1_O1(20)", "2.29 ns*1.0",NOW);
        rep_timing(tpd_CEB1_O1(19)(tr10), "tpd_CEB1_O1(19)", "2.29 ns*1.0",NOW);
        rep_timing(tpd_CEB1_O1(18)(tr10), "tpd_CEB1_O1(18)", "2.29 ns*1.0",NOW);
        rep_timing(tpd_CEB1_O1(17)(tr10), "tpd_CEB1_O1(17)", "2.29 ns*1.0",NOW);
        rep_timing(tpd_CEB1_O1(16)(tr10), "tpd_CEB1_O1(16)", "2.29 ns*1.0",NOW);
        rep_timing(tpd_CEB1_O1(15)(tr10), "tpd_CEB1_O1(15)", "2.29 ns*1.0",NOW);
        rep_timing(tpd_CEB1_O1(14)(tr10), "tpd_CEB1_O1(14)", "2.29 ns*1.0",NOW);
        rep_timing(tpd_CEB1_O1(13)(tr10), "tpd_CEB1_O1(13)", "2.29 ns*1.0",NOW);
        rep_timing(tpd_CEB1_O1(12)(tr10), "tpd_CEB1_O1(12)", "2.29 ns*1.0",NOW);
        rep_timing(tpd_CEB1_O1(11)(tr10), "tpd_CEB1_O1(11)", "2.29 ns*1.0",NOW);
        rep_timing(tpd_CEB1_O1(10)(tr10), "tpd_CEB1_O1(10)", "2.29 ns*1.0",NOW);
        rep_timing(tpd_CEB1_O1(9)(tr10), "tpd_CEB1_O1(9)", "2.29 ns*1.0",NOW);
        rep_timing(tpd_CEB1_O1(8)(tr10), "tpd_CEB1_O1(8)", "2.29 ns*1.0",NOW);
        rep_timing(tpd_CEB1_O1(7)(tr10), "tpd_CEB1_O1(7)", "2.29 ns*1.0",NOW);
        rep_timing(tpd_CEB1_O1(6)(tr10), "tpd_CEB1_O1(6)", "2.29 ns*1.0",NOW);
        rep_timing(tpd_CEB1_O1(5)(tr10), "tpd_CEB1_O1(5)", "2.29 ns*1.0",NOW);
        rep_timing(tpd_CEB1_O1(4)(tr10), "tpd_CEB1_O1(4)", "2.29 ns*1.0",NOW);
        rep_timing(tpd_CEB1_O1(3)(tr10), "tpd_CEB1_O1(3)", "2.29 ns*1.0",NOW);
        rep_timing(tpd_CEB1_O1(2)(tr10), "tpd_CEB1_O1(2)", "2.29 ns*1.0",NOW);
        rep_timing(tpd_CEB1_O1(1)(tr10), "tpd_CEB1_O1(1)", "2.29 ns*1.0",NOW);
        rep_timing(tpd_CEB1_O1(0)(tr10), "tpd_CEB1_O1(0)", "2.29 ns*1.0",NOW);

        rep_timing(tpd_CEB2_O2(35)(tr10), "tpd_CEB2_O2(35)", "2.29 ns*1.0",NOW);
        rep_timing(tpd_CEB2_O2(34)(tr10), "tpd_CEB2_O2(34)", "2.29 ns*1.0",NOW);
        rep_timing(tpd_CEB2_O2(33)(tr10), "tpd_CEB2_O2(33)", "2.29 ns*1.0",NOW);
        rep_timing(tpd_CEB2_O2(32)(tr10), "tpd_CEB2_O2(32)", "2.29 ns*1.0",NOW);
        rep_timing(tpd_CEB2_O2(31)(tr10), "tpd_CEB2_O2(31)", "2.29 ns*1.0",NOW);
        rep_timing(tpd_CEB2_O2(30)(tr10), "tpd_CEB2_O2(30)", "2.29 ns*1.0",NOW);
        rep_timing(tpd_CEB2_O2(29)(tr10), "tpd_CEB2_O2(29)", "2.29 ns*1.0",NOW);
        rep_timing(tpd_CEB2_O2(28)(tr10), "tpd_CEB2_O2(28)", "2.29 ns*1.0",NOW);
        rep_timing(tpd_CEB2_O2(27)(tr10), "tpd_CEB2_O2(27)", "2.29 ns*1.0",NOW);
        rep_timing(tpd_CEB2_O2(26)(tr10), "tpd_CEB2_O2(26)", "2.29 ns*1.0",NOW);
        rep_timing(tpd_CEB2_O2(25)(tr10), "tpd_CEB2_O2(25)", "2.29 ns*1.0",NOW);
        rep_timing(tpd_CEB2_O2(24)(tr10), "tpd_CEB2_O2(24)", "2.29 ns*1.0",NOW);
        rep_timing(tpd_CEB2_O2(23)(tr10), "tpd_CEB2_O2(23)", "2.29 ns*1.0",NOW);
        rep_timing(tpd_CEB2_O2(22)(tr10), "tpd_CEB2_O2(22)", "2.29 ns*1.0",NOW);
        rep_timing(tpd_CEB2_O2(21)(tr10), "tpd_CEB2_O2(21)", "2.29 ns*1.0",NOW);
        rep_timing(tpd_CEB2_O2(20)(tr10), "tpd_CEB2_O2(20)", "2.29 ns*1.0",NOW);
        rep_timing(tpd_CEB2_O2(19)(tr10), "tpd_CEB2_O2(19)", "2.29 ns*1.0",NOW);
        rep_timing(tpd_CEB2_O2(18)(tr10), "tpd_CEB2_O2(18)", "2.29 ns*1.0",NOW);
        rep_timing(tpd_CEB2_O2(17)(tr10), "tpd_CEB2_O2(17)", "2.29 ns*1.0",NOW);
        rep_timing(tpd_CEB2_O2(16)(tr10), "tpd_CEB2_O2(16)", "2.29 ns*1.0",NOW);
        rep_timing(tpd_CEB2_O2(15)(tr10), "tpd_CEB2_O2(15)", "2.29 ns*1.0",NOW);
        rep_timing(tpd_CEB2_O2(14)(tr10), "tpd_CEB2_O2(14)", "2.29 ns*1.0",NOW);
        rep_timing(tpd_CEB2_O2(13)(tr10), "tpd_CEB2_O2(13)", "2.29 ns*1.0",NOW);
        rep_timing(tpd_CEB2_O2(12)(tr10), "tpd_CEB2_O2(12)", "2.29 ns*1.0",NOW);
        rep_timing(tpd_CEB2_O2(11)(tr10), "tpd_CEB2_O2(11)", "2.29 ns*1.0",NOW);
        rep_timing(tpd_CEB2_O2(10)(tr10), "tpd_CEB2_O2(10)", "2.29 ns*1.0",NOW);
        rep_timing(tpd_CEB2_O2(9)(tr10), "tpd_CEB2_O2(9)", "2.29 ns*1.0",NOW);
        rep_timing(tpd_CEB2_O2(8)(tr10), "tpd_CEB2_O2(8)", "2.29 ns*1.0",NOW);
        rep_timing(tpd_CEB2_O2(7)(tr10), "tpd_CEB2_O2(7)", "2.29 ns*1.0",NOW);
        rep_timing(tpd_CEB2_O2(6)(tr10), "tpd_CEB2_O2(6)", "2.29 ns*1.0",NOW);
        rep_timing(tpd_CEB2_O2(5)(tr10), "tpd_CEB2_O2(5)", "2.29 ns*1.0",NOW);
        rep_timing(tpd_CEB2_O2(4)(tr10), "tpd_CEB2_O2(4)", "2.29 ns*1.0",NOW);
        rep_timing(tpd_CEB2_O2(3)(tr10), "tpd_CEB2_O2(3)", "2.29 ns*1.0",NOW);
        rep_timing(tpd_CEB2_O2(2)(tr10), "tpd_CEB2_O2(2)", "2.29 ns*1.0",NOW);
        rep_timing(tpd_CEB2_O2(1)(tr10), "tpd_CEB2_O2(1)", "2.29 ns*1.0",NOW);
        rep_timing(tpd_CEB2_O2(0)(tr10), "tpd_CEB2_O2(0)", "2.29 ns*1.0",NOW);

        rep_timing(tpd_OEB1_O1(35)(tr0z), "tpd_OEB1_O1(35)(tr0z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(35)(trz1), "tpd_OEB1_O1(35)(trz1)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(35)(tr1z), "tpd_OEB1_O1(35)(tr1z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(35)(trz0), "tpd_OEB1_O1(35)(trz0)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(34)(tr0z), "tpd_OEB1_O1(34)(tr0z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(34)(trz1), "tpd_OEB1_O1(34)(trz1)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(34)(tr1z), "tpd_OEB1_O1(34)(tr1z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(34)(trz0), "tpd_OEB1_O1(34)(trz0)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(33)(tr0z), "tpd_OEB1_O1(33)(tr0z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(33)(trz1), "tpd_OEB1_O1(33)(trz1)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(33)(tr1z), "tpd_OEB1_O1(33)(tr1z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(33)(trz0), "tpd_OEB1_O1(33)(trz0)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(32)(tr0z), "tpd_OEB1_O1(32)(tr0z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(32)(trz1), "tpd_OEB1_O1(32)(trz1)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(32)(tr1z), "tpd_OEB1_O1(32)(tr1z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(32)(trz0), "tpd_OEB1_O1(32)(trz0)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(31)(tr0z), "tpd_OEB1_O1(31)(tr0z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(31)(trz1), "tpd_OEB1_O1(31)(trz1)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(31)(tr1z), "tpd_OEB1_O1(31)(tr1z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(31)(trz0), "tpd_OEB1_O1(31)(trz0)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(30)(tr0z), "tpd_OEB1_O1(30)(tr0z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(30)(trz1), "tpd_OEB1_O1(30)(trz1)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(30)(tr1z), "tpd_OEB1_O1(30)(tr1z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(30)(trz0), "tpd_OEB1_O1(30)(trz0)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(29)(tr0z), "tpd_OEB1_O1(29)(tr0z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(29)(trz1), "tpd_OEB1_O1(29)(trz1)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(29)(tr1z), "tpd_OEB1_O1(29)(tr1z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(29)(trz0), "tpd_OEB1_O1(29)(trz0)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(28)(tr0z), "tpd_OEB1_O1(28)(tr0z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(28)(trz1), "tpd_OEB1_O1(28)(trz1)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(28)(tr1z), "tpd_OEB1_O1(28)(tr1z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(28)(trz0), "tpd_OEB1_O1(28)(trz0)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(27)(tr0z), "tpd_OEB1_O1(27)(tr0z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(27)(trz1), "tpd_OEB1_O1(27)(trz1)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(27)(tr1z), "tpd_OEB1_O1(27)(tr1z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(27)(trz0), "tpd_OEB1_O1(27)(trz0)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(26)(tr0z), "tpd_OEB1_O1(26)(tr0z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(26)(trz1), "tpd_OEB1_O1(26)(trz1)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(26)(tr1z), "tpd_OEB1_O1(26)(tr1z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(26)(trz0), "tpd_OEB1_O1(26)(trz0)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(25)(tr0z), "tpd_OEB1_O1(25)(tr0z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(25)(trz1), "tpd_OEB1_O1(25)(trz1)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(25)(tr1z), "tpd_OEB1_O1(25)(tr1z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(25)(trz0), "tpd_OEB1_O1(25)(trz0)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(24)(tr0z), "tpd_OEB1_O1(24)(tr0z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(24)(trz1), "tpd_OEB1_O1(24)(trz1)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(24)(tr1z), "tpd_OEB1_O1(24)(tr1z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(24)(trz0), "tpd_OEB1_O1(24)(trz0)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(23)(tr0z), "tpd_OEB1_O1(23)(tr0z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(23)(trz1), "tpd_OEB1_O1(23)(trz1)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(23)(tr1z), "tpd_OEB1_O1(23)(tr1z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(23)(trz0), "tpd_OEB1_O1(23)(trz0)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(22)(tr0z), "tpd_OEB1_O1(22)(tr0z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(22)(trz1), "tpd_OEB1_O1(22)(trz1)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(22)(tr1z), "tpd_OEB1_O1(22)(tr1z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(22)(trz0), "tpd_OEB1_O1(22)(trz0)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(21)(tr0z), "tpd_OEB1_O1(21)(tr0z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(21)(trz1), "tpd_OEB1_O1(21)(trz1)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(21)(tr1z), "tpd_OEB1_O1(21)(tr1z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(21)(trz0), "tpd_OEB1_O1(21)(trz0)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(20)(tr0z), "tpd_OEB1_O1(20)(tr0z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(20)(trz1), "tpd_OEB1_O1(20)(trz1)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(20)(tr1z), "tpd_OEB1_O1(20)(tr1z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(20)(trz0), "tpd_OEB1_O1(20)(trz0)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(19)(tr0z), "tpd_OEB1_O1(19)(tr0z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(19)(trz1), "tpd_OEB1_O1(19)(trz1)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(19)(tr1z), "tpd_OEB1_O1(19)(tr1z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(19)(trz0), "tpd_OEB1_O1(19)(trz0)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(18)(tr0z), "tpd_OEB1_O1(18)(tr0z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(18)(trz1), "tpd_OEB1_O1(18)(trz1)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(18)(tr1z), "tpd_OEB1_O1(18)(tr1z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(18)(trz0), "tpd_OEB1_O1(18)(trz0)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(17)(tr0z), "tpd_OEB1_O1(17)(tr0z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(17)(trz1), "tpd_OEB1_O1(17)(trz1)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(17)(tr1z), "tpd_OEB1_O1(17)(tr1z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(17)(trz0), "tpd_OEB1_O1(17)(trz0)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(16)(tr0z), "tpd_OEB1_O1(16)(tr0z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(16)(trz1), "tpd_OEB1_O1(16)(trz1)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(16)(tr1z), "tpd_OEB1_O1(16)(tr1z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(16)(trz0), "tpd_OEB1_O1(16)(trz0)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(15)(tr0z), "tpd_OEB1_O1(15)(tr0z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(15)(trz1), "tpd_OEB1_O1(15)(trz1)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(15)(tr1z), "tpd_OEB1_O1(15)(tr1z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(15)(trz0), "tpd_OEB1_O1(15)(trz0)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(14)(tr0z), "tpd_OEB1_O1(14)(tr0z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(14)(trz1), "tpd_OEB1_O1(14)(trz1)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(14)(tr1z), "tpd_OEB1_O1(14)(tr1z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(14)(trz0), "tpd_OEB1_O1(14)(trz0)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(13)(tr0z), "tpd_OEB1_O1(13)(tr0z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(13)(trz1), "tpd_OEB1_O1(13)(trz1)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(13)(tr1z), "tpd_OEB1_O1(13)(tr1z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(13)(trz0), "tpd_OEB1_O1(13)(trz0)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(12)(tr0z), "tpd_OEB1_O1(12)(tr0z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(12)(trz1), "tpd_OEB1_O1(12)(trz1)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(12)(tr1z), "tpd_OEB1_O1(12)(tr1z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(12)(trz0), "tpd_OEB1_O1(12)(trz0)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(11)(tr0z), "tpd_OEB1_O1(11)(tr0z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(11)(trz1), "tpd_OEB1_O1(11)(trz1)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(11)(tr1z), "tpd_OEB1_O1(11)(tr1z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(11)(trz0), "tpd_OEB1_O1(11)(trz0)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(10)(tr0z), "tpd_OEB1_O1(10)(tr0z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(10)(trz1), "tpd_OEB1_O1(10)(trz1)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(10)(tr1z), "tpd_OEB1_O1(10)(tr1z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(10)(trz0), "tpd_OEB1_O1(10)(trz0)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(9)(tr0z), "tpd_OEB1_O1(9)(tr0z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(9)(trz1), "tpd_OEB1_O1(9)(trz1)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(9)(tr1z), "tpd_OEB1_O1(9)(tr1z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(9)(trz0), "tpd_OEB1_O1(9)(trz0)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(8)(tr0z), "tpd_OEB1_O1(8)(tr0z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(8)(trz1), "tpd_OEB1_O1(8)(trz1)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(8)(tr1z), "tpd_OEB1_O1(8)(tr1z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(8)(trz0), "tpd_OEB1_O1(8)(trz0)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(7)(tr0z), "tpd_OEB1_O1(7)(tr0z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(7)(trz1), "tpd_OEB1_O1(7)(trz1)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(7)(tr1z), "tpd_OEB1_O1(7)(tr1z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(7)(trz0), "tpd_OEB1_O1(7)(trz0)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(6)(tr0z), "tpd_OEB1_O1(6)(tr0z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(6)(trz1), "tpd_OEB1_O1(6)(trz1)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(6)(tr1z), "tpd_OEB1_O1(6)(tr1z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(6)(trz0), "tpd_OEB1_O1(6)(trz0)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(5)(tr0z), "tpd_OEB1_O1(5)(tr0z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(5)(trz1), "tpd_OEB1_O1(5)(trz1)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(5)(tr1z), "tpd_OEB1_O1(5)(tr1z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(5)(trz0), "tpd_OEB1_O1(5)(trz0)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(4)(tr0z), "tpd_OEB1_O1(4)(tr0z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(4)(trz1), "tpd_OEB1_O1(4)(trz1)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(4)(tr1z), "tpd_OEB1_O1(4)(tr1z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(4)(trz0), "tpd_OEB1_O1(4)(trz0)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(3)(tr0z), "tpd_OEB1_O1(3)(tr0z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(3)(trz1), "tpd_OEB1_O1(3)(trz1)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(3)(tr1z), "tpd_OEB1_O1(3)(tr1z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(3)(trz0), "tpd_OEB1_O1(3)(trz0)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(2)(tr0z), "tpd_OEB1_O1(2)(tr0z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(2)(trz1), "tpd_OEB1_O1(2)(trz1)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(2)(tr1z), "tpd_OEB1_O1(2)(tr1z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(2)(trz0), "tpd_OEB1_O1(2)(trz0)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(1)(tr0z), "tpd_OEB1_O1(1)(tr0z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(1)(trz1), "tpd_OEB1_O1(1)(trz1)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(1)(tr1z), "tpd_OEB1_O1(1)(tr1z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(1)(trz0), "tpd_OEB1_O1(1)(trz0)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(0)(tr0z), "tpd_OEB1_O1(0)(tr0z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(0)(trz1), "tpd_OEB1_O1(0)(trz1)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(0)(tr1z), "tpd_OEB1_O1(0)(tr1z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB1_O1(0)(trz0), "tpd_OEB1_O1(0)(trz0)", "0.744 ns*1.0",NOW);


        rep_timing(tpd_OEB2_O2(35)(tr0z), "tpd_OEB2_O2(35)(tr0z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(35)(trz1), "tpd_OEB2_O2(35)(trz1)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(35)(tr1z), "tpd_OEB2_O2(35)(tr1z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(35)(trz0), "tpd_OEB2_O2(35)(trz0)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(34)(tr0z), "tpd_OEB2_O2(34)(tr0z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(34)(trz1), "tpd_OEB2_O2(34)(trz1)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(34)(tr1z), "tpd_OEB2_O2(34)(tr1z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(34)(trz0), "tpd_OEB2_O2(34)(trz0)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(33)(tr0z), "tpd_OEB2_O2(33)(tr0z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(33)(trz1), "tpd_OEB2_O2(33)(trz1)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(33)(tr1z), "tpd_OEB2_O2(33)(tr1z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(33)(trz0), "tpd_OEB2_O2(33)(trz0)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(32)(tr0z), "tpd_OEB2_O2(32)(tr0z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(32)(trz1), "tpd_OEB2_O2(32)(trz1)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(32)(tr1z), "tpd_OEB2_O2(32)(tr1z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(32)(trz0), "tpd_OEB2_O2(32)(trz0)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(31)(tr0z), "tpd_OEB2_O2(31)(tr0z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(31)(trz1), "tpd_OEB2_O2(31)(trz1)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(31)(tr1z), "tpd_OEB2_O2(31)(tr1z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(31)(trz0), "tpd_OEB2_O2(31)(trz0)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(30)(tr0z), "tpd_OEB2_O2(30)(tr0z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(30)(trz1), "tpd_OEB2_O2(30)(trz1)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(30)(tr1z), "tpd_OEB2_O2(30)(tr1z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(30)(trz0), "tpd_OEB2_O2(30)(trz0)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(29)(tr0z), "tpd_OEB2_O2(29)(tr0z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(29)(trz1), "tpd_OEB2_O2(29)(trz1)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(29)(tr1z), "tpd_OEB2_O2(29)(tr1z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(29)(trz0), "tpd_OEB2_O2(29)(trz0)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(28)(tr0z), "tpd_OEB2_O2(28)(tr0z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(28)(trz1), "tpd_OEB2_O2(28)(trz1)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(28)(tr1z), "tpd_OEB2_O2(28)(tr1z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(28)(trz0), "tpd_OEB2_O2(28)(trz0)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(27)(tr0z), "tpd_OEB2_O2(27)(tr0z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(27)(trz1), "tpd_OEB2_O2(27)(trz1)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(27)(tr1z), "tpd_OEB2_O2(27)(tr1z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(27)(trz0), "tpd_OEB2_O2(27)(trz0)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(26)(tr0z), "tpd_OEB2_O2(26)(tr0z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(26)(trz1), "tpd_OEB2_O2(26)(trz1)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(26)(tr1z), "tpd_OEB2_O2(26)(tr1z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(26)(trz0), "tpd_OEB2_O2(26)(trz0)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(25)(tr0z), "tpd_OEB2_O2(25)(tr0z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(25)(trz1), "tpd_OEB2_O2(25)(trz1)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(25)(tr1z), "tpd_OEB2_O2(25)(tr1z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(25)(trz0), "tpd_OEB2_O2(25)(trz0)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(24)(tr0z), "tpd_OEB2_O2(24)(tr0z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(24)(trz1), "tpd_OEB2_O2(24)(trz1)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(24)(tr1z), "tpd_OEB2_O2(24)(tr1z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(24)(trz0), "tpd_OEB2_O2(24)(trz0)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(23)(tr0z), "tpd_OEB2_O2(23)(tr0z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(23)(trz1), "tpd_OEB2_O2(23)(trz1)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(23)(tr1z), "tpd_OEB2_O2(23)(tr1z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(23)(trz0), "tpd_OEB2_O2(23)(trz0)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(22)(tr0z), "tpd_OEB2_O2(22)(tr0z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(22)(trz1), "tpd_OEB2_O2(22)(trz1)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(22)(tr1z), "tpd_OEB2_O2(22)(tr1z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(22)(trz0), "tpd_OEB2_O2(22)(trz0)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(21)(tr0z), "tpd_OEB2_O2(21)(tr0z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(21)(trz1), "tpd_OEB2_O2(21)(trz1)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(21)(tr1z), "tpd_OEB2_O2(21)(tr1z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(21)(trz0), "tpd_OEB2_O2(21)(trz0)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(20)(tr0z), "tpd_OEB2_O2(20)(tr0z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(20)(trz1), "tpd_OEB2_O2(20)(trz1)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(20)(tr1z), "tpd_OEB2_O2(20)(tr1z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(20)(trz0), "tpd_OEB2_O2(20)(trz0)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(19)(tr0z), "tpd_OEB2_O2(19)(tr0z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(19)(trz1), "tpd_OEB2_O2(19)(trz1)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(19)(tr1z), "tpd_OEB2_O2(19)(tr1z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(19)(trz0), "tpd_OEB2_O2(19)(trz0)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(18)(tr0z), "tpd_OEB2_O2(18)(tr0z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(18)(trz1), "tpd_OEB2_O2(18)(trz1)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(18)(tr1z), "tpd_OEB2_O2(18)(tr1z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(18)(trz0), "tpd_OEB2_O2(18)(trz0)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(17)(tr0z), "tpd_OEB2_O2(17)(tr0z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(17)(trz1), "tpd_OEB2_O2(17)(trz1)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(17)(tr1z), "tpd_OEB2_O2(17)(tr1z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(17)(trz0), "tpd_OEB2_O2(17)(trz0)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(16)(tr0z), "tpd_OEB2_O2(16)(tr0z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(16)(trz1), "tpd_OEB2_O2(16)(trz1)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(16)(tr1z), "tpd_OEB2_O2(16)(tr1z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(16)(trz0), "tpd_OEB2_O2(16)(trz0)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(15)(tr0z), "tpd_OEB2_O2(15)(tr0z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(15)(trz1), "tpd_OEB2_O2(15)(trz1)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(15)(tr1z), "tpd_OEB2_O2(15)(tr1z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(15)(trz0), "tpd_OEB2_O2(15)(trz0)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(14)(tr0z), "tpd_OEB2_O2(14)(tr0z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(14)(trz1), "tpd_OEB2_O2(14)(trz1)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(14)(tr1z), "tpd_OEB2_O2(14)(tr1z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(14)(trz0), "tpd_OEB2_O2(14)(trz0)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(13)(tr0z), "tpd_OEB2_O2(13)(tr0z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(13)(trz1), "tpd_OEB2_O2(13)(trz1)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(13)(tr1z), "tpd_OEB2_O2(13)(tr1z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(13)(trz0), "tpd_OEB2_O2(13)(trz0)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(12)(tr0z), "tpd_OEB2_O2(12)(tr0z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(12)(trz1), "tpd_OEB2_O2(12)(trz1)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(12)(tr1z), "tpd_OEB2_O2(12)(tr1z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(12)(trz0), "tpd_OEB2_O2(12)(trz0)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(11)(tr0z), "tpd_OEB2_O2(11)(tr0z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(11)(trz1), "tpd_OEB2_O2(11)(trz1)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(11)(tr1z), "tpd_OEB2_O2(11)(tr1z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(11)(trz0), "tpd_OEB2_O2(11)(trz0)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(10)(tr0z), "tpd_OEB2_O2(10)(tr0z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(10)(trz1), "tpd_OEB2_O2(10)(trz1)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(10)(tr1z), "tpd_OEB2_O2(10)(tr1z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(10)(trz0), "tpd_OEB2_O2(10)(trz0)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(9)(tr0z), "tpd_OEB2_O2(9)(tr0z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(9)(trz1), "tpd_OEB2_O2(9)(trz1)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(9)(tr1z), "tpd_OEB2_O2(9)(tr1z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(9)(trz0), "tpd_OEB2_O2(9)(trz0)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(8)(tr0z), "tpd_OEB2_O2(8)(tr0z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(8)(trz1), "tpd_OEB2_O2(8)(trz1)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(8)(tr1z), "tpd_OEB2_O2(8)(tr1z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(8)(trz0), "tpd_OEB2_O2(8)(trz0)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(7)(tr0z), "tpd_OEB2_O2(7)(tr0z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(7)(trz1), "tpd_OEB2_O2(7)(trz1)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(7)(tr1z), "tpd_OEB2_O2(7)(tr1z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(7)(trz0), "tpd_OEB2_O2(7)(trz0)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(6)(tr0z), "tpd_OEB2_O2(6)(tr0z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(6)(trz1), "tpd_OEB2_O2(6)(trz1)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(6)(tr1z), "tpd_OEB2_O2(6)(tr1z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(6)(trz0), "tpd_OEB2_O2(6)(trz0)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(5)(tr0z), "tpd_OEB2_O2(5)(tr0z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(5)(trz1), "tpd_OEB2_O2(5)(trz1)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(5)(tr1z), "tpd_OEB2_O2(5)(tr1z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(5)(trz0), "tpd_OEB2_O2(5)(trz0)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(4)(tr0z), "tpd_OEB2_O2(4)(tr0z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(4)(trz1), "tpd_OEB2_O2(4)(trz1)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(4)(tr1z), "tpd_OEB2_O2(4)(tr1z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(4)(trz0), "tpd_OEB2_O2(4)(trz0)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(3)(tr0z), "tpd_OEB2_O2(3)(tr0z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(3)(trz1), "tpd_OEB2_O2(3)(trz1)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(3)(tr1z), "tpd_OEB2_O2(3)(tr1z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(3)(trz0), "tpd_OEB2_O2(3)(trz0)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(2)(tr0z), "tpd_OEB2_O2(2)(tr0z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(2)(trz1), "tpd_OEB2_O2(2)(trz1)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(2)(tr1z), "tpd_OEB2_O2(2)(tr1z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(2)(trz0), "tpd_OEB2_O2(2)(trz0)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(1)(tr0z), "tpd_OEB2_O2(1)(tr0z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(1)(trz1), "tpd_OEB2_O2(1)(trz1)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(1)(tr1z), "tpd_OEB2_O2(1)(tr1z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(1)(trz0), "tpd_OEB2_O2(1)(trz0)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(0)(tr0z), "tpd_OEB2_O2(0)(tr0z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(0)(trz1), "tpd_OEB2_O2(0)(trz1)", "0.744 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(0)(tr1z), "tpd_OEB2_O2(0)(tr1z)", "0.784 ns*1.0",NOW);
        rep_timing(tpd_OEB2_O2(0)(trz0), "tpd_OEB2_O2(0)(trz0)", "0.744 ns*1.0",NOW);




     rep_timing(tsetup_WEB1_CEB1_negedge_negedge,  "tsetup_WEB1_CEB1_negedge_negedge  ", "0 ns*1.0",NOW);
        rep_timing(thold_WEB1_CEB1_negedge_negedge,   "thold_WEB1_CEB1_negedge_negedge   ", "0.329 ns*1.0",NOW);
        rep_timing(tsetup_A1_CEB1_negedge_negedge(0), "tsetup_A1_CEB1_negedge_negedge ", "0 ns*1.0",NOW);
        rep_timing(thold_A1_CEB1_negedge_negedge(0),  "thold_A1_CEB1_negedge_negedge ", "0.403 ns*1.0",NOW);
        rep_timing(tsetup_I1_CEB1_negedge_negedge(0), "tsetup_I1_CEB1_negedge_negedge ", "0.053 ns*1.0",NOW);
        rep_timing(thold_I1_CEB1_negedge_negedge(0),  "thold_I1_CEB1_negedge_negedge ", "0.408 ns*1.0",NOW);
        rep_timing(tsetup_CSB1_CEB1_negedge_negedge,  "tsetup_CSB1_CEB1_negedge_negedge  ", "0.294 ns*1.0",NOW);
        rep_timing(thold_CSB1_CEB1_negedge_negedge,   "thold_CSB1_CEB1_negedge_negedge   ", "0.053 ns*1.0",NOW);
        
        rep_timing(tsetup_WEB1_CEB1_posedge_negedge,  "tsetup_WEB1_CEB1_posedge_negedge  ", "0 ns*1.0",NOW);
        rep_timing(tsetup_A1_CEB1_posedge_negedge(0), "tsetup_A1_CEB1_posedge_negedge ", "0 ns*1.0",NOW);
        rep_timing(tsetup_I1_CEB1_posedge_negedge(0), "tsetup_I1_CEB1_posedge_negedge ", "0.053 ns*1.0",NOW);
        rep_timing(thold_I1_CEB1_posedge_negedge(0),  "thold_I1_CEB1_posedge_negedge ", "0.408 ns*1.0",NOW);
        rep_timing(tsetup_CSB1_CEB1_posedge_negedge,  "tsetup_CSB1_CEB1_posedge_negedge  ", "0.294 ns*1.0",NOW);
        rep_timing(thold_CSB1_CEB1_posedge_negedge,   "thold_CSB1_CEB1_posedge_negedge   ", "0.053 ns*1.0",NOW);






     rep_timing(tsetup_WEB2_CEB2_negedge_negedge,  "tsetup_WEB2_CEB2_negedge_negedge  ", "0 ns*1.0",NOW);
        rep_timing(thold_WEB2_CEB2_negedge_negedge,   "thold_WEB2_CEB2_negedge_negedge   ", "0.329 ns*1.0",NOW);
        rep_timing(tsetup_A2_CEB2_negedge_negedge(0), "tsetup_A2_CEB2_negedge_negedge ", "0 ns*1.0",NOW);
        rep_timing(thold_A2_CEB2_negedge_negedge(0),  "thold_A2_CEB2_negedge_negedge ", "0.403 ns*1.0",NOW);
        rep_timing(tsetup_I2_CEB2_negedge_negedge(0), "tsetup_I2_CEB2_negedge_negedge ", "0.053 ns*1.0",NOW);
        rep_timing(thold_I2_CEB2_negedge_negedge(0),  "thold_I2_CEB2_negedge_negedge ", "0.408 ns*1.0",NOW);
        rep_timing(tsetup_CSB2_CEB2_negedge_negedge,  "tsetup_CSB2_CEB2_negedge_negedge  ", "0.294 ns*1.0",NOW);
        rep_timing(thold_CSB2_CEB2_negedge_negedge,   "thold_CSB2_CEB2_negedge_negedge   ", "0.053 ns*1.0",NOW);
        
        rep_timing(tsetup_WEB2_CEB2_posedge_negedge,  "tsetup_WEB2_CEB2_posedge_negedge  ", "0 ns*1.0",NOW);
        rep_timing(tsetup_A2_CEB2_posedge_negedge(0), "tsetup_A2_CEB2_posedge_negedge ", "0 ns*1.0",NOW);
        rep_timing(tsetup_I2_CEB2_posedge_negedge(0), "tsetup_I2_CEB2_posedge_negedge ", "0.053 ns*1.0",NOW);
        rep_timing(thold_I2_CEB2_posedge_negedge(0),  "thold_I2_CEB2_posedge_negedge ", "0.408 ns*1.0",NOW);
        rep_timing(tsetup_CSB2_CEB2_posedge_negedge,  "tsetup_CSB2_CEB2_posedge_negedge  ", "0.294 ns*1.0",NOW);
        rep_timing(thold_CSB2_CEB2_posedge_negedge,   "thold_CSB2_CEB2_posedge_negedge   ", "0.053 ns*1.0",NOW);





      end if;

      header_printed := TRUE;
    end if;
  end process;

  ----------------------------------------------------------------------
  -- WireDelay:
  --
  -- Delaying all input ports by the interconnect path delay.
  ----------------------------------------------------------------------

  WireDelay: BLOCK
  begin

    WID1: for i in 0 to (numAddr-1) generate
      VitalWireDelay(A1_ipd(i), A1(i), tipd_A1(i));
      VitalWireDelay(A2_ipd(i), A2(i), tipd_A2(i));
    end generate;

    WID2: for j in 0 to (numOut-1) generate
      VitalWireDelay(I1_ipd(j), I1(j), tipd_I1(j));
      VitalWireDelay(I2_ipd(j), I2(j), tipd_I2(j));
    end generate;



    VitalWireDelay(CEB1_ipd, CEB1, tipd_CEB1);
    VitalWireDelay(CEB2_ipd, CEB2, tipd_CEB2);
    VitalWireDelay(WEB1_ipd, WEB1, tipd_WEB1);
    VitalWireDelay(WEB2_ipd, WEB2, tipd_WEB2);
    VitalWireDelay(OEB1_ipd, OEB1, tipd_OEB1);
    VitalWireDelay(OEB2_ipd, OEB2, tipd_OEB2);
    VitaLWireDelay(CSB1_ipd, CSB1, tipd_CSB1);
    VitaLWireDelay(CSB2_ipd, CSB2, tipd_CSB2);


  end block;

  ----------------------------------------------------------------------
  -- translate_state:
  --
  -- Translate the external signals to state signals, without the
  -- strength. This makes it easier to monitor changes in state.
  ----------------------------------------------------------------------

  translate_state: block
  begin
    IN1State     <= To_X01(I1_ipd);
    IN2State     <= To_X01(I2_ipd);
    OEB1State    <= To_X01(OEB1_ipd);
    OEB2State    <= To_X01(OEB2_ipd);
    CEB1State    <= To_X01(CEB1_ipd);
    CEB2State    <= To_X01(CEB2_ipd);
    WEB1State    <= To_X01(WEB1_ipd);
    WEB2State    <= To_X01(WEB2_ipd);
    CSB1State    <= To_X01(CSB1_ipd);
    CSB2State    <= To_X01(CSB2_ipd);
    A1State      <= To_X01(A1_ipd);
    A2State      <= To_X01(A2_ipd);
  end block;

  BA1_int <= '1';
  BA2_int <= '1';

  A1eqA2 <= isTrue(A1State = A2State);
  rwc <= A1eqA2 and not CSB1State and not CSB2State and BA1_int and BA2_int;
  en_read1write2 <= rwc and WEB1State and not WEB2State;
  en_write1read2 <= rwc and not WEB1State and WEB2State;
  en_write1write2 <= rwc and not WEB1State and not WEB2State;
  
  
  ----------------------------------------------------------------------
  -- address_check:
  --
  -- Calculating integer value of address and check if one of the
  -- address bits is either 'X' or 'Z'. If this is the case the
  -- integer value is set to -1.
  ----------------------------------------------------------------------

  address_check1: process(A1State)
  begin
      address1 <= X01toI(A1State);
      if (X01toI(A1State) >= wordDepth) then
        address1 <= -2;
      end if;
  end process address_check1;
  
  address_check2: process(A2State)
  begin
    address2 <= X01toI(A2State);
    if (X01toI(A2State) >= wordDepth) then
      address2 <= -2;
    end if;
  end process address_check2;


  ----------------------------------------------------------------------
  -- bankSelect:
  --
  -- Set statically to '1', because multiple banks are not used.
  ----------------------------------------------------------------------

  bankSelect: block
  begin
    bankIsSelected1 <= '1';
    bankIsSelected2 <= '1';
  end block;


  ----------------------------------------------------------------------
  -- delayOEB:
  --
  -- Delays the output enable signal about the path delay. By doing in
  -- this way there is no decision necessary when the output needs to
  -- be driven.
  ----------------------------------------------------------------------

  delayOEB1 : process(OEB1State)
  begin
  for j in intBus1'range loop
    case OEB1State is
      when '0' => oebDelayed1(j) <= transport '0' after tpd_OEB1_O1(j)(trz1);
      when '1' => oebDelayed1(j) <= transport '1' after tpd_OEB1_O1(j)(tr1z);
      when 'X' => 
        oebDelayed1(j) <= 'X';
        if (CSB1State = '0' or CSB1State = 'X') then
          Warn("OEB1 is unknown.",InstancePath,NOW,verbose);
        end if;
    end case;
  end loop;
  end process delayOEB1;

  delayOEB2 : process(OEB2State)
  begin
  for j in intBus2'range loop
    case OEB2State is
      when '0' => oebDelayed2(j) <= transport '0' after tpd_OEB2_O2(j)(trz1);
      when '1' => oebDelayed2(j) <= transport '1' after tpd_OEB2_O2(j)(tr1z);
      when 'X' => 
        oebDelayed2(j) <= 'X';
        if (CSB2State = '0' or CSB2State = 'X') then
          Warn("OEB2 is unknown.",InstancePath,NOW,verbose);
        end if;
    end case;
  end loop;
  end process delayOEB2;


  ----------------------------------------------------------------------
  -- delaySelectBlock:
  --
  -- Set statically to '1', because multiple banks are not used.
  ----------------------------------------------------------------------

  delaySelectBlock: block
  begin
    bankIsGood_d1 <= (others => '1');
    bankIsGood_d2 <= (others => '1');
  end block;


  ----------------------------------------------------------------------
  -- genEnable:
  --
  -- When the ram and the bank is selected, output enable (OEB) active
  -- and WEB inactive (just in case of common IO), i.e. an active read
  -- cycle, the internal signal 'enable' is generated. It's used in the
  -- output part to drive the value at the output pins.
  ----------------------------------------------------------------------

  genEnable1 : process(oebDelayed1,bankIsGood_d1
                      )
  begin
    enable1 <= bankIsGood_d1 and not oebDelayed1;
  end process genEnable1;

  genEnable2 : process(oebDelayed2,bankIsGood_d2
                      )
  begin
    enable2 <= bankIsGood_d2 and not oebDelayed2;
  end process genEnable2;

  read_write_cycle1 : process(CEB1State,CEB2State,setOut1toX,WEB1State,CSB1State,address1,IN1State
                      )
    variable cebLastRise1   : time := 0 ns;
    variable cebLastFall1   : time := 0 ns;
    variable xData : X01_vector(0 to numOut-1) := (others => 'X');
    variable cebLastFall2 : time := 0 ns;
    variable err_addr1      : integer := -1;
    variable error1        : boolean := false;
    variable out1_to_x    : boolean := false;
    variable ADDR_viol1    : boolean := false;
    variable BA_viol1    : boolean := false;
    variable WENB_viol1    : boolean := false;
    variable CSB_viol1    : boolean := false;
    variable WEB_viol1    : boolean := false;
    variable IN_viol1    : boolean := false;
    variable PULSE_viol1  : boolean := false;
    variable CLOCK_viol1  : boolean := false;
    variable read1      : boolean := false;
    variable write1      : boolean := false;
    variable addr1_old      : integer := -1;
    variable banksel1_old  : X01 := 'X';
    variable csb1_old    : X01 := 'X';
    variable web1_old    : X01 := 'X';
    variable in1_old      : X01_vector((numOut-1) downto 0) := (others => 'X');
  begin

    -----------------------------------
    -- Checks in respect to clock edges
    -----------------------------------
    if(CEB2State'event and CEB2State = '0') then
      cebLastFall2 := NOW;
    end if;
    if(setOut1toX'event) then
      if(setOut1toX) then
        for j in intBus1'range loop
          intBus1(j) <= 'X' after cebLastFall1 + tpd_CEB1_O1(j)(tr10) - NOW;
        end loop;
      end if;
    elsif(CEB1State'event or WEB1State'event or CSB1State'event or address1'event or IN1State'event
                      ) then
      if (CEB1State'last_event = 0 ns) and (NOW > cebLastFall1) then

      ----------------------------------------------------------------
      -- Checks at inactive edge of clock (also events from or to 'X')
      ----------------------------------------------------------------

        if (CEB1State'last_value = '0' and (CEB1State = '1' or CEB1State = 'X'))
          or (CEB1State'last_value = 'X' and CEB1State = '1') then
          if (verbose /= 0) then

          -- AC violation tests

            cebLastRise1 := NOW;
            if (cebLastRise1 - cebLastFall1 < tpw_CEB1_posedge) then
            -- tCLA (minimum clock low time)
              Warn("CEB1 low phase too short during cycle.",InstancePath,NOW,verbose);
              active_addr1 <= -1;
              buff1 <= (others => 'X');
              for j in intBus1'range loop
                intBus1(j) <= 'X' after cebLastFall1 + tpd_CEB1_O1(j)(tr10) - NOW;
              end loop;
            elsif (CEB1State = 'X') then
              Warn("CEB1 event from 0 to X.",InstancePath,NOW,verbose);
            elsif (CEB1State'last_value = 'X') then
              Warn("CEB1 event from X to 1.",InstancePath,NOW,verbose);
            end if;
          end if;
        end if;

      --------------------------------------------------------------
      -- Checks at active edge of clock (also events from or to 'X')
      --------------------------------------------------------------

        if ((CEB1State'last_value = '1' and (CEB1State = 'X' or CEB1State = '0'))
          or (CEB1State'last_value = 'X' and CEB1State = '0')) then
            if (verbose /= 0) then
              error1     := false;
              out1_to_x    := false;
              ADDR_viol1   := false;
              BA_viol1   := false;
              WENB_viol1   := false;
              CSB_viol1   := false;
              WEB_viol1   := false;
              IN_viol1   := false;
              CLOCK_viol1  := false;
              PULSE_viol1   := false;
              addr1_old    := address1;
              banksel1_old := bankIsSelected1;
              csb1_old    := CSB1State;
              web1_old    := WEB1State;
              in1_old    := IN1State;

          -- X-handling

              if (web1_old = 'X') then
                Warn("WEB1 unknown at active clock edge.",InstancePath,NOW,verbose);
                WEB_viol1 := true;
              end if;
              if (csb1_old = 'X') then
                Warn("CSB1 unknown at active clock edge.",InstancePath,NOW,verbose);
                CSB_viol1 := true;
              end if;
              if (banksel1_old = 'X') then
                Warn("BA1 unknown at active clock edge.",InstancePath,NOW,verbose);
                BA_viol1 := true;
              end if;
              if (addr1_old = -1) then
                Warn("Address1 unknown at active clock edge.",InstancePath,NOW,verbose);
                ADDR_viol1 := true;
              end if;

          -- AC violation tests

              if (A1State'last_event < max2(tsetup_A1_CEB1_negedge_negedge(0),tsetup_A1_CEB1_posedge_negedge(0))) then
                Warn("Address1 set up time not met.",InstancePath,NOW,verbose);
                ADDR_viol1 := true;
              end if;

              if(CSB1State = '0') then
                if (CSB1State'last_event < tsetup_CSB1_CEB1_negedge_negedge) then
                  Warn("CSB1 setup time not met.",InstancePath,NOW,verbose);
                  CSB_viol1 := true;
                end if;
              else
                if (CSB1State'last_event < tsetup_CSB1_CEB1_posedge_negedge) then
                  Warn("CSB1 setup time not met.",InstancePath,NOW,verbose);
                  CSB_viol1 := true;
                end if;
              end if;
              if(WEB1State = '0') then
                if (WEB1State'last_event < tsetup_WEB1_CEB1_negedge_negedge) then
                  Warn("WEB1 setup time not met.",InstancePath,NOW,verbose);
                  WEB_viol1 := true;
                end if;
              else
                if (WEB1State'last_event < tsetup_WEB1_CEB1_posedge_negedge) then
                  Warn("WEB1 setup time not met.",InstancePath,NOW,verbose);
                  WEB_viol1 := true;
                end if;
              end if;

              if (IN1State'last_event < max2(tsetup_I1_CEB1_negedge_negedge(0), tsetup_I1_CEB1_posedge_negedge(0))) then
                Warn("Data in setup time during write cycle not met.",InstancePath,NOW,verbose);
                IN_viol1 := true;
              end if;
              if (NOW - cebLastFall1 < tperiod_CEB1) then
                Warn("CEB1 period too short.",InstancePath,NOW,verbose);
                CLOCK_viol1 := true;
              end if;
              cebLastFall1 := NOW;
              if (CEB1State = 'X') then
                Warn("CEB1 event from 1 to X.",InstancePath,NOW,verbose);
                CLOCK_viol1 := true;
              end if;
          
              if (CEB1State'last_value = 'X') then
                Warn("CEB1 event from X to 0.",InstancePath,NOW,verbose);
                CLOCK_viol1 := true;
              end if;

              if (cebLastFall1 - cebLastRise1 < tpw_CEB1_negedge) then
            -- tCLP violation
                Warn("CEB1 high phase too short.",InstancePath,NOW,verbose);
                PULSE_viol1 := true;
                active_addr1 <= -1;
                buff1 <= (others => 'X');
                for j in intBus1'range loop
                   intBus1(j) <= 'X' after tpd_CEB1_O1(j)(tr10);
                end loop;
              end if;
  
              else cebLastFall1 := NOW;
              end if;
            end if;
          end if;
          
    ---------------------------------
    -- Checks after active clock edge
    ---------------------------------

          if ((CEB1State = '0') and not(PULSE_viol1)) then
    
            if (verbose /= 0) then
              if ((WEB1State'last_event = 0 ns) and (NOW > cebLastFall1) and 
                 ((WEB1State = '1' and (NOW - cebLastFall1 < thold_WEB1_CEB1_posedge_negedge)) or 
                 (WEB1State = '0' and (NOW - cebLastFall1 < thold_WEB1_CEB1_negedge_negedge)))) then
                Warn("WEB1 hold time not met.",InstancePath,NOW,verbose);
                WEB_viol1 := true;
              end if;
      
              if ((A1State'last_event = 0 ns) and  (NOW > cebLastFall1)) then
                for j in  A1State'range loop
                  if ((A1State(j) = '1' and (NOW - cebLastFall1 < thold_A1_CEB1_posedge_negedge(j))) or 
                     (A1State(j) = '0' and (NOW - cebLastFall1 < thold_A1_CEB1_negedge_negedge(j)))) then
                    Warn("Address1 hold time not met.",InstancePath,NOW,verbose);
                    ADDR_viol1 := true;
                  end if;
                end loop;
              end if;
    
              if(CSB1State = '0') then
                if (CSB1State'last_event = 0 ns) and  (NOW > cebLastFall1) and 
                   (NOW - cebLastFall1 < thold_CSB1_CEB1_negedge_negedge) then
                  Warn("CSB1 hold time not met.",InstancePath,NOW,verbose);
                  CSB_viol1 := true;
                end if;
              else
                if (CSB1State'last_event = 0 ns) and  (NOW > cebLastFall1) and 
                   (NOW - cebLastFall1 < thold_CSB1_CEB1_posedge_negedge) then
                  Warn("CSB1 hold time not met.",InstancePath,NOW,verbose);
                  CSB_viol1 := true;
                end if;
              end if;
    
              if (IN1State'last_event = 0 ns) and  (NOW > cebLastFall1) and 
                 (NOW - cebLastFall1 < max2(thold_I1_CEB1_negedge_negedge(0), thold_I1_CEB1_posedge_negedge(0))) then
                Warn("Data in hold time during write cycle not met.",InstancePath,NOW,verbose);
                IN_viol1 := true;
              end if;
            end if;

  -----------------              
  -- Make decision
  -----------------
    
            read1  := false;
            write1 := false;
    
            if (CSB_viol1 or (csb1_old /= '1')) and (BA_viol1 or (banksel1_old /= '0')) then
              if (WEB_viol1 and (web1_old /= '1')) or (CEB1State'event and (web1_old /= '1')) then write1 := true;
              elsif (WEB_viol1 and (web1_old /= '0')) or (CEB1State'event and (web1_old /= '0')) then read1 := true;
              end if;
            end if;
    
            if ADDR_viol1 then
              error1 := true;
              err_addr1 := -1;
            elsif (addr1_old = -2) then
              Warn("Address1 is out of range at active clock edge.",InstancePath,NOW,verbose);
              error1 := true;
              err_addr1 := -2;
            else err_addr1 := addr1_old;
            end if;
    
            if WEB_viol1 then
              out1_to_x := true;
              error1 := true;
            elsif CSB_viol1 then
              error1 := true;
            elsif BA_viol1 then
              error1 := true;
            elsif CLOCK_viol1 then
              if (web1_old = '0') then out1_to_x := true;  end if;
              error1 := true;
            elsif (web1_old = '0') then
              if IN_viol1 then
                out1_to_x := true;
                error1 := true;

              end if;
            end if;

        -- Reading memory location (modifying internal output latch)

            if read1 then
              if(NOW - cebLastFall2 < trecovery_CEB2_CEB1_negedge_negedge and en_read1write2 = '1') then
                Warn("Read/write operations for the same address are too close.",InstancePath,NOW,verbose);
                for j in intBus1'range loop
                  intBus1(j) <= 'X' after cebLastFall1 + tpd_CEB1_O1(j)(tr10) - NOW;
                end loop;
              elsif error1 then
                if (verbose /= 0 and verbose /= 1) then
                  for j in intBus1'range loop
                    intBus1(j) <= 'X' after cebLastFall1 + tpd_CEB1_O1(j)(tr10) - NOW;
                  end loop;
                  if ((debug = 1 or debug = 2) and verbose /= 0 and verbose /= 1 and verbose /= 2) then
                    Warn("  ==> Setting internal output1 latch unknown.",InstancePath,NOW);
                  end if;
                end if;
              else
                active_addr1 <= addr1_old;
                for j in intBus1'range loop
                  if (cebLastFall1 + tpd_CEB1_O1(j)(tr01) > NOW) then
                   intBus1(j) <= transport '1' after cebLastFall1 + tpd_CEB1_O1(j)(tr01) - NOW;
                  else
                   intBus1(j) <= transport '1' after 0 ns;
                  end if;
                  intBus1(j) <= transport memory(addr1_old)(j) after cebLastFall1 + tpd_CEB1_O1(j)(tr10) - NOW;
                end loop;
                if (verbose /= 0 and verbose /= 2 and debug = 2) then
                  Info("Setting internal output1 latch: ",memory(addr1_old),InstancePath,NOW);
                end if;
              end if;
            end if;
        
        -- Writing memory location

            if write1 then
              if(NOW - cebLastFall2 < trecovery_CEB2_CEB1_negedge_negedge and (en_write1read2 = '1' or en_write1write2 = '1')) then
                if(en_write1read2 = '1') then
                  Warn("Read/write operations for the same address are too close.",InstancePath,NOW,verbose);
                  setOut2toX <= TRUE;
                elsif(en_write1write2 = '1') then
                  setOut2toX <= FALSE;
                  Warn("Simulteneuos write to the same address.",InstancePath,NOW,verbose);
                  buff1 <= (others => 'X');
                  for j in intBus1'range loop
                    intBus1(j) <= 'X' after cebLastFall1 + tpd_CEB1_O1(j)(tr10) - NOW;
                  end loop;
                  active_addr1 <= addr1_old;
                end if;
              elsif (error1) then
                setOut2toX <= FALSE;
                active_addr1 <= err_addr1;
                buff1 <= (others => 'X');
                for j in intBus1'range loop
                  intBus1(j) <= 'X' after cebLastFall1 + tpd_CEB1_O1(j)(tr10) - NOW;
                end loop;
              else
                setOut2toX <= FALSE;  
                active_addr1 <= addr1_old;
                buff1 <= in1_old; 
                for j in intBus1'range loop
                  intBus1(j) <= in1_old(j) after cebLastFall1 + tpd_CEB1_O1(j)(tr10) - NOW;
                end loop;       
                if (verbose /= 0 and verbose /= 2 and debug = 2) then
           
                  Info("Setting memory cell:",addr1_old,in1_old,InstancePath,NOW);
                end if;
              end if;
            end if;
          end if;
        end if;  
      end process read_write_cycle1;

      read_write_cycle2 : process(CEB2State,CEB1State,setOut2toX,WEB2State,CSB2State,address2,IN2State
                      )
        variable cebLastRise2   : time := 0 ns;
        variable cebLastFall2   : time := 0 ns;
        variable xData : X01_vector(0 to numOut-1) := (others => 'X');
        variable cebLastFall1 : time := 0 ns;
        variable err_addr2      : integer := -1;
        variable error2        : boolean := false;
        variable out2_to_x    : boolean := false;
        variable ADDR_viol2    : boolean := false;
        variable BA_viol2    : boolean := false;
        variable WENB_viol2    : boolean := false;
        variable CSB_viol2    : boolean := false;
        variable WEB_viol2    : boolean := false;
        variable IN_viol2    : boolean := false;
        variable PULSE_viol2  : boolean := false;
        variable CLOCK_viol2  : boolean := false;
        variable read2      : boolean := false;
        variable write2      : boolean := false;
        variable addr2_old      : integer := -1;
        variable banksel2_old  : X01 := 'X';
        variable csb2_old    : X01 := 'X';
        variable web2_old    : X01 := 'X';
        variable in2_old      : X01_vector((numOut-1) downto 0) := (others => 'X');
      begin

    -----------------------------------
    -- Checks in respect to clock edges
    -----------------------------------
      if(CEB1State'event and CEB1State = '0') then
        cebLastFall1 := NOW;
      end if;
      if(setOut2toX'event) then
        if(setOut2toX) then
          for j in intBus2'range loop
            intBus2(j) <= 'X' after cebLastFall2 + tpd_CEB2_O2(j)(tr10) - NOW;
          end loop;
        end if;
      elsif(CEB2State'event or WEB2State'event or CSB2State'event or address2'event or IN2State'event
                      ) then
        if (CEB2State'last_event = 0 ns) and (NOW > cebLastFall2) then

      ----------------------------------------------------------------
      -- Checks at inactive edge of clock (also events from or to 'X')
      ----------------------------------------------------------------

          if (CEB2State'last_value = '0' and (CEB2State = '1' or CEB2State = 'X'))
              or (CEB2State'last_value = 'X' and CEB2State = '1') then
            if (verbose /= 0) then

          -- AC violation tests

              cebLastRise2 := NOW;
              if (cebLastRise2 - cebLastFall2 < tpw_CEB2_posedge) then
            -- tCLA (minimum clock low time)
                Warn("CEB2 low phase too short during cycle.",InstancePath,NOW,verbose);
                active_addr2 <= -1;
                buff2 <= (others => 'X');
                for j in intBus2'range loop
                  intBus2(j) <= 'X' after cebLastFall2 + tpd_CEB2_O2(j)(tr10) - NOW;
                end loop;
              elsif (CEB2State = 'X') then
                Warn("CEB2 event from 0 to X.",InstancePath,NOW,verbose);
              elsif (CEB2State'last_value = 'X') then
                Warn("CEB2 event from X to 1.",InstancePath,NOW,verbose);
              end if;
            end if;
          end if;

      --------------------------------------------------------------
      -- Checks at active edge of clock (also events from or to 'X')
      --------------------------------------------------------------

          if ((CEB2State'last_value = '1' and (CEB2State = 'X' or CEB2State = '0'))
              or (CEB2State'last_value = 'X' and CEB2State = '0')) then
            if (verbose /= 0) then
              error2     := false;
              out2_to_x    := false;
              ADDR_viol2   := false;
              BA_viol2   := false;
              WENB_viol2   := false;
              CSB_viol2   := false;
              WEB_viol2   := false;
              IN_viol2   := false;
              CLOCK_viol2  := false;
              PULSE_viol2   := false;
              addr2_old   := address2;
              banksel2_old := bankIsSelected2;
              csb2_old   := CSB2State;
              web2_old   := WEB2State;
              in2_old     := IN2State;

          -- X-handling

              if (web2_old = 'X') then
                Warn("WEB2 unknown at active clock edge.",InstancePath,NOW,verbose);
                WEB_viol2 := true;
              end if;
              if (csb2_old = 'X') then
                Warn("CSB2 unknown at active clock edge.",InstancePath,NOW,verbose);
                CSB_viol2 := true;
              end if;
              if (banksel2_old = 'X') then
                Warn("BA2 unknown at active clock edge.",InstancePath,NOW,verbose);
                BA_viol2 := true;
              end if;
              if (addr2_old = -1) then
                Warn("Address2 unknown at active clock edge.",InstancePath,NOW,verbose);
                ADDR_viol2 := true;
              end if;


          -- AC violation tests

              if (A2State'last_event < max2(tsetup_A2_CEB2_negedge_negedge(0), tsetup_A2_CEB2_posedge_negedge(0))) then
                Warn("Address2 set up time not met.",InstancePath,NOW,verbose);
                ADDR_viol2 := true;
              end if;

              if(CSB2State = '0') then
                if (CSB2State'last_event < tsetup_CSB2_CEB2_negedge_negedge) then
                  Warn("CSB2 setup time not met.",InstancePath,NOW,verbose);
                  CSB_viol2 := true;
                end if;
              else
                if (CSB2State'last_event < tsetup_CSB2_CEB2_posedge_negedge) then
                  Warn("CSB2 setup time not met.",InstancePath,NOW,verbose);
                  CSB_viol2 := true;
                end if;
              end if;
              if(WEB2State = '0') then
                if (WEB2State'last_event < tsetup_WEB2_CEB2_negedge_negedge) then
                  Warn("WEB2 setup time not met.",InstancePath,NOW,verbose);
                  WEB_viol2 := true;
                end if;
              else
                if (WEB2State'last_event < tsetup_WEB2_CEB2_posedge_negedge) then
                  Warn("WEB2 setup time not met.",InstancePath,NOW,verbose);
                  WEB_viol2 := true;
                end if;
              end if;

              if (IN2State'last_event < max2(tsetup_I2_CEB2_negedge_negedge(0), tsetup_I2_CEB2_posedge_negedge(0))) then
                Warn("Data in setup time during write cycle not met.",InstancePath,NOW,verbose);
                IN_viol2 := true;
              end if;

              if (NOW - cebLastFall2 < tperiod_CEB2) then
                Warn("CEB2 period too short.",InstancePath,NOW,verbose);
                CLOCK_viol2 := true;
              end if;
              cebLastFall2 := NOW;
              if (CEB2State = 'X') then
                Warn("CEB2 event from 1 to X.",InstancePath,NOW,verbose);
                CLOCK_viol2 := true;
              end if;
              if (CEB2State'last_value = 'X') then
                Warn("CEB2 event from X to 0.",InstancePath,NOW,verbose);
                CLOCK_viol2 := true;
              end if;
    
              if (cebLastFall2 - cebLastRise2 < tpw_CEB2_negedge) then
            -- tCLP violation
                Warn("CEB2 high phase too short.",InstancePath,NOW,verbose);
                PULSE_viol2 := true;
                active_addr2 <= -1;
                buff2 <= (others => 'X');
                for j in intBus2'range loop
                  intBus2(j) <= 'X' after tpd_CEB2_O2(j)(tr10);
                end loop;
              end if;
            else cebLastFall2 := NOW;
            end if;
          end if;
        end if;
          
    ---------------------------------
    -- Checks after active clock edge
    ---------------------------------
        if ((CEB2State = '0') and not(PULSE_viol2)) then
    
          if (verbose /= 0) then
            if ((WEB2State'last_event = 0 ns) and (NOW > cebLastFall2) and 
                ((WEB2State = '1' and (NOW - cebLastFall2 < thold_WEB2_CEB2_posedge_negedge)) or 
                (WEB2State = '0' and (NOW - cebLastFall2 < thold_WEB2_CEB2_negedge_negedge)))) then
              Warn("WEB2 hold time not met.",InstancePath,NOW,verbose);
              WEB_viol2 := true;
            end if;
            if ((A2State'last_event = 0 ns) and  (NOW > cebLastFall2)) then
              for j in  A2State'range loop
                if ((A2State(j) = '1' and (NOW - cebLastFall2 < thold_A2_CEB2_posedge_negedge(j))) or 
                    (A2State(j) = '0' and (NOW - cebLastFall2 < thold_A2_CEB2_negedge_negedge(j)))) then
                  Warn("Address2 hold time not met.",InstancePath,NOW,verbose);
                  ADDR_viol2 := true;
                end if;
              end loop;
            end if;
    
            if(CSB2State = '0') then
              if (CSB2State'last_event = 0 ns) and (NOW > cebLastFall2) and 
                 (NOW - cebLastFall2 < thold_CSB2_CEB2_negedge_negedge) then
                Warn("CSB2 hold time not met.",InstancePath,NOW,verbose);
                CSB_viol2 := true;
              end if;
            else
              if (CSB2State'last_event = 0 ns) and (NOW > cebLastFall2) and 
                 (NOW - cebLastFall2 < thold_CSB2_CEB2_posedge_negedge) then
                Warn("CSB2 hold time not met.",InstancePath,NOW,verbose);
                CSB_viol2 := true;
              end if;
            end if;
    
            if (IN2State'last_event = 0 ns) and (NOW > cebLastFall2) and 
               (NOW - cebLastFall2 < max2(thold_I2_CEB2_negedge_negedge(0), thold_I2_CEB2_posedge_negedge(0))) then
              Warn("Data in hold time during write cycle not met.",InstancePath,NOW,verbose);
              IN_viol2 := true;
            end if;
          end if;

  -----------------              
  -- Make decision
  -----------------
    
          read2  := false;
          write2 := false;
    
          if (CSB_viol2 or (csb2_old /= '1')) and (BA_viol2 or (banksel2_old /= '0')) then
            if (WEB_viol2 and (web2_old /= '1')) or (CEB2State'event and (web2_old /= '1')) then write2 := true;
            elsif (WEB_viol2 and (web2_old /= '0')) or (CEB2State'event and (web2_old /= '0')) then read2 := true;
            end if;
          end if;
    
          if ADDR_viol2 then
            error2 := true;
            err_addr2 := -1;
          elsif (addr2_old = -2) then
            Warn("Address2 is out of range at active clock edge.",InstancePath,NOW,verbose);
            error2 := true;
            err_addr2 := -2;
          else err_addr2 := addr2_old;
          end if;
    
          if WEB_viol2 then
            out2_to_x := true;
            error2 := true;
          elsif CSB_viol2 then
            error2 := true;
          elsif BA_viol2 then
            error2 := true;
          elsif CLOCK_viol2 then
            if (web2_old = '0') then out2_to_x := true;  end if;
            error2 := true;
          elsif (web2_old = '0') then
            if IN_viol2 then
             out2_to_x := true;
             error2 := true;

            end if;
          end if;

        -- Reading memory location (modifying internal output latch)

          if read2 then
            if(NOW - cebLastFall1 < trecovery_CEB1_CEB2_negedge_negedge and en_write1read2 = '1') then
              Warn("Read/write operations for the same address are too close.",InstancePath,NOW,verbose);
              for j in intBus2'range loop
                intBus2(j) <= 'X' after cebLastFall2 + tpd_CEB2_O2(j)(tr10) - NOW;
              end loop;
            elsif error2 then
              if (verbose /= 0 and verbose /= 1) then
                for j in intBus2'range loop
                  intBus2(j) <= 'X' after cebLastFall2 + tpd_CEB2_O2(j)(tr10) - NOW;
                end loop;
                if ((debug = 1 or debug = 2) and verbose /= 0 and verbose /= 1 and verbose /= 2) then
                  Warn("  ==> Setting internal output2 latch unknown.",InstancePath,NOW);
                end if;
              end if;
            else
              active_addr2 <= addr2_old;
              for j in intBus2'range loop
                if (cebLastFall2 + tpd_CEB2_O2(j)(tr01) > NOW) then
                 intBus2(j) <= transport '1' after cebLastFall2 + tpd_CEB2_O2(j)(tr01) - NOW;
                else 
                 intBus2(j) <= transport '1' after 0 ns;
                end if;
                intBus2(j) <= transport memory(addr2_old)(j) after cebLastFall2 + tpd_CEB2_O2(j)(tr10) - NOW;
              end loop;
              if (verbose /= 0 and verbose /= 2 and debug = 2) then
                Info("Setting internal output2 latch: ",memory(addr2_old),InstancePath,NOW);
              end if;
            end if;
          end if;
        
        -- Writing memory location

          if write2 then
            if(NOW - cebLastFall1 < trecovery_CEB1_CEB2_negedge_negedge and (en_read1write2 = '1' or en_write1write2 = '1')) then
              if(en_read1write2 = '1') then
                Warn("Read/write operations for the same address are too close.",InstancePath,NOW,verbose);
                setOut1toX <= TRUE;
              elsif(en_write1write2 = '1') then
                Warn("Simulteneuos write to the same address.",InstancePath,NOW,verbose);
                buff2 <= (others => 'X');
                for j in intBus2'range loop
                  intBus2(j) <= 'X' after cebLastFall2 + tpd_CEB2_O2(j)(tr10) - NOW;
                end loop;
                active_addr2 <= addr2_old;
                setOut1toX <= FALSE;
              end if;
            elsif (error2) then
              active_addr2 <= err_addr2;
              setOut1toX <= FALSE;
              buff2 <= (others => 'X');
              for j in intBus2'range loop
                intBus2(j) <= 'X' after cebLastFall2 + tpd_CEB2_O2(j)(tr10) - NOW;
              end loop;
            else
              setOut1toX <= FALSE;  
              active_addr2 <= addr2_old;
              buff2 <= in2_old;
              for j in intBus2'range loop
                intBus2(j) <= in2_old(j) after cebLastFall2 + tpd_CEB2_O2(j)(tr10) - NOW;
              end loop;
              if (verbose /= 0 and verbose /= 2 and debug = 2) then
           
                Info("Setting memory cell:",addr2_old,in2_old,InstancePath,NOW);
              end if;
            end if;
          end if;
        end if;
      end if;
    end process read_write_cycle2;

  memory_update : process(buff1'transaction, buff2'transaction)
  begin
    if (buff1'last_active = 0 ns) then 
      if (X_judge(buff1) = -1) then
        if (active_addr1 = -1) then memory <= (others => (others => 'X'));
        elsif (active_addr1 /= -2) then memory(active_addr1) <= (others => 'X');
        end if;
      
      elsif ((active_addr1 = active_addr2) or (active_addr2 = -1)) 
             and (buff2'last_active = 0 ns) then
        memory(active_addr1) <= (others => 'X');
      else memory(active_addr1) <= buff1;
      end if;
    end if;
  
    if (buff2'last_active = 0 ns) then
      if (X_judge(buff2) = -1) then
        if (active_addr2 = -1) then memory <= (others => (others => 'X'));
        elsif (active_addr2 /= -2) then memory(active_addr2) <= (others => 'X');
        end if;
      elsif ((active_addr2 = active_addr1) or (active_addr1 = -1)) 
             and (buff1'last_active = 0 ns) then
        memory(active_addr2) <= (others => 'X');
      else memory(active_addr2) <= buff2;
      end if;
    end if;
  end process memory_update; 
  
  output_data1 : process(intBus1'transaction, enable1)
    variable data : X01_vector((numOut-1) downto 0) := (others => 'X');

  begin  
    if (intBus1'last_active = 0 ns) then
      data := intBus1;
    end if;
  
    for j in intBus1'range loop
      if (enable1(j) = '1') then O1(j) <= data(j);
      elsif (enable1(j) = '0') then O1(j) <= 'Z';
      else O1(j) <='X';
      end if;
    end loop;
  end process output_data1;
  
  output_data2 : process(intBus2'transaction, enable2)
    variable data : X01_vector((numOut-1) downto 0) := (others => 'X');

  begin  
    if (intBus2'last_active = 0 ns) then
      data := intBus2;
    end if;
  
    for j in intBus2'range loop
      if (enable2(j) = '1') then O2(j) <= data(j);
      elsif (enable2(j) = '0') then O2(j) <= 'Z';
      else O2(j) <='X';
      end if;
    end loop;
  end process output_data2;

END dpram4096x36_behave;

CONFIGURATION dpram4096x36_con of dpram4096x36 is
  for dpram4096x36_behave
  end for;
END dpram4096x36_con;

