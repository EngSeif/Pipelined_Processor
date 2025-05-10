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

    -- Memory access tracking signals
    SIGNAL mem_access_ex, mem_access_mem : STD_LOGIC;

BEGIN
    opcode <= instruction_bits(31 DOWNTO 26);

    -- Memory access flags
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

    -- Consolidated output generation process
    PROCESS (rst, opcode, zero_flag, negative_flag, carry_flag, Int,
        opcode_ex, dst_reg_ex, opcode_mem, instruction_bits, mem_access_ex, mem_access_mem)
    BEGIN
        IF rst = '1' THEN
            -- Reset all outputs
            wb_ctrl <= (OTHERS => '0');
            pc_src <= (OTHERS => '0');
            address_sel <= (OTHERS => '0');
            mem_read <= '0';
            mem_write <= '0';
            reg_write_1 <= '0';
            reg_write_2 <= '0';
            hlt_flag <= '0';
            sp_enable <= '0';
            sp_push <= '0';
            Int_Type <= '0';
            stall_flag <= '0';
            flush <= '0';
        ELSE
            -- Default assignments
            pc_src <= "00";
            mem_read <= '0';
            mem_write <= '0';
            wb_ctrl <= "00";
            sp_enable <= '0';
            sp_push <= '0';
            address_sel <= "00";
            reg_write_1 <= '0';
            reg_write_2 <= '0';
            hlt_flag <= '0';
            Int_Type <= '0';
            stall_flag <= '0';
            flush <= '0';

            -- PC Source Control
            CASE opcode IS
                WHEN OP_JZ =>
                    IF zero_flag = '1' THEN
                        pc_src <= "01";
                    ELSE
                        pc_src <= "00";
                    END IF;
                WHEN OP_JN =>
                    IF negative_flag = '1' THEN
                        pc_src <= "01";
                    ELSE
                        pc_src <= "00";
                    END IF;
                WHEN OP_JC =>
                    IF carry_flag = '1' THEN
                        pc_src <= "01";
                    ELSE
                        pc_src <= "00";
                    END IF;
                WHEN OP_JMP =>
                    pc_src <= "01";
                WHEN OP_INT =>
                    pc_src <= "10";
                WHEN OP_RET | OP_RTI =>
                    pc_src <= "11";
                WHEN OTHERS =>
                    IF Int = '1' THEN
                        pc_src <= "10";
                    ELSE
                        pc_src <= "00";
                    END IF;
            END CASE;

            -- Memory Read Control
            IF (opcode = OP_LDD OR opcode = OP_POP OR
                opcode = OP_RET OR opcode = OP_RTI) THEN
                mem_read <= '1';
            END IF;

            -- Memory Write Control
            IF opcode = OP_STD OR opcode = OP_PUSH OR
                opcode = OP_CALL OR opcode = OP_INT OR Int = '1' THEN
                mem_write <= '1';
            END IF;

            -- Writeback Control
            CASE opcode IS
                WHEN OP_STD | OP_PUSH | OP_CALL | OP_INT =>
                    wb_ctrl <= "11";
                WHEN OP_IN =>
                    wb_ctrl <= "10";
                WHEN OP_LDD | OP_SWAP =>
                    wb_ctrl <= "01";
                WHEN OTHERS =>
                    wb_ctrl <= "00";
            END CASE;

            -- Stack and Address Selection
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

            -- Register Write Control
            IF (opcode(5) = '0' OR opcode = OP_LDD OR opcode = OP_IN) THEN
                reg_write_1 <= '1';
            END IF;

            IF opcode = OP_SWAP THEN
                reg_write_2 <= '1';
            END IF;

            -- HLT and Interrupt Handling
            IF opcode = OP_HLT THEN
                hlt_flag <= '1';
            END IF;

            IF opcode = OP_INT THEN
                Int_Type <= '1';
            END IF;

            -- Stall Flag Handling
            IF (opcode_ex = OP_LDD AND (dst_reg_ex = instruction_bits(25 DOWNTO 23))) OR
                (mem_access_ex = '1' OR mem_access_mem = '1') OR -- Structural hazards
                (opcode = OP_JMP OR
                (opcode = OP_JZ AND zero_flag = '1') OR
                (opcode = OP_JN AND negative_flag = '1') OR
                (opcode = OP_JC AND carry_flag = '1')) OR
                (Int = '1' OR opcode = OP_INT) THEN
                stall_flag <= '1';
            END IF;

            -- Flush Control
            IF (opcode = OP_JMP) OR
                (opcode = OP_JZ AND zero_flag = '1') OR
                (opcode = OP_JN AND negative_flag = '1') OR
                (opcode = OP_JC AND carry_flag = '1') OR
                (opcode = OP_RET OR opcode = OP_RTI) THEN
                flush <= '1';
            END IF;
        END IF;
    END PROCESS;

END ARCHITECTURE control_arch;