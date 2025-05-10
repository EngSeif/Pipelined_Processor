LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY Decode_Execute IS
    PORT (
        clk   : IN STD_LOGIC;
        reset : IN STD_LOGIC;

        EX : IN STD_LOGIC;
        M  : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        WB : IN STD_LOGIC_VECTOR(1 DOWNTO 0);

        PC : IN STD_LOGIC_VECTOR(11 DOWNTO 0);

        index     : IN STD_LOGIC;
        readData1 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        readData2 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        Rsrc1     : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        Rsrc2     : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        Rdest     : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        Opcode    : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
        Off_Imm   : IN STD_LOGIC_VECTOR(31 DOWNTO 0);

        -- Outputs to Execute stage
        ID_EXE_M  : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        ID_EXE_WB : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);

        ID_EXE_PC : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);

        ID_EXE_index     : OUT STD_LOGIC;
        ID_EXE_readData1 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        ID_EXE_readData2 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        ID_EXE_Rsrc1     : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        ID_EXE_Rsrc2     : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        ID_EXE_Rdest     : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        ID_EXE_Opcode    : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
        ID_EXE_Off_Imm   : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END Decode_Execute;

ARCHITECTURE Behavioral OF Decode_Execute IS
BEGIN

    PROCESS (clk, reset)
    BEGIN
        IF reset = '1' THEN
            ID_EXE_M         <= "00";
            ID_EXE_WB        <= (OTHERS => '0');
            ID_EXE_PC        <= (OTHERS => '0');
            ID_EXE_index     <= '0';
            ID_EXE_readData1 <= (OTHERS => '0');
            ID_EXE_readData2 <= (OTHERS => '0');
            ID_EXE_Rsrc1     <= (OTHERS => '0');
            ID_EXE_Rsrc2     <= (OTHERS => '0');
            ID_EXE_Rdest     <= (OTHERS => '0');
            ID_EXE_Opcode    <= (OTHERS => '0');
            ID_EXE_Off_Imm   <= (OTHERS => '0');
        ELSIF rising_edge(clk) THEN
            IF EX = '1' THEN
                ID_EXE_M         <= M;
                ID_EXE_WB        <= WB;
                ID_EXE_PC        <= PC;
                ID_EXE_index     <= index;
                ID_EXE_readData1 <= readData1;
                ID_EXE_readData2 <= readData2;
                ID_EXE_Rsrc1     <= Rsrc1;
                ID_EXE_Rsrc2     <= Rsrc2;
                ID_EXE_Rdest     <= Rdest;
                ID_EXE_Opcode    <= Opcode;
                ID_EXE_Off_Imm   <= Off_Imm;

            END IF;

        END IF;
    END PROCESS;
END Behavioral;