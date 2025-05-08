LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY IF_ID_Register IS
    PORT (
        clk                 : IN STD_LOGIC;
        reset               : IN STD_LOGIC;
        flush               : IN STD_LOGIC;
        stall               : IN STD_LOGIC;
        fetched_instruction : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        pc_plus_1           : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        -- Outputs to Decode stage
        IF_ID_Instruction : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        IF_ID_PC          : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END IF_ID_Register;

ARCHITECTURE Behavioral OF IF_ID_Register IS
    SIGNAL instr_reg : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL pc_reg    : STD_LOGIC_VECTOR(31 DOWNTO 0);
BEGIN

    PROCESS (clk, reset)
    BEGIN
        IF reset = '1' THEN
            instr_reg <= (OTHERS => '0');
            pc_reg    <= (OTHERS => '0');
        ELSIF rising_edge(clk) THEN
            IF flush = '1' THEN
                instr_reg <= (OTHERS => '0'); -- Flush (NOP or bubble)
                pc_reg    <= (OTHERS => '0');
            ELSIF stall = '0' THEN
                instr_reg <= fetched_instruction;
                pc_reg    <= pc_plus_1;
            END IF;
        END IF;
    END PROCESS;

    -- Output assignments
    IF_ID_Instruction <= instr_reg;
    IF_ID_PC          <= pc_reg;

END Behavioral;