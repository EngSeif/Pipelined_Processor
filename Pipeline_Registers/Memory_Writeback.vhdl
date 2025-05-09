LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY Memory_Writeback IS
    PORT (
        clk                 : IN STD_LOGIC;
        reset               : IN STD_LOGIC;
        
        WB                  : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
               
        readData1           : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        readData2           : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        memoryData         : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        ALU_result          : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        Rsrc1               : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        Rsrc2               : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        Rdest               : IN STD_LOGIC_VECTOR(2 DOWNTO 0);

        -- Outputs to Writeback stage
        MEM_WB_WB           : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        
        MEM_WB_readData1    : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        MEM_WB_readData2    : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        MEM_WB_memoryData   : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        MEM_WB_ALU_result   : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        MEM_WB_Rsrc1        : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        MEM_WB_Rsrc2        : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        MEM_WB_Rdest        : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
    );
END Memory_Writeback;

ARCHITECTURE Behavioral OF Memory_Writeback IS
BEGIN

    PROCESS (clk, reset)
    BEGIN
        IF reset = '1' THEN
            MEM_WB_WB           <= (others => '0');
            MEM_WB_readData1    <= (others => '0');
            MEM_WB_readData2    <= (others => '0');
            MEM_WB_memoryData   <= (others => '0');
            MEM_WB_ALU_result   <= (others => '0');
            MEM_WB_Rsrc1        <= (others => '0');
            MEM_WB_Rsrc2        <= (others => '0');
            MEM_WB_Rdest        <= (others => '0');


        ELSIF rising_edge(clk) THEN
            if WB = "01" or WB = "10" or WB = "11" then
                MEM_WB_readData1    <= readData1;
                MEM_WB_readData2    <= readData2;
                MEM_WB_memoryData   <= memorydata;
                MEM_WB_ALU_result   <= ALU_result;
                MEM_WB_Rsrc1        <= Rsrc1;
                MEM_WB_Rsrc2        <= Rsrc2;
                MEM_WB_Rdest        <= Rdest;

            end if;

        END IF;
    END PROCESS;
END Behavioral;