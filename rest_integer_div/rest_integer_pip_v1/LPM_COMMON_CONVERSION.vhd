---START_PACKAGE_HEADER-----------------------------------------------------
--
-- Package Name    :  LPM_COMMON_CONVERSION
--
-- Description     :  Common conversion functions
--
---END_PACKAGE_HEADER--------------------------------------------------------

-- BEGINING OF PACKAGE
Library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;

-- PACKAGE DECLARATION
package LPM_COMMON_CONVERSION is
-- FUNCTION DECLARATION
    function STR_TO_INT (str : string) return integer;
    function INT_TO_STR (value : in integer) return string;
    function HEX_STR_TO_INT (str : in string) return integer;
    procedure SHRINK_LINE (str_line : inout line; pos : in integer);
end LPM_COMMON_CONVERSION;

package body LPM_COMMON_CONVERSION is
function STR_TO_INT ( str : string ) return integer is
variable len : integer := str'length;
variable ivalue : integer := 0;
variable digit : integer := 0;
begin
    for i in 1 to len loop
        case str(i) is
            when '0' =>
                digit := 0;
            when '1' =>
                digit := 1;
            when '2' =>
                digit := 2;
            when '3' =>
                digit := 3;
            when '4' =>
                digit := 4;
            when '5' =>
                digit := 5;
            when '6' =>
                digit := 6;
            when '7' =>
                digit := 7;
            when '8' =>
                digit := 8;
            when '9' =>
                digit := 9;
            when others =>
                ASSERT FALSE
                REPORT "Illegal Character "&  str(i) & "in string parameter! "
                SEVERITY ERROR;
        end case;
        ivalue := ivalue * 10 + digit;
    end loop;
    return ivalue;
end STR_TO_INT;

-- This function converts an integer to a string
function INT_TO_STR (value : in integer) return string is
variable ivalue : integer := 0;
variable index  : integer := 0;
variable digit : integer := 0;
variable line_no: string(8 downto 1) := "        ";  
begin
    ivalue := value;
    index := 1;
    
    while (ivalue > 0) loop
        digit := ivalue MOD 10;
        ivalue := ivalue/10;
        case digit is
            when 0 => line_no(index) := '0';
            when 1 => line_no(index) := '1';
            when 2 => line_no(index) := '2';
            when 3 => line_no(index) := '3';
            when 4 => line_no(index) := '4';
            when 5 => line_no(index) := '5';
            when 6 => line_no(index) := '6';
            when 7 => line_no(index) := '7';
            when 8 => line_no(index) := '8';
            when 9 => line_no(index) := '9';
            when others =>
                ASSERT FALSE
                REPORT "Illegal number!"
                SEVERITY ERROR;
        end case;
        index := index + 1;
    end loop;
    
    return line_no;
end INT_TO_STR;

-- This function converts a hexadecimal number to an integer
function HEX_STR_TO_INT (str : in string) return integer is
variable len : integer := str'length;
variable ivalue : integer := 0;
variable digit : integer := 0;
begin
    for i in len downto 1 loop
        case str(i) is
            when '0' => digit := 0;
            when '1' => digit := 1;
            when '2' => digit := 2;
            when '3' => digit := 3;
            when '4' => digit := 4;
            when '5' => digit := 5;
            when '6' => digit := 6;
            when '7' => digit := 7;
            when '8' => digit := 8;
            when '9' => digit := 9;
            when 'A' => digit := 10;
            when 'a' => digit := 10;
            when 'B' => digit := 11;
            when 'b' => digit := 11;
            when 'C' => digit := 12;
            when 'c' => digit := 12;
            when 'D' => digit := 13;
            when 'd' => digit := 13;
            when 'E' => digit := 14;
            when 'e' => digit := 14;
            when 'F' => digit := 15;
            when 'f' => digit := 15;
            when others =>
                ASSERT FALSE
                REPORT "Illegal character "&  str(i) & "in Intel Hex File! "
                SEVERITY ERROR;
        end case;
        ivalue := ivalue * 16 + digit;
    end loop;
    return ivalue;
end HEX_STR_TO_INT;

-- This procedure "cuts" the str_line into desired length
procedure SHRINK_LINE (str_line : inout line; pos : in integer) is
subtype nstring is string(1 to pos);
variable str : nstring;
begin
    if (pos >= 1) then
        read(str_line, str);
    end if;
end;
end LPM_COMMON_CONVERSION;
-- END OF PACKAGE 

---START_PACKAGE_HEADER-----------------------------------------------------
--
-- Package Name    :  LPM_HINT_EVALUATION
--
-- Description     :  Common function to grep the value of altera specific parameters
--                    within the lpm_hint parameter.
--
---END_PACKAGE_HEADER--------------------------------------------------------

-- BEGINING OF PACKAGE
--Library ieee;
--use ieee.std_logic_1164.all;
--
---- PACKAGE DECLARATION
--package LPM_HINT_EVALUATION is
---- FUNCTION DECLARATION
--    function get_parameter_value( constant  given_string : string;
--                                            compare_param_name : string) return string;
--end LPM_HINT_EVALUATION;
--
--package body LPM_HINT_EVALUATION is
--
---- This function will search through the string (given string) to look for a match for the
---- a given parameter(compare_param_name). It will return the value for the given parameter.
--function get_parameter_value( constant  given_string : string; 
--                                        compare_param_name : string) return string is
--    variable param_name_left_index   : integer := given_string'length;
--    variable param_name_right_index  : integer := given_string'length;
--    variable param_value_left_index  : integer := given_string'length;
--    variable param_value_right_index : integer := given_string'length;
--    variable set_right_index         : boolean := true;
--    variable extract_param_value     : boolean := true; 
--    variable extract_param_name      : boolean := false;  
--    variable param_found             : boolean := false;
--    
--begin
--
--    -- checking every character of the given_string from right to left.
--    for i in given_string'length downto 1 loop
--        if (given_string(i) /= ' ') then
--            if (given_string(i) = '=') then
--                extract_param_value := false;
--                extract_param_name  := true;
--                set_right_index := true;
--            elsif (given_string(i) = ',') then
--                extract_param_value := true;
--                extract_param_name  := false;
--                set_right_index := true;
--                
--                if (compare_param_name = given_string(param_name_left_index to param_name_right_index)) then
--                        param_found := true;  -- the compare_param_name have been found in the given_string
--                        exit;
--                end if;            
--            else            
--                if (extract_param_value = true) then                
--                    if (set_right_index = true) then                    
--                        param_value_right_index := i;
--                        set_right_index := false;    
--                    end if;
--                    param_value_left_index := i;
--                elsif (extract_param_name = true) then                
--                    if (set_right_index = true) then                    
--                        param_name_right_index := i;
--                        set_right_index := false;    
--                    end if;
--                    param_name_left_index := i;    
--                end if;
--            end if;
--        end if;
--    end loop;
--
--    -- for the case whether parameter's name is the left most part of the given_string
--    if (extract_param_name = true) then
--        if(compare_param_name = given_string(param_name_left_index to param_name_right_index)) then        
--            param_found := true;                
--        end if;
--    end if;
--
--    if(param_found = true) then             
--        return given_string(param_value_left_index to param_value_right_index);    
--    else    
--        return "";   -- return empty string if parameter not found
--    end if;
--    
--end get_parameter_value;
--end LPM_HINT_EVALUATION;
---- END OF PACKAGE 
--
---- BEGINING OF PACKAGES
--Library ieee;
--use ieee.std_logic_1164.all;
--
---- PACKAGE DECLARATION
--package LPM_DEVICE_FAMILIES is
---- FUNCTION DECLARATION
--    function IS_FAMILY_APEX20K (device : in string) return boolean;
--    function IS_FAMILY_MAX7000B (device : in string) return boolean;
--    function IS_FAMILY_MAX7000AE (device : in string) return boolean;
--    function IS_FAMILY_MAX3000A (device : in string) return boolean;
--    function IS_FAMILY_MAX7000S (device : in string) return boolean;
--    function IS_FAMILY_MAX7000A (device : in string) return boolean;
--    function IS_FAMILY_STRATIX (device : in string) return boolean;
--    function IS_FAMILY_STRATIXGX (device : in string) return boolean;
--    function IS_FAMILY_CYCLONE (device : in string) return boolean;
--    function IS_VALID_FAMILY (device: in string) return boolean;
--end LPM_DEVICE_FAMILIES;
--
--package body LPM_DEVICE_FAMILIES is
--
--
--function IS_FAMILY_APEX20K (device : in string) return boolean is
--variable is_apex20k : boolean := false;
--begin
--    if ((device = "APEX20K") or (device = "apex20k") or (device = "APEX 20K") or (device = "apex 20k") or (device = "RAPHAEL") or (device = "raphael"))
--    then
--        is_apex20k := true;
--    end if;
--    return is_apex20k;
--end IS_FAMILY_APEX20K;
--
--function IS_FAMILY_MAX7000B (device : in string) return boolean is
--variable is_max7000b : boolean := false;
--begin
--    if ((device = "MAX7000B") or (device = "max7000b") or (device = "MAX 7000B") or (device = "max 7000b"))
--    then
--        is_max7000b := true;
--    end if;
--    return is_max7000b;
--end IS_FAMILY_MAX7000B;
--
--function IS_FAMILY_MAX7000AE (device : in string) return boolean is
--variable is_max7000ae : boolean := false;
--begin
--    if ((device = "MAX7000AE") or (device = "max7000ae") or (device = "MAX 7000AE") or (device = "max 7000ae"))
--    then
--        is_max7000ae := true;
--    end if;
--    return is_max7000ae;
--end IS_FAMILY_MAX7000AE;
--
--function IS_FAMILY_MAX3000A (device : in string) return boolean is
--variable is_max3000a : boolean := false;
--begin
--    if ((device = "MAX3000A") or (device = "max3000a") or (device = "MAX 3000A") or (device = "max 3000a"))
--    then
--        is_max3000a := true;
--    end if;
--    return is_max3000a;
--end IS_FAMILY_MAX3000A;
--
--function IS_FAMILY_MAX7000S (device : in string) return boolean is
--variable is_max7000s : boolean := false;
--begin
--    if ((device = "MAX7000S") or (device = "max7000s") or (device = "MAX 7000S") or (device = "max 7000s"))
--    then
--        is_max7000s := true;
--    end if;
--    return is_max7000s;
--end IS_FAMILY_MAX7000S;
--
--function IS_FAMILY_MAX7000A (device : in string) return boolean is
--variable is_max7000a : boolean := false;
--begin
--    if ((device = "MAX7000A") or (device = "max7000a") or (device = "MAX 7000A") or (device = "max 7000a"))
--    then
--        is_max7000a := true;
--    end if;
--    return is_max7000a;
--end IS_FAMILY_MAX7000A;
--
--function IS_FAMILY_STRATIX (device : in string) return boolean is
--variable is_stratix : boolean := false;
--begin
--    if ((device = "Stratix") or (device = "STRATIX") or (device = "stratix") or (device = "Yeager") or (device = "YEAGER") or (device = "yeager"))
--    then
--        is_stratix := true;
--    end if;
--    return is_stratix;
--end IS_FAMILY_STRATIX;
--
--function IS_FAMILY_STRATIXGX (device : in string) return boolean is
--variable is_stratixgx : boolean := false;
--begin
--    if ((device = "Stratix GX") or (device = "STRATIX GX") or (device = "stratix gx") or (device = "Stratix-GX") or (device = "STRATIX-GX") or (device = "stratix-gx") or (device = "StratixGX") or (device = "STRATIXGX") or (device = "stratixgx") or (device = "Aurora") or (device = "AURORA") or (device = "aurora"))
--    then
--        is_stratixgx := true;
--    end if;
--    return is_stratixgx;
--end IS_FAMILY_STRATIXGX;
--
--function IS_FAMILY_CYCLONE (device : in string) return boolean is
--variable is_cyclone : boolean := false;
--begin
--    if ((device = "Cyclone") or (device = "CYCLONE") or (device = "cyclone") or (device = "ACEX2K") or (device = "acex2k") or (device = "ACEX 2K") or (device = "acex 2k") or (device = "Tornado") or (device = "TORNADO") or (device = "tornado"))
--    then
--        is_cyclone := true;
--    end if;
--    return is_cyclone;
--end IS_FAMILY_CYCLONE;
--
--function IS_VALID_FAMILY (device : in string) return boolean is
--variable is_valid : boolean := false;
--begin
--    if (((device = "ACEX1K") or (device = "acex1k") or (device = "ACEX 1K") or (device = "acex 1k"))
--    or ((device = "APEX20K") or (device = "apex20k") or (device = "APEX 20K") or (device = "apex 20k") or (device = "RAPHAEL") or (device = "raphael"))
--    or ((device = "APEX20KC") or (device = "apex20kc") or (device = "APEX 20KC") or (device = "apex 20kc"))
--    or ((device = "APEX20KE") or (device = "apex20ke") or (device = "APEX 20KE") or (device = "apex 20ke"))
--    or ((device = "APEX II") or (device = "apex ii") or (device = "APEXII") or (device = "apexii") or (device = "APEX 20KF") or (device = "apex 20kf") or (device = "APEX20KF") or (device = "apex20kf"))
--    or ((device = "EXCALIBUR_ARM") or (device = "excalibur_arm") or (device = "Excalibur ARM") or (device = "EXCALIBUR ARM") or (device = "excalibur arm") or (device = "ARM-BASED EXCALIBUR") or (device = "arm-based excalibur") or (device = "ARM_BASED_EXCALIBUR") or (device = "arm_based_excalibur"))
--    or ((device = "FLEX10KE") or (device = "flex10ke") or (device = "FLEX 10KE") or (device = "flex 10ke"))
--    or ((device = "FLEX10K") or (device = "flex10k") or (device = "FLEX 10K") or (device = "flex 10k"))
--    or ((device = "FLEX10KA") or (device = "flex10ka") or (device = "FLEX 10KA") or (device = "flex 10ka"))
--    or ((device = "FLEX6000") or (device = "flex6000") or (device = "FLEX 6000") or (device = "flex 6000") or (device = "FLEX6K") or (device = "flex6k"))
--    or ((device = "MAX7000B") or (device = "max7000b") or (device = "MAX 7000B") or (device = "max 7000b"))
--    or ((device = "MAX7000AE") or (device = "max7000ae") or (device = "MAX 7000AE") or (device = "max 7000ae"))
--    or ((device = "MAX3000A") or (device = "max3000a") or (device = "MAX 3000A") or (device = "max 3000a"))
--    or ((device = "MAX7000S") or (device = "max7000s") or (device = "MAX 7000S") or (device = "max 7000s"))
--    or ((device = "MAX7000A") or (device = "max7000a") or (device = "MAX 7000A") or (device = "max 7000a"))
--    or ((device = "Mercury") or (device = "MERCURY") or (device = "mercury") or (device = "DALI") or (device = "dali"))
--    or ((device = "Stratix") or (device = "STRATIX") or (device = "stratix") or (device = "Yeager") or (device = "YEAGER") or (device = "yeager"))
--    or ((device = "Stratix GX") or (device = "STRATIX GX") or (device = "stratix gx") or (device = "Stratix-GX") or (device = "STRATIX-GX") or (device = "stratix-gx") or (device = "StratixGX") or (device = "STRATIXGX") or (device = "stratixgx") or (device = "Aurora") or (device = "AURORA") or (device = "aurora"))
--    or ((device = "Cyclone") or (device = "CYCLONE") or (device = "cyclone") or (device = "ACEX2K") or (device = "acex2k") or (device = "ACEX 2K") or (device = "acex 2k") or (device = "Tornado") or (device = "TORNADO") or (device = "tornado"))
--    or ((device = "MAX II") or (device = "max ii") or (device = "MAXII") or (device = "maxii") or (device = "Tsunami") or (device = "TSUNAMI") or (device = "tsunami"))
--    or ((device = "HardCopy Stratix") or (device = "HARDCOPY STRATIX") or (device = "hardcopy stratix") or (device = "Stratix HC") or (device = "STRATIX HC") or (device = "stratix hc") or (device = "StratixHC") or (device = "STRATIXHC") or (device = "stratixhc") or (device = "HardcopyStratix") or (device = "HARDCOPYSTRATIX") or (device = "hardcopystratix"))
--    or ((device = "Stratix II") or (device = "STRATIX II") or (device = "stratix ii") or (device = "StratixII") or (device = "STRATIXII") or (device = "stratixii") or (device = "Armstrong") or (device = "ARMSTRONG") or (device = "armstrong"))
--    or ((device = "Stratix II GX") or (device = "STRATIX II GX") or (device = "stratix ii gx") or (device = "StratixIIGX") or (device = "STRATIXIIGX") or (device = "stratixiigx"))
--    or ((device = "Cyclone II") or (device = "CYCLONE II") or (device = "cyclone ii") or (device = "Cycloneii") or (device = "CYCLONEII") or (device = "cycloneii") or (device = "Magellan") or (device = "MAGELLAN") or (device = "magellan"))
--    or ((device = "HardCopy II") or (device = "HARDCOPY II") or (device = "hardcopy ii") or (device = "HardCopyII") or (device = "HARDCOPYII") or (device = "hardcopyii") or (device = "Fusion") or (device = "FUSION") or (device = "fusion"))
--    or ((device = "Titan") or (device = "TITAN") or (device = "titan"))
--    or ((device = "Barracuda") or (device = "BARRACUDA") or (device = "barracuda") or (device = "Cuda") or (device = "CUDA") or (device = "cuda")))
--    then
--        is_valid := true;
--    end if;
--    return is_valid;
--end IS_VALID_FAMILY;
--
--
--end LPM_DEVICE_FAMILIES;
---- END OF PACKAGE