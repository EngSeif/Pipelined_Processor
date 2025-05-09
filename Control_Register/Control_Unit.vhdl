LIBRARY IEEE;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY Control_unit IS
    PORT (
        instruction_bits : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- Takes Instruction bits so it helps in generating control signals

        -- signals from pipeline Registers  (To handle Hazards)
        dst_reg : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        write_back_sig : IN STD_LOGIC;

        -- flags
        zero_flag : IN STD_LOGIC;
        carry_flag : IN STD_LOGIC;
        negative_flag : IN STD_LOGIC;

        -- external signal
        Int : IN STD_LOGIC;
        rst : IN STD_LOGIC;
        clk : IN STD_LOGIC;

        -- outputs
        wb_ctrl : output STD_LOGIC_VECTOR(2 DOWNTO 0);
        pc_src : output STD_LOGIC_VECTOR(1 DOWNTO 0);
        address_sel : output STD_LOGIC_VECTOR(1 DOWNTO 0);
        mem_read : output STD_LOGIC;
        mem_write : output STD_LOGIC;
        sp_up_down : output STD_LOGIC;
        stall_flag : output STD_LOGIC;
        hlt_flag : output STD_LOGIC;
        reg_write_1 : output STD_LOGIC;
        reg_write_2 : output STD_LOGIC
    );

END ENTITY Control_unit;

-- pc_src       ✅
-- mem_read     ✅
-- mem_write    ✅
-- Address_sel  ✅
-- hlt_flag     ✅
-- reg_write_2  ✅

ARCHITECTURE control_arch OF Control_unit IS

BEGIN
    -- PC_SRC Handling logic
    PROCESS (instruction_bits, zero_flag, negative_flag, carry_flag, Int)
    BEGIN
        IF (instruction_bits(31 DOWNTO 26) = "110000" AND zero_flag = '1') THEN -- JZ
            pc_src <= "01";
        ELSIF (instruction_bits(31 DOWNTO 26) = "110001" AND negative_flag = '1') THEN -- JN
            pc_src <= "01";
        ELSIF (instruction_bits(31 DOWNTO 26) = "110010" AND carry_flag = '1') THEN -- JC 
            pc_src <= "01";
        ELSIF (instruction_bits(31 DOWNTO 26) = "110011") THEN -- JMP
            pc_src <= "01";
        ELSIF (Int = '1' OR instruction_bits(31 DOWNTO 26) = "000100") THEN -- INT (external or internal)
            pc_src <= "10";
        ELSIF (instruction_bits(31 DOWNTO 26) = "000011" OR instruction_bits(31 DOWNTO 26) = "000101") THEN -- RET or RTI
            pc_src <= "11";
        ELSE
            pc_src <= "00"; -- Normal execution (PC + 1)
        END IF;
    END PROCESS;

    -- MemRead Handling Logic
    PROCESS (instruction_bits)
    BEGIN
        IF (instruction_bits(31 DOWNTO 26) = "100010") THEN -- LDD (LOAD FROM MEMORY)
            mem_read <= "1";
        ELSIF (instruction_bits(31 DOWNTO 26) = "011010") THEN -- POP
            mem_read <= "1";
        ELSIF (instruction_bits(31 DOWNTO 26) = "000011") THEN -- RET
            mem_read <= "1";
        ELSIF (instruction_bits(31 DOWNTO 26) = "000101") THEN -- RTI
            mem_read <= "1";
        ELSE
            mem_read <= "0"; -- Normal execution (Command Doesnt Need Memory Read)
        END IF;
    END PROCESS;

    -- MemWrite/wb_ctrl Handling Logic
    PROCESS (instruction_bits)
    BEGIN
        IF (instruction_bits(31 DOWNTO 26) = "100011") THEN -- STD (Store In MEMORY)
            mem_write <= "1";
        ELSIF (instruction_bits(31 DOWNTO 26) = "011001") THEN -- PUSH
            mem_write <= "1";
        ELSIF (instruction_bits(31 DOWNTO 26) = "100100") THEN -- CALL
            mem_write <= "1";
        ELSIF (instruction_bits(31 DOWNTO 26) = "000100") THEN -- INT
            mem_write <= "1";
        ELSIF (Int = '1') THEN -- INT EXTERNAL
            mem_write <= "1";
        ELSE
            mem_write <= "0"; -- Normal execution (Command Doesnt Need Memory Write)
        END IF;
    END PROCESS;

    -- address_sel Handling Logic
    -- 1st => SP Selection
    -- 2nd => Load And Store
    -- 3rd => Interrupts
    PROCESS (instruction_bits)
    BEGIN
        IF (instruction_bits(31 DOWNTO 26) = "011001") THEN -- PUSH
            address_sel <= "01";
        ELSIF (instruction_bits(31 DOWNTO 26) = "011010") THEN -- POP
            address_sel <= "01";
        ELSIF (instruction_bits(31 DOWNTO 26) = "100100") THEN -- CALL
            address_sel <= "01";
        ELSIF (instruction_bits(31 DOWNTO 26) = "000011") THEN -- RET
            address_sel <= "01";
        ELSIF (instruction_bits(31 DOWNTO 26) = "000101") THEN -- RTI
            address_sel <= "01";
        ELSIF (instruction_bits(31 DOWNTO 26) = "100010") THEN -- LDD (LOAD FROM MEMORY)
            address_sel <= "10";
        ELSIF (instruction_bits(31 DOWNTO 26) = "100011") THEN -- STD (Store In MEMORY)
            address_sel <= "10";
        ELSIF (instruction_bits(31 DOWNTO 26) = "000100") THEN -- INT
            address_sel <= "11";
        ELSIF (Int = '1') THEN -- INT EXTERNAL
            address_sel <= "11";
        ELSE
            address_sel <= "00"; -- Normal execution (Take PC)
        END IF;
    END PROCESS;

    -- handle hlt flag
    PROCESS (instruction_bits)
    BEGIN
        IF (instruction_bits(31 DOWNTO 26) = "000001") THEN -- HLT
            hlt_flag <= "1";
        ELSE
            hlt_flag <= "0"; -- Normal 
        END IF;
    END PROCESS;

    PROCESS (instruction_bits)
    BEGIN
        IF (instruction_bits(31 DOWNTO 26) = "010101") THEN -- SWAP
            reg_write_2 <= "1";
            wb_ctrl <= "1";
        ELSE
            reg_write_2 <= "0"; -- Normal 
            wb_ctrl <= "0";
        END IF;
    END PROCESS;

END ARCHITECTURE control_arch;