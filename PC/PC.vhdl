LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.math_real.ALL;
ENTITY PC IS
    GENERIC (
        Address_Bits : INTEGER := 32
    );
    PORT (
        clk        : IN STD_LOGIC;
        reset      : IN STD_LOGIC;
        enable     : IN STD_LOGIC;
        writeEn    : IN STD_LOGIC;
        inAddresss : IN STD_LOGIC_VECTOR(Address_Bits - 1 DOWNTO 0);
        outAddress : OUT STD_LOGIC_VECTOR(Address_Bits - 1 DOWNTO 0)
    );
END ENTITY PC;

ARCHITECTURE rtl OF PC IS

BEGIN
    PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF reset = '1' THEN
                outAddress <= (OTHERS => '0'); -- Reset to address 0 (M[0] to be fetched externally)

            ELSIF writeEn = '1' THEN
                outAddress <= STD_LOGIC_VECTOR(unsigned(inAddresss));

            ELSIF enable = '1' THEN
                outAddress <= STD_LOGIC_VECTOR(unsigned(inAddresss) + 1);
                -- to stall just make enable to 0
                -- need to see how to handle incoming pc from stack for example  
            END IF;
        END IF;
    END PROCESS;
END ARCHITECTURE;