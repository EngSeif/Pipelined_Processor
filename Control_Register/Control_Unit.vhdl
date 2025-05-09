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
        pc_src : output STD_LOGIC_VECTOR(2 DOWNTO 0);
        mem_read : output STD_LOGIC;
        mem_write : output STD_LOGIC;
        address_sel : output STD_LOGIC;
        sp_up_down : output STD_LOGIC;
        stall_flag : output STD_LOGIC;
        hlt_flag : output STD_LOGIC;
        reg_write_1 : output STD_LOGIC;
        reg_write_2 : output STD_LOGIC
    );

END ENTITY Control_unit;

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

END ARCHITECTURE control_arch;