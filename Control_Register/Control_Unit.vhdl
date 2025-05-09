LIBRARY IEEE;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY Control_unit IS
    PORT (
        instruction_bits : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- Instruction bits

        -- Flags
        zero_flag : IN STD_LOGIC;
        carry_flag : IN STD_LOGIC;
        negative_flag : IN STD_LOGIC;

        -- External signals
        Int : IN STD_LOGIC;
        rst : IN STD_LOGIC;
        clk : IN STD_LOGIC;

        -- for stall
        dst_reg_ex : IN STD_LOGIC_VECTOR(2 DOWNTO 0); -- Destination reg in EX stage
        is_load_ex : IN STD_LOGIC; -- Is EX instruction a LDD
        mem_access_ex : IN STD_LOGIC;
        mem_access_mem : IN STD_LOGIC;

        -- Control outputs
        wb_ctrl : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        pc_src : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        address_sel : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        mem_read : OUT STD_LOGIC;
        mem_write : OUT STD_LOGIC;
        reg_write_1 : OUT STD_LOGIC;
        reg_write_2 : OUT STD_LOGIC;
        hlt_flag : OUT STD_LOGIC;
        sp_enable : OUT STD_LOGIC;
        sp_push : OUT STD_LOGIC;
        Int_Type : OUT STD_LOGIC;
        stall_flag : OUT STD_LOGIC;
        flush : OUT STD_LOGIC
    );
END ENTITY Control_unit;

-- pc_src       ✅
-- mem_read     ✅
-- mem_write    ✅
-- Address_sel  ✅
-- hlt_flag     ✅
-- reg_write_2  ✅
-- reg_write_1  ✅
-- sp_enable    ✅
-- sp_push      ✅
-- wb_ctrl      ✅
-- Int_Type     ✅
-- stall_flag   (nearly correct i think)
-- flush        (nearly correct i think)

ARCHITECTURE control_arch OF Control_unit IS

    CONSTANT OPCODE_WIDTH : INTEGER := 6;
    SIGNAL opcode : STD_LOGIC_VECTOR(OPCODE_WIDTH - 1 DOWNTO 0);

BEGIN
    opcode <= instruction_bits(31 DOWNTO 26);

    -- PC source control
    PROCESS (opcode, zero_flag, negative_flag, carry_flag, Int)
    BEGIN
        CASE opcode IS
            WHEN "110000" => -- JZ
                IF zero_flag = '1' THEN
                    pc_src <= "01";
                ELSE
                    pc_src <= "00";
                END IF;
            WHEN "110001" => -- JN
                IF negative_flag = '1' THEN
                    pc_src <= "01";
                ELSE
                    pc_src <= "00";
                END IF;
            WHEN "110010" => -- JC
                IF carry_flag = '1' THEN
                    pc_src <= "01";
                ELSE
                    pc_src <= "00";
                END IF;
            WHEN "110011" => -- JMP
                pc_src <= "01";
            WHEN "000100" => -- INT
                pc_src <= "10";
            WHEN "000011" | "000101" => -- RET or RTI
                pc_src <= "11";
            WHEN OTHERS =>
                IF Int = '1' THEN
                    pc_src <= "10";
                ELSE
                    pc_src <= "00"; -- Default: PC + 1
                END IF;
        END CASE;
    END PROCESS;

    -- Memory read control
    PROCESS (opcode)
    BEGIN
        CASE opcode IS
            WHEN "100010" | "011010" | "000011" | "000101" => -- LDD, POP, RET, RTI
                mem_read <= '1';
            WHEN OTHERS =>
                mem_read <= '0';
        END CASE;
    END PROCESS;

    -- Memory write control
    PROCESS (opcode, Int)
    BEGIN
        CASE opcode IS
            WHEN "100011" | "011001" | "100100" | "000100" => -- STD, PUSH, CALL, INT
                mem_write <= '1';
            WHEN OTHERS =>
                IF Int = '1' THEN
                    mem_write <= '1';
                ELSE
                    mem_write <= '0';
                END IF;
        END CASE;
    END PROCESS;

    -- Writeback control (centralized)
    PROCESS (opcode)
    BEGIN
        CASE opcode IS
            WHEN "100011" | "011001" | "100100" | "000100" => -- Memory Write + INT
                wb_ctrl <= "11";
            WHEN "010011" => -- IN
                wb_ctrl <= "10";
            WHEN "010000" TO "100001" | "100010" => -- Most reg-write instructions
                wb_ctrl <= "01";
            WHEN OTHERS =>
                wb_ctrl <= "00";
        END CASE;
    END PROCESS;

    -- Stack and Address selection
    PROCESS (opcode, Int)
    BEGIN
        -- Defaults
        sp_enable <= '0';
        sp_push <= '0';
        address_sel <= "00";

        CASE opcode IS
            WHEN "011001" | "100100" | "000100" => -- PUSH, CALL, INT
                address_sel <= "01";
                sp_enable <= '1';
                sp_push <= '1';
            WHEN "011010" | "000011" | "000101" => -- POP, RET, RTI
                address_sel <= "01";
                sp_enable <= '1';
                sp_push <= '0';
            WHEN "100010" | "100011" => -- LDD, STD
                address_sel <= "10";
            WHEN OTHERS =>
                IF Int = '1' THEN
                    address_sel <= "11";
                    sp_enable <= '1';
                    sp_push <= '1';
                END IF;
        END CASE;
    END PROCESS;

    -- Register write control
    PROCESS (opcode)
    BEGIN
        CASE opcode IS
            WHEN "010000" TO "100001" | "100010" | "010011" => -- NOT to LDM, LDD, IN
                reg_write_1 <= '1';
            WHEN OTHERS =>
                reg_write_1 <= '0';
        END CASE;
    END PROCESS;

    -- Register write for second operand (SWAP)
    PROCESS (opcode)
    BEGIN
        IF opcode = "010101" THEN -- SWAP
            reg_write_2 <= '1';
        ELSE
            reg_write_2 <= '0';
        END IF;
    END PROCESS;

    -- HLT instruction
    PROCESS (opcode)
    BEGIN
        IF opcode = "000001" THEN -- HLT
            hlt_flag <= '1';
        ELSE
            hlt_flag <= '0';
        END IF;
    END PROCESS;

    -- INT_TYPE instruction
    PROCESS (opcode)
    BEGIN
        IF opcode = "000100" THEN -- INT SOFTWARE
            Int_Type <= '1';
        ELSIF (Int = '1') THEN
            Int_Type <= '0';
        END IF;
    END PROCESS;

    -- Stall flag handling
    PROCESS (is_load_ex, dst_reg_ex, opcode, mem_access_ex, mem_access_mem, Int, zero_flag, negative_flag, carry_flag)
    BEGIN
        -- Load-Use Data Hazard
        IF (is_load_ex = '1') AND
            ((dst_reg_ex = instruction_bits(22 DOWNTO 20)) OR (dst_reg_ex = instruction_bits(19 DOWNTO 17))) THEN
            stall_flag <= '1'; -- Data hazard detected → Stall pipeline

            -- Structural Hazard: Instruction fetch vs memory access
        ELSIF (mem_access_ex = '1') OR (mem_access_mem = '1') THEN
            stall_flag <= '1';

            -- Control Hazard (branch/jump)
        ELSIF (opcode = "110011") THEN -- JMP (always taken)
            stall_flag <= '1';
        ELSIF (opcode = "110000" AND zero_flag = '1') THEN -- JZ (if Z=1)
            stall_flag <= '1';
        ELSIF (opcode = "110001" AND negative_flag = '1') THEN -- JN (if N=1)
            stall_flag <= '1';
        ELSIF (opcode = "110010" AND carry_flag = '1') THEN -- JC (if C=1)
            stall_flag <= '1';

            -- Interrupt Stall (Hardware OR Software)
        ELSIF (Int = '1' OR opcode = "000100") THEN
            stall_flag <= '1';

            -- No hazard → Proceed normally
        ELSE
            stall_flag <= '0';
        END IF;

        IF (Int = '1') THEN
            stall_flag <= '1';
        END IF;
    END PROCESS;

    -- Flush control 
    PROCESS (opcode, zero_flag, negative_flag, carry_flag, Int)
    BEGIN
        flush <= '0'; -- Default: no flush

        -- 1. Branch/Jump Taken
        IF (opcode = "110011") OR -- JMP (unconditional)
            (opcode = "110000" AND zero_flag = '1') OR -- JZ (Z=1)
            (opcode = "110001" AND negative_flag = '1') OR -- JN (N=1)
            (opcode = "110010" AND carry_flag = '1') THEN -- JC (C=1)
            flush <= '1';
        END IF;

        -- Check Back on it
        -- -- 2. Interrupts (Software/Hardware)
        -- IF (opcode = "000100" OR Int = '1') THEN -- INT or hardware interrupt
        --     flush <= '1';
        -- END IF;

        -- 3. Returns (RET/RTI)
        IF (opcode = "000011" OR opcode = "000101") THEN -- RET or RTI
            flush <= '1';
        END IF;
    END PROCESS;

END ARCHITECTURE control_arch;