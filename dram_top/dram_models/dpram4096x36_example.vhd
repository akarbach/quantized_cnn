-------------------------------------------------------------------
--                                                               --
-- Copyright (c) 2003 Synopsys, Inc.  All Rights Reserved        --
-- This information is provided pursuant to a license agreement  --
-- that grants limited rights of access/use and requires that    --
-- the information be treated as confidential.                   --
--                                                               --
-------------------------------------------------------------------

 LIBRARY IEEE;
    USE IEEE.std_logic_1164.all;

  LIBRARY WORK;
    USE WORK.all;

  ENTITY dpram4096x36_example IS
    GENERIC (display_header : boolean := TRUE;
             verbose        : integer := 2 );
    PORT (EXP_A1   : IN std_logic_vector((12-1) downto 0) := (others => 'X');
          EXP_A2   : IN std_logic_vector((12-1) downto 0) := (others => 'X');   
          EXP_CEB1 : IN std_logic := 'X';
          EXP_CEB2 : IN std_logic := 'X';
          EXP_WEB1 : IN std_logic := 'X';
          EXP_WEB2 : IN std_logic := 'X';
          EXP_OEB1 : IN std_logic := 'X';
          EXP_OEB2 : IN std_logic := 'X';
          EXP_CSB1 : IN std_logic := 'X';
          EXP_CSB2 : IN std_logic := 'X';
          EXP_I1   : IN  std_logic_vector((36-1) downto 0) := (others => 'X');
          EXP_I2   : IN  std_logic_vector((36-1) downto 0) := (others => 'X');
          EXP_O1   : OUT std_logic_vector((36-1) downto 0) := (others => 'X');
          EXP_O2   : OUT std_logic_vector((36-1) downto 0) := (others => 'X'));
  END;


  ARCHITECTURE arch OF dpram4096x36_example IS

    -- Component Declaration

    COMPONENT dpram4096x36
      GENERIC (display_header : boolean;
               verbose        : integer );
      PORT (A1   : IN std_logic_vector((12-1) downto 0) := (others => 'X');
            A2   : IN std_logic_vector((12-1) downto 0) := (others => 'X');
            CEB1 : IN std_logic := 'X';
            CEB2 : IN std_logic := 'X';
            WEB1 : IN std_logic := 'X';
            WEB2 : IN std_logic := 'X';
            OEB1 : IN std_logic := 'X';
            OEB2 : IN std_logic := 'X';
            CSB1 : IN std_logic := 'X';
            CSB2 : IN std_logic := 'X';
            I1   : IN  std_logic_vector((36-1) downto 0) := (others => 'X');
            I2   : IN  std_logic_vector((36-1) downto 0) := (others => 'X');
            O1   : OUT std_logic_vector((36-1) downto 0) := (others => 'X');
            O2   : OUT std_logic_vector((36-1) downto 0) := (others => 'X'));
    END COMPONENT;

    -- Component Configuration

    FOR ALL: dpram4096x36 USE ENTITY WORK.dpram4096x36(dpram4096x36_behave);
    SIGNAL a1   : std_logic_vector((12-1) downto 0) := (others => 'X');
    SIGNAL ceb1 : std_logic := 'X';
    SIGNAL web1 : std_logic := 'X';
    SIGNAL oeb1 : std_logic := 'X';
    SIGNAL csb1 : std_logic := 'X';
    SIGNAL i1   : std_logic_vector((36-1) downto 0) := (others => 'X');
    SIGNAL o1   : std_logic_vector((36-1) downto 0) := (others => 'X');
    SIGNAL a2   : std_logic_vector((12-1) downto 0) := (others => 'X');
    SIGNAL ceb2 : std_logic := 'X';
    SIGNAL web2 : std_logic := 'X';
    SIGNAL oeb2 : std_logic := 'X';
    SIGNAL csb2 : std_logic := 'X';
    SIGNAL i2   : std_logic_vector((36-1) downto 0) := (others => 'X');
    SIGNAL o2   : std_logic_vector((36-1) downto 0) := (others => 'X');
  BEGIN

    -- Component Instantiation

    u1: dpram4096x36
      GENERIC MAP (display_header,verbose)
      PORT MAP    (a1, a2, ceb1, ceb2, web1, web2, oeb1, oeb2, csb1, csb2,
                   i1, i2, o1, o2);
    a1      <= EXP_A1;
    ceb1    <= EXP_CEB1;
    web1    <= EXP_WEB1;
    oeb1    <= EXP_OEB1;
    csb1    <= EXP_CSB1;
    i1      <= EXP_I1;
    EXP_O1  <= o1;
    a2      <= EXP_A2;
    ceb2    <= EXP_CEB2;
    web2    <= EXP_WEB2;
    oeb2    <= EXP_OEB2;
    csb2    <= EXP_CSB2;
    i2      <= EXP_I2;
    EXP_O2  <= o2;
  END arch;

