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

  ENTITY dpram4096x36_gen_width_tb IS
    GENERIC (display_header : boolean := TRUE;
             W              : integer := 4   ;     
             verbose        : integer := 2   ) ;
  END;


  ARCHITECTURE arch OF dpram4096x36_gen_width_tb IS

    -- Component Declaration

    COMPONENT dpram4096x36_gen_width
    GENERIC (display_header : boolean := TRUE;
             W              : integer := 4   ;     
             verbose        : integer := 2   ) ;
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
          EXP_I1   : IN  std_logic_vector((W*36-1) downto 0) := (others => 'X');
          EXP_I2   : IN  std_logic_vector((W*36-1) downto 0) := (others => 'X');
          EXP_O1   : OUT std_logic_vector((W*36-1) downto 0) := (others => 'X');
          EXP_O2   : OUT std_logic_vector((W*36-1) downto 0) := (others => 'X'));
    END COMPONENT;

signal  EXP_A1   : std_logic_vector((12-1) downto 0) := (others => 'X');
signal  EXP_A2   : std_logic_vector((12-1) downto 0) := (others => 'X');   
signal  EXP_CEB1 : std_logic := '0';
signal  EXP_CEB2 : std_logic := '0';
signal  EXP_WEB1 : std_logic := '0';
signal  EXP_WEB2 : std_logic := '0';
signal  EXP_OEB1 : std_logic := '0';
signal  EXP_OEB2 : std_logic := '0';
signal  EXP_CSB1 : std_logic := '0';
signal  EXP_CSB2 : std_logic := '0';
signal  EXP_I1   : std_logic_vector((W*36-1) downto 0) := (others => 'X');
signal  EXP_I2   : std_logic_vector((W*36-1) downto 0) := (others => 'X');
signal  EXP_O1   : std_logic_vector((W*36-1) downto 0) := (others => 'X');
signal  EXP_O2   : std_logic_vector((W*36-1) downto 0) := (others => 'X');

  BEGIN

 
dut: dpram4096x36_gen_width 
  generic map(
           display_header  => display_header,
           W               => W             ,     
           verbose         => verbose       
           )
  port map (
           EXP_A1          => EXP_A1   ,
           EXP_A2          => EXP_A2   ,
           EXP_CEB1        => EXP_CEB1 ,
           EXP_CEB2        => EXP_CEB2 ,
           EXP_WEB1        => EXP_WEB1 ,
           EXP_WEB2        => EXP_WEB2 ,
           EXP_OEB1        => EXP_OEB1 ,
           EXP_OEB2        => EXP_OEB2 ,
           EXP_CSB1        => EXP_CSB1 ,
           EXP_CSB2        => EXP_CSB2 ,
           EXP_I1          => EXP_I1   ,
           EXP_I2          => EXP_I2   ,
           EXP_O1          => EXP_O1   ,
           EXP_O2          => EXP_O2   
           ); 

process        
   begin
     EXP_CEB1 <= '0';  
     EXP_CEB2 <= '0';
     wait for 5 ns;
     EXP_CEB1 <= '1';
     EXP_CEB2 <= '1';
     wait for 5 ns;
   end process;

--rst <= '1', '0' after 10 ns;

  END arch;

