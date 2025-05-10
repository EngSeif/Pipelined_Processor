LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY Latch_Unit IS
    PORT (
        enable      : IN STD_LOGIC;
        reset       : IN STD_LOGIC;
        input_latch : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        output_port : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END ENTITY Latch_Unit;

ARCHITECTURE behavior OF Latch_Unit IS
BEGIN
    PROCESS (enable, reset)
    BEGIN
        IF reset = '1' THEN
            output_port <= (OTHERS => '0');
        ELSIF enable = '1' THEN
            output_port <= input_latch;
        END IF;
    END PROCESS;
END ARCHITECTURE behavior;