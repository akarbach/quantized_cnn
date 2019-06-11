library ieee;
use ieee.std_logic_1164.all;

package ConvLayer_types_package is
    constant CL_units   : integer := 2; -- number of CL units
    constant W          : integer := 8; -- data output width
	subtype element is std_logic_vector(W-1 downto 0);
	type vec is array (natural range 0 to CL_units -1) of element;
	type mat is array (natural range <>) of vec;
	--type vec is array (natural range <>) of element;
	--type mat is array (natural range <>) of vec;
end ConvLayer_types_package;