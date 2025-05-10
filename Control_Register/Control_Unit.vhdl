LIBRARY IEEE;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY Control_unit IS
    PORT (
        instruction_bits : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        zero_flag : IN STD_LOGIC;
        carry_flag : IN STD_LOGIC;
        negative_flag : IN STD_LOGIC;
        Int : IN STD_LOGIC;
        rst : IN STD_LOGIC;
        clk : IN STD_LOGIC;
        opcode_ex : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
        opcode_mem : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
        dst_reg_ex : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
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

ARCHITECTURE control_arch OF Control_unit IS
    CONSTANT OPCODE_WIDTH : INTEGER := 6;
    SIGNAL opcode : STD_LOGIC_VECTOR(OPCODE_WIDTH - 1 DOWNTO 0);
    SIGNAL mem_access_ex, mem_access_mem : STD_LOGIC;

    -- Opcode constants
    CONSTANT OP_HLT : STD_LOGIC_VECTOR(5 DOWNTO 0) := "000001";
    CONSTANT OP_INT : STD_LOGIC_VECTOR(5 DOWNTO 0) := "000100";
    CONSTANT OP_RET : STD_LOGIC_VECTOR(5 DOWNTO 0) := "000011";
    CONSTANT OP_RTI : STD_LOGIC_VECTOR(5 DOWNTO 0) := "000101";
    CONSTANT OP_SWAP : STD_LOGIC_VECTOR(5 DOWNTO 0) := "010101";
    CONSTANT OP_IN : STD_LOGIC_VECTOR(5 DOWNTO 0) := "010011";
    CONSTANT OP_PUSH : STD_LOGIC_VECTOR(5 DOWNTO 0) := "011001";
    CONSTANT OP_POP : STD_LOGIC_VECTOR(5 DOWNTO 0) := "011010";
    CONSTANT OP_LDD : STD_LOGIC_VECTOR(5 DOWNTO 0) := "100010";
    CONSTANT OP_STD : STD_LOGIC_VECTOR(5 DOWNTO 0) := "100011";
    CONSTANT OP_CALL : STD_LOGIC_VECTOR(5 DOWNTO 0) := "100100";
    CONSTANT OP_JZ : STD_LOGIC_VECTOR(5 DOWNTO 0) := "110000";
    CONSTANT OP_JN : STD_LOGIC_VECTOR(5 DOWNTO 0) := "110001";
    CONSTANT OP_JC : STD_LOGIC_VECTOR(5 DOWNTO 0) := "110010";
    CONSTANT OP_JMP : STD_LOGIC_VECTOR(5 DOWNTO 0) := "110011";

BEGIN
    opcode <= instruction_bits(31 DOWNTO 26);
    -- Update memory access flags based on opcodes
    mem_access_ex <= '1' WHEN (opcode_ex = OP_LDD OR opcode_ex = OP_STD OR
        opcode_ex = OP_PUSH OR opcode_ex = OP_POP OR
        opcode_ex = OP_CALL OR opcode_ex = OP_RET OR
        opcode_ex = OP_RTI) ELSE
        '0';

    mem_access_mem <= '1' WHEN (opcode_mem = OP_LDD OR opcode_mem = OP_STD OR
        opcode_mem = OP_PUSH OR opcode_mem = OP_POP OR
        opcode_mem = OP_CALL OR opcode_mem = OP_RET OR
        opcode_mem = OP_RTI) ELSE
        '0';

    -- PC source control
    PROCESS (opcode, zero_flag, negative_flag, carry_flag, Int)
    BEGIN
        CASE opcode IS
            WHEN OP_JZ =>
                pc_src <= "01" WHEN zero_flag = '1' ELSE
                    "00";
            WHEN OP_JN =>
                pc_src <= "01" WHEN negative_flag = '1' ELSE
                    "00";
            WHEN OP_JC =>
                pc_src <= "01" WHEN carry_flag = '1' ELSE
                    "00";
            WHEN OP_JMP =>
                pc_src <= "01";
            WHEN OP_INT =>
                pc_src <= "10";
            WHEN OP_RET | OP_RTI =>
                pc_src <= "11";
            WHEN OTHERS =>
                pc_src <= "10" WHEN Int = '1' ELSE
                    "00";
        END CASE;
    END PROCESS;

    -- Memory read control
    PROCESS (opcode)
    BEGIN
        mem_read <= '1' WHEN (opcode = OP_LDD OR opcode = OP_POP OR
            opcode = OP_RET OR opcode = OP_RTI) ELSE
            '0';
    END PROCESS;

    -- Memory write control
    PROCESS (opcode, Int)
    BEGIN
        IF opcode = OP_STD OR opcode = OP_PUSH OR
            opcode = OP_CALL OR opcode = OP_INT THEN
            mem_write <= '1';
        ELSE
            mem_write <= '1' WHEN Int = '1' ELSE
                '0';
        END IF;
    END PROCESS;

    -- Writeback control
    PROCESS (opcode)
    BEGIN
        CASE opcode IS
            WHEN OP_STD | OP_PUSH | OP_CALL | OP_INT => wb_ctrl <= "11";
            WHEN OP_IN => wb_ctrl <= "10";
            WHEN OP_LDD | OP_SWAP => wb_ctrl <= "01";
            WHEN OTHERS => wb_ctrl <= "00";
        END CASE;
    END PROCESS;

    -- Stack and Address selection
    PROCESS (opcode, Int)
    BEGIN
        sp_enable <= '0';
        sp_push <= '0';
        address_sel <= "00";

        CASE opcode IS
            WHEN OP_PUSH | OP_CALL | OP_INT =>
                address_sel <= "01";
                sp_enable <= '1';
                sp_push <= '1';
            WHEN OP_POP | OP_RET | OP_RTI =>
                address_sel <= "01";
                sp_enable <= '1';
                sp_push <= '0';
            WHEN OP_LDD | OP_STD =>
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
        reg_write_1 <= '1' WHEN (opcode(5) = '0' OR opcode = OP_LDD OR
            opcode = OP_IN) ELSE
            '0';
        reg_write_2 <= '1' WHEN opcode = OP_SWAP ELSE
            '0';
    END PROCESS;

    -- HLT and interrupt handling
    PROCESS (opcode)
    BEGIN
        hlt_flag <= '1' WHEN opcode = OP_HLT ELSE
            '0';
        Int_Type <= '1' WHEN opcode = OP_INT ELSE
            '0';
    END PROCESS;

    -- Stall flag handling (improved)
    PROCESS (opcode_ex, opcode_mem, opcode, Int, zero_flag, negative_flag, carry_flag)
    BEGIN
        -- LOAD USE Handling
        -- Checks IF the instruction IN the EX stage IS a load (LDD).
        -- Compares the destination REGISTER OF the LDD (IN EX stage) WITH the source REGISTER OF the current instruction (IN ID stage).
        IF (opcode_ex = OP_LDD AND (dst_reg_ex = instruction_bits(25 DOWNTO 23))) THEN
            stall_flag <= '1';

            -- Structural Hazard Handling
        ELSIF (opcode_ex = OP_STD OR opcode_ex = OP_LDD OR opcode_ex = OP_CALL OR
            opcode_ex = OP_PUSH OR opcode_ex = OP_POP OR opcode_ex = OP_RTI OR
            opcode_ex = OP_RET OR opcode_ex = OP_INT) THEN
            stall_flag <= '1';

            -- Branching Hazard Handling
        ELSIF (opcode = OP_JMP OR
            (opcode = OP_JZ AND zero_flag = '1') OR
            (opcode = OP_JN AND negative_flag = '1') OR
            (opcode = OP_JC AND carry_flag = '1')) THEN
            stall_flag <= '1';
            -- Interrupt handling Handling
        ELSIF (Int = '1' OR opcode = OP_INT) THEN
            stall_flag <= '1';
        ELSE
            stall_flag <= '0';
        END IF;
    END PROCESS;

    -- Flush control
    PROCESS (opcode, zero_flag, negative_flag, carry_flag)
    BEGIN
        flush <= '0';
        IF (opcode = OP_JMP) OR
            (opcode = OP_JZ AND zero_flag = '1') OR
            (opcode = OP_JN AND negative_flag = '1') OR
            (opcode = OP_JC AND carry_flag = '1') OR
            (opcode = OP_RET OR opcode = OP_RTI) THEN
            flush <= '1';
        END IF;
    END PROCESS;

END ARCHITECTURE control_arch;