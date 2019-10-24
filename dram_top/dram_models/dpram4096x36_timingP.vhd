-------------------------------------------------------------------
--                                                               --
-- Copyright (c) 2003 Synopsys, Inc.  All Rights Reserved        --
-- This information is provided pursuant to a license agreement  --
-- that grants limited rights of access/use and requires that    --
-- the information be treated as confidential.                   --
--                                                               --
-------------------------------------------------------------------

LIBRARY IEEE;
  use IEEE.std_logic_1164.all;


PACKAGE dpram4096x36_timingP IS

  CONSTANT numOut    : INTEGER := 36;
  CONSTANT wordDepth : INTEGER := 4096;
  CONSTANT numAddr   : INTEGER := 12;

  CONSTANT cycle     : TIME := 10 ns;
  CONSTANT tDelta    : TIME := 0.01 ns;

  CONSTANT tOUTU     : TIME := 1.023 ns;
  CONSTANT tACC0     : TIME := 2.29 ns;
  CONSTANT tOE       : TIME := 0.744 ns;
  CONSTANT tOEZ0     : TIME := 0.784 ns;
  CONSTANT tCYC      : TIME := 2.809 ns;
  CONSTANT tCLA     : TIME := 0.198 ns;
  CONSTANT tCLP     : TIME := 0.363 ns;
  CONSTANT tWS       : TIME := 0 ns;
  CONSTANT tWH       : TIME := 0.329 ns;
  CONSTANT tAS       : TIME := 0 ns;
  CONSTANT tAH       : TIME := 0.403 ns;
  CONSTANT tIS       : TIME := 0.053 ns;
  CONSTANT tIH       : TIME := 0.408 ns;
  CONSTANT tCSS       : TIME := 0.294 ns;
  CONSTANT tCH       : TIME := 0.053 ns;

END dpram4096x36_timingP;
