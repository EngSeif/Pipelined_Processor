LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY Execute_Memory IS
    PORT (
        clk   : IN STD_LOGIC;
        reset : IN STD_LOGIC;

        M  : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        WB : IN STD_LOGIC_VECTOR(1 DOWNTO 0);

        PC         : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
        opcode     : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
        index      : IN STD_LOGIC;
        readData1  : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        readData2  : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        ALU_result : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        Rsrc1      : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        Rsrc2      : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        Rdest      : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        Off_Imm    : IN STD_LOGIC_VECTOR(31 DOWNTO 0);

        -- Outputs to Memory stage
        EXE_MEM_M  : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        EXE_MEM_WB : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);

        EXE_MEM_PC         : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
        EXE_MEM_opcode     : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
        EXE_MEM_index      : OUT STD_LOGIC;
        EXE_MEM_readData1  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        EXE_MEM_readData2  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        EXE_MEM_ALU_result : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        EXE_MEM_Rsrc1      : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        EXE_MEM_Rsrc2      : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        EXE_MEM_Rdest      : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        EXE_MEM_Off_Imm    : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END Execute_Memory;

ARCHITECTURE Behavioral OF Execute_Memory IS
BEGIN

    PROCESS (clk, reset)
    BEGIN
        IF reset = '1' THEN
            EXE_MEM_M          <= "00";
            EXE_MEM_WB         <= (OTHERS => '0');
            EXE_MEM_PC         <= (OTHERS => '0');
            EXE_MEM_index      <= '0';
            EXE_MEM_readData1  <= (OTHERS => '0');
            EXE_MEM_readData2  <= (OTHERS => '0');
            EXE_MEM_ALU_result <= (OTHERS => '0');
            EXE_MEM_Rsrc1      <= (OTHERS => '0');
            EXE_MEM_Rsrc2      <= (OTHERS => '0');
            EXE_MEM_Rdest      <= (OTHERS => '0');
            EXE_MEM_Off_Imm    <= (OTHERS => '0');
            EXE_MEM_opcode     <= (OTHERS => '0');
        ELSIF rising_edge(clk) THEN
            IF WB /= "00" THEN
                EXE_MEM_WB         <= WB;
                EXE_MEM_PC         <= PC;
                EXE_MEM_index      <= index;
                EXE_MEM_readData1  <= readData1;
                EXE_MEM_readData2  <= readData2;
                EXE_MEM_ALU_result <= ALU_result;
                EXE_MEM_Rsrc1      <= Rsrc1;
                EXE_MEM_Rsrc2      <= Rsrc2;
                EXE_MEM_Rdest      <= Rdest;
                EXE_MEM_Off_Imm    <= Off_Imm;
                EXE_MEM_opcode     <= opcode;

            END IF;

        END IF;
    END PROCESS;
END Behavioral;