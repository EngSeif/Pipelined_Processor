LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY Fetch_Decode IS
    PORT (
        clk                 : IN STD_LOGIC;
        reset               : IN STD_LOGIC;
        fetched_instruction : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        PC                  : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
        IF_ID_Write         : IN STD_LOGIC;
        MemDest             : IN STD_LOGIC;
        -- Outputs to Decode stage
        IF_ID_Instruction : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        IF_ID_PC          : OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
    );
END Fetch_Decode;

ARCHITECTURE Behavioral OF Fetch_Decode IS
BEGIN

    PROCESS (clk, reset)
    BEGIN
        IF reset = '1' THEN
            IF_ID_Instruction <= (OTHERS => '0');
            IF_ID_PC          <= (OTHERS => '0');

        ELSIF rising_edge(clk) THEN
            IF MemDest = '1' AND IF_ID_Write = '1' THEN
                IF_ID_Instruction <= fetched_instruction;
                IF_ID_PC          <= PC;

            END IF;

        END IF;
    END PROCESS;
END Behavioral;