LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.math_real.ALL;
ENTITY MainProcessor IS
    PORT (
        clk            : IN STD_LOGIC;
        reset          : IN STD_LOGIC;
        enable_test    : IN STD_LOGIC;
        interrupt_port : IN STD_LOGIC;
        in_port        : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        out_Port       : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)

    );
END ENTITY MainProcessor;

ARCHITECTURE rtl OF MainProcessor IS

    ------------------------------- Start Pipeline Registers Declaration -----------------------------------------------

    COMPONENT Fetch_Decode
        PORT (
            clk                 : IN STD_LOGIC;
            reset               : IN STD_LOGIC;
            fetched_instruction : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            PC                  : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
            IF_ID_Write         : IN STD_LOGIC;
            MemDest             : IN STD_LOGIC;
            IF_ID_Instruction   : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            IF_ID_PC            : OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
        );
    END COMPONENT;

    ----------------------------------------------------------
    ----------------------------------------------------------

    COMPONENT Decode_Execute
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
    END COMPONENT;

    ----------------------------------------------------------
    ----------------------------------------------------------

    COMPONENT Execute_Memory
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
    END COMPONENT;

    ----------------------------------------------------------
    ----------------------------------------------------------
    COMPONENT Memory_Writeback
        PORT (
            clk   : IN STD_LOGIC;
            reset : IN STD_LOGIC;

            WB : IN STD_LOGIC_VECTOR(1 DOWNTO 0);

            readData1  : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            readData2  : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            memoryData : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            ALU_result : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            Rsrc1      : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            Rsrc2      : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            Rdest      : IN STD_LOGIC_VECTOR(2 DOWNTO 0);

            MEM_WB_WB         : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            MEM_WB_readData1  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            MEM_WB_readData2  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            MEM_WB_memoryData : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            MEM_WB_ALU_result : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            MEM_WB_Rsrc1      : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            MEM_WB_Rsrc2      : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            MEM_WB_Rdest      : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
        );
    END COMPONENT;

    ------------------------------- End Pipeline Registers Declaration -----------------------------------------------

    ------------------------------- Start Register File Declaration -----------------------------------------------
    COMPONENT Register_File
        PORT (
            clk         : IN STD_LOGIC;
            reset       : IN STD_LOGIC;
            read_reg1   : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            read_reg2   : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            write_reg1  : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            write_reg2  : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            write_data1 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            write_data2 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            RegWrite1   : IN STD_LOGIC;
            RegWrite2   : IN STD_LOGIC;
            read_data1  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            read_data2  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    END COMPONENT;

    ------------------------------- End register File Declaration -----------------------------------------------
    ------------------------------- Start Execution Stage Declaration -----------------------------------------------
    COMPONENT ExecuteStage
        PORT (
            clk               : IN STD_LOGIC;
            opcode            : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
            Rsrc1_Data_ID_EXE : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            result            : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            CCR               : OUT STD_LOGIC_VECTOR(2 DOWNTO 0) -- Z(0), N(1), C(2)
        );
    END COMPONENT;
    ------------------------------- End Execution Stage Declaration -----------------------------------------------
    ------------------------------- Start Memory Declaration -----------------------------------------------
    COMPONENT Memory
        GENERIC (
            Address_bits : INTEGER := 12;
            Data_width   : INTEGER := 32
        );
        PORT (
            clk      : IN STD_LOGIC;
            reset    : IN STD_LOGIC;
            writeEn  : IN STD_LOGIC;
            address  : IN STD_LOGIC_VECTOR(Address_bits - 1 DOWNTO 0);
            readEn   : IN STD_LOGIC;
            data_in  : IN STD_LOGIC_VECTOR(Data_width - 1 DOWNTO 0);
            data_out : OUT STD_LOGIC_VECTOR(Data_width - 1 DOWNTO 0)
        );
    END COMPONENT;

    ------------------------------- End Memory Declaration -----------------------------------------------
    ------------------------------- Start Program Counter Declaration -----------------------------------------------

    COMPONENT PC
        GENERIC (
            Address_Bits : INTEGER := 12
        );
        PORT (
            clk        : IN STD_LOGIC;
            reset      : IN STD_LOGIC;
            enable     : IN STD_LOGIC;
            writeEn    : IN STD_LOGIC;
            inAddresss : IN STD_LOGIC_VECTOR(Address_Bits - 1 DOWNTO 0);
            outAddress : OUT STD_LOGIC_VECTOR(Address_Bits - 1 DOWNTO 0)
        );
    END COMPONENT;
    ------------------------------- End Program Counter Declaration -----------------------------------------------
    ------------------------------- Start Control Unit  Declaration -----------------------------------------------
    COMPONENT Control_unit
        PORT (
            instruction_bits : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            zero_flag        : IN STD_LOGIC;
            carry_flag       : IN STD_LOGIC;
            negative_flag    : IN STD_LOGIC;
            Int              : IN STD_LOGIC;
            rst              : IN STD_LOGIC;
            clk              : IN STD_LOGIC;
            opcode_ex        : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
            opcode_mem       : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
            dst_reg_ex       : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            wb_ctrl          : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            pc_src           : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            address_sel      : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            mem_read         : OUT STD_LOGIC;
            mem_write        : OUT STD_LOGIC;
            reg_write_1      : OUT STD_LOGIC;
            reg_write_2      : OUT STD_LOGIC;
            hlt_flag         : OUT STD_LOGIC;
            sp_enable        : OUT STD_LOGIC;
            sp_push          : OUT STD_LOGIC;
            Int_Type         : OUT STD_LOGIC;
            stall_flag       : OUT STD_LOGIC;
            flush            : OUT STD_LOGIC
        );
    END COMPONENT;

    ------------------------------- End Control Unit Declaration -----------------------------------------------
    ------------------------------- start Latch Unit Declaration -----------------------------------------------
    COMPONENT Latch_Unit
        PORT (
            enable      : IN STD_LOGIC;
            reset       : IN STD_LOGIC;
            input_latch : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            output_port : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    END COMPONENT;

    ------------------------------- End Latch Unit Declaration -----------------------------------------------
    ------------------------------- Signal Declaration -----------------------------------------------

    ----PC
    SIGNAL PC_writeEn          : STD_LOGIC;                     -- Loads PC with inAddresss when set
    SIGNAL PC_enable           : STD_LOGIC;                     -- Increments PC when set (inAddresss + 1)
    SIGNAL PC_inAddress        : STD_LOGIC_VECTOR(11 DOWNTO 0); -- Source of new PC value or base for +1
    SIGNAL PC_outAddress       : STD_LOGIC_VECTOR(11 DOWNTO 0); -- Current PC output
    SIGNAL ctrl_pc_src         : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL EXE_MEM_Off_Imm_out : STD_LOGIC_VECTOR(31 DOWNTO 0);

    ----Memory
    -- SIGNAL MEM_writeEn             : STD_LOGIC; -- Asserted to perform write on falling edge (e.g., STD, PUSH)
    -- SIGNAL MEM_readEn              : STD_LOGIC; -- Asserted to perform read on rising edge (e.g., LDD, POP, RTI)
    SIGNAL MEM_Ctrl                : STD_LOGIC_VECTOR(1 DOWNTO 0) := "10";--!for testinnggg
    SIGNAL MEM_address_from_PC     : STD_LOGIC_VECTOR(11 DOWNTO 0);--!do we really need it? -- PC-based memory address
    SIGNAL MEM_address_from_ALU    : STD_LOGIC_VECTOR(11 DOWNTO 0); -- ALU result from EXE_MEM
    SIGNAL MEM_address_mux_select  : STD_LOGIC := '0';              -- Selects address source: '0' = PC, '1' = ALU
    SIGNAL MEM_address             : STD_LOGIC_VECTOR(11 DOWNTO 0); -- Final address input to memory
    SIGNAL MEM_data_in             : STD_LOGIC_VECTOR(31 DOWNTO 0); -- Data to be stored in memory (e.g., for STD, PUSH)
    SIGNAL MEM_data_out            : STD_LOGIC_VECTOR(31 DOWNTO 0); -- Output of memory
    SIGNAL MEM_data_out_mux_select : STD_LOGIC := '0';              -- Select between NOP and Instruction to IF/ID
    SIGNAL MEM_Mux_data_out        : STD_LOGIC_VECTOR(31 DOWNTO 0); -- Mux output to IF/ID
    ----Fetch Decode

    SIGNAL IF_ID_Write           : STD_LOGIC := '1';--! for testing
    SIGNAL MemDest               : STD_LOGIC := '1';--! for testing
    SIGNAL IF_ID_Instruction_out : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL IF_ID_PC_out          : STD_LOGIC_VECTOR(11 DOWNTO 0);

    ---- Register File
    -- SIGNAL Reg_Write_En_1     : STD_LOGIC;
    -- SIGNAL Reg_Write_En_2     : STD_LOGIC; --! it will come from the Mem WB register
    SIGNAL read_reg1_address  : STD_LOGIC_VECTOR(2 DOWNTO 0) := IF_ID_Instruction_out(22 DOWNTO 20);
    SIGNAL read_reg2_address  : STD_LOGIC_VECTOR(2 DOWNTO 0) := IF_ID_Instruction_out(19 DOWNTO 17);
    SIGNAL write_reg1_address : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL write_reg2_address : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL write_reg1_data    : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL write_reg2_data    : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL Read_reg1_data     : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL Read_reg2_data     : STD_LOGIC_VECTOR(31 DOWNTO 0);
    ---- Decode Execute
    SIGNAL EX                     : STD_LOGIC;
    SIGNAL M_for_decode_execute   : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL WB_for_decode_execute  : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL Off_Imm_decode_execute : STD_LOGIC_VECTOR(31 DOWNTO 0);

    SIGNAL M_for_execute_memory  : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL WB_for_execute_memory : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL ID_EXE_PC_out         : STD_LOGIC_VECTOR(11 DOWNTO 0);
    SIGNAL ID_EXE_Index_out      : STD_LOGIC;
    SIGNAL ID_EXE_readData1_out  : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL ID_EXE_readData2_out  : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL ID_EXE_Rsrc1_out      : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL ID_EXE_Rsrc2_out      : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL ID_EXE_Rdest_out      : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL ID_EXE_Opcode_out     : STD_LOGIC_VECTOR(5 DOWNTO 0);
    SIGNAL ID_EXE_Off_Imm_out    : STD_LOGIC_VECTOR(31 DOWNTO 0);

    --!-- Execute Memory
    -- SIGNAL M_for_execute_memory  : STD_LOGIC;
    -- SIGNAL WB_for_execute_memory : STD_LOGIC;
    SIGNAL EXE_MEM_index_out      : STD_LOGIC;
    SIGNAL WB_Memory_WriteBack    : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL EXE_MEM_readData1_out  : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL EXE_MEM_readData2_out  : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL EXE_MEM_ALU_result_out : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL EXE_MEM_Rsrc1_out      : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL EXE_MEM_Rsrc2_out      : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL EXE_MEM_Rdest_out      : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL EXE_MEM_opcode_out     : STD_LOGIC_VECTOR(5 DOWNTO 0);
    SIGNAL EXE_MEM_Off_Imm_sig    : STD_LOGIC_VECTOR(31 DOWNTO 0);
    ----Memory Write Back
    SIGNAL MEM_WB_WB_for_register_file : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL MEM_WB_readData1_out        : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL MEM_WB_readData2_out        : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL MEM_WB_memoryData_out       : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL MEM_WB_ALU_result_out       : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL MEM_WB_Rsrc1_out            : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL MEM_WB_Rsrc2_out            : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL MEM_WB_Rdest_out            : STD_LOGIC_VECTOR(2 DOWNTO 0);

    ---- WB Data Muxes
    SIGNAL Final_out_data_to_write_Back_to_register_File : STD_LOGIC_VECTOR(31 DOWNTO 0);
    ---- control signals--!some still not connected
    SIGNAL wb_ctrl      : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL hlt_flag     : STD_LOGIC;                    --!
    SIGNAL sp_enable    : STD_LOGIC;                    --!
    SIGNAL sp_push      : STD_LOGIC;                    --!
    SIGNAL Int_Type     : STD_LOGIC;                    --!
    SIGNAL stall_flag   : STD_LOGIC;                    --!
    SIGNAL flush        : STD_LOGIC;                    --!
    SIGNAL Latch_enable : STD_LOGIC;                    --!
    SIGNAL address_sel  : STD_LOGIC_VECTOR(1 DOWNTO 0); --!

    ---- Execute_Stage
    SIGNAL EXEC_STAGE_Result : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL CCR_out           : STD_LOGIC_VECTOR(2 DOWNTO 0);

BEGIN
    Off_Imm_decode_execute <= (15 DOWNTO 0 => IF_ID_Instruction_out(19)) & IF_ID_Instruction_out(19 DOWNTO 4);


    WITH MEM_data_out_mux_select SELECT
        MEM_Mux_data_out <= MEM_data_out WHEN '0',
        (OTHERS => '0') WHEN OTHERS; --like NOP , this is a mux between NOP and data out of Memory
    -- before IF/ID mux 

    WITH MEM_address_mux_select SELECT
        MEM_address <= PC_outAddress WHEN '0',
        EXEC_STAGE_Result WHEN '1',
        (OTHERS => '0') WHEN OTHERS; -- memory address mux either pc or immediate

    WITH MEM_WB_WB_for_register_file(1) SELECT
    write_reg1_address <= MEM_WB_Rdest_out WHEN '0',
        MEM_WB_Rsrc2_out WHEN '1',
        (OTHERS => '0') WHEN OTHERS;--! register file muxes 

    WITH MEM_WB_WB_for_register_file(1) SELECT
    write_reg1_data <= Final_out_data_to_write_Back_to_register_File WHEN '0',
        MEM_WB_readData1_out WHEN '1',
        (OTHERS => '0') WHEN OTHERS;--! register file muxes 

    WITH wb_ctrl SELECT
        Final_out_data_to_write_Back_to_register_File <= MEM_WB_ALU_result_out WHEN "00",
        in_port WHEN "01",
        MEM_WB_ALU_result_out WHEN "10",
        (OTHERS => '0') WHEN OTHERS; -- -- what to Write Back Mux

    WITH ctrl_pc_src SELECT
        PC_inAddress <= PC_outAddress WHEN "00",
        EXE_MEM_Off_Imm_out(11 DOWNTO 0) WHEN "01",
        (OTHERS => '0') WHEN OTHERS; -- -- from where to get PC Mux
    ------------------------------- Start pipeline registers Instantiation -----------------------------------------------
    Fetch_Decode_REG : Fetch_Decode
    PORT MAP(
        clk                 => clk,
        reset               => reset,
        fetched_instruction => MEM_Mux_data_out,
        PC                  => PC_outAddress,
        IF_ID_Write         => IF_ID_Write,
        MemDest             => MemDest,
        IF_ID_Instruction   => IF_ID_Instruction_out,
        IF_ID_PC            => IF_ID_PC_out
    );

    ----------------------------------------------------------
    ----------------------------------------------------------

    Decode_Execute_REG : Decode_Execute
    PORT MAP(
        clk              => clk,
        reset            => reset,
        EX               => EX,
        M                => M_for_decode_execute,
        WB               => WB_for_decode_execute,
        PC               => IF_ID_PC_out,
        index            => IF_ID_Instruction_out(25),
        readData1        => Read_reg1_data,
        readData2        => Read_reg2_data,
        Rsrc1            => read_reg1_address,
        Rsrc2            => read_reg2_address,
        Rdest            => IF_ID_Instruction_out(25 DOWNTO 23),
        Opcode           => IF_ID_Instruction_out(31 DOWNTO 26),
        Off_Imm          => Off_Imm_decode_execute,
        ID_EXE_M         => M_for_execute_memory,
        ID_EXE_WB        => WB_for_execute_memory,
        ID_EXE_PC        => ID_EXE_PC_out,
        ID_EXE_index     => ID_EXE_Index_out,
        ID_EXE_readData1 => ID_EXE_readData1_out,
        ID_EXE_readData2 => ID_EXE_readData2_out,
        ID_EXE_Rsrc1     => ID_EXE_Rsrc1_out,
        ID_EXE_Rsrc2     => ID_EXE_Rsrc2_out,
        ID_EXE_Rdest     => ID_EXE_Rdest_out,
        ID_EXE_Opcode    => ID_EXE_Opcode_out,
        ID_EXE_Off_Imm   => ID_EXE_Off_Imm_out
    );

    ----------------------------------------------------------
    ----------------------------------------------------------

    Execute_Memory_REG : Execute_Memory
    PORT MAP(
        clk                => clk,
        reset              => reset,
        M                  => M_for_execute_memory,
        WB                 => WB_for_execute_memory,
        opcode             => ID_EXE_Opcode_out,
        PC                 => ID_EXE_PC_out,
        index              => ID_EXE_Index_out,
        readData1          => ID_EXE_readData1_out,
        readData2          => ID_EXE_readData2_out,
        ALU_result         => EXEC_STAGE_Result,
        Rsrc1              => ID_EXE_Rsrc1_out,
        Rsrc2              => ID_EXE_Rsrc2_out,
        Rdest              => ID_EXE_Rdest_out,
        Off_Imm            => ID_EXE_Off_Imm_out,
        EXE_MEM_M          => MEM_Ctrl, --gona make it MEM_readEn for now --!need to check to see which signal is it
        EXE_MEM_WB         => WB_Memory_WriteBack,
        EXE_MEM_opcode     => EXE_MEM_opcode_out,
        EXE_MEM_PC         => MEM_address_from_PC, --!NOT CONNECTED YET -- to write is as data
        EXE_MEM_index      => EXE_MEM_index_out,   --!NOT CONNECTED YET
        EXE_MEM_readData1  => EXE_MEM_readData1_out,
        EXE_MEM_readData2  => EXE_MEM_readData2_out,
        EXE_MEM_ALU_result => EXE_MEM_ALU_result_out,
        EXE_MEM_Rsrc1      => EXE_MEM_Rsrc1_out,
        EXE_MEM_Rsrc2      => EXE_MEM_Rsrc2_out,
        EXE_MEM_Rdest      => EXE_MEM_Rdest_out,
        EXE_MEM_Off_Imm    => EXE_MEM_Off_Imm_out
    );

    ----------------------------------------------------------
    ----------------------------------------------------------
    Memory_WriteBack_REG : Memory_Writeback
    PORT MAP(
        clk               => clk,
        reset             => reset,
        WB                => WB_Memory_WriteBack,
        readData1         => EXE_MEM_readData1_out,
        readData2         => EXE_MEM_readData2_out,
        memoryData        => MEM_data_out,
        ALU_result        => EXE_MEM_ALU_result_out,
        Rsrc1             => EXE_MEM_Rsrc1_out,
        Rsrc2             => EXE_MEM_Rsrc2_out,
        Rdest             => EXE_MEM_Rdest_out,
        MEM_WB_WB         => MEM_WB_WB_for_register_file,
        MEM_WB_readData1  => MEM_WB_readData1_out,
        MEM_WB_readData2  => MEM_WB_readData2_out,
        MEM_WB_memoryData => MEM_WB_memoryData_out,
        MEM_WB_ALU_result => MEM_WB_ALU_result_out,
        MEM_WB_Rsrc1      => MEM_WB_Rsrc1_out,
        MEM_WB_Rsrc2      => MEM_WB_Rsrc2_out,
        MEM_WB_Rdest      => MEM_WB_Rdest_out
    );
    ------------------------------- End pipeline Registers Instantiation -----------------------------------------------
    ------------------------------- Start Control Unit Instantiation -----------------------------------------------

    Control_Unit_REG : Control_unit
    PORT MAP(
        instruction_bits => IF_ID_Instruction_out,
        zero_flag        => CCR_out(0),
        carry_flag       => CCR_out(2),
        negative_flag    => CCR_out(1),
        Int              => interrupt_port,
        rst              => reset,
        clk              => clk,
        opcode_ex        => ID_EXE_Opcode_out,
        opcode_mem       => EXE_MEM_opcode_out,
        dst_reg_ex       => EXE_MEM_Rdest_out,
        wb_ctrl          => wb_ctrl,
        pc_src           => ctrl_pc_src,
        address_sel      => address_sel,
        mem_read         => M_for_decode_execute(1),
        mem_write        => M_for_decode_execute(0),
        reg_write_1      => WB_for_decode_execute(0),
        reg_write_2      => WB_for_decode_execute(1),
        hlt_flag         => hlt_flag, --stop pc
        sp_enable        => sp_enable,
        sp_push          => sp_push,    --
        Int_Type         => Int_Type,   -- for mem block -- see later
        stall_flag       => stall_flag, -- see later
        flush            => flush       -- see later
    );
    ------------------------------- End  Control Unit Instantiation -----------------------------------------------

    ------------------------------- Start Registers File Instantiation -----------------------------------------------

    REG_FILE : Register_File --!write signals should come from the write back register
    PORT MAP(
        clk         => clk,
        reset       => reset,
        read_reg1   => read_reg1_address,
        read_reg2   => read_reg2_address,
        write_reg1  => write_reg1_address,
        write_reg2  => MEM_WB_Rsrc1_out,
        write_data1 => write_reg1_data,
        write_data2 => MEM_WB_readData2_out,
        RegWrite1   => MEM_WB_WB_for_register_file(0),
        RegWrite2   => MEM_WB_WB_for_register_file(1),
        read_data1  => Read_reg1_data,
        read_data2  => Read_reg2_data
    );
    ------------------------------- End Registers File Instantiation -----------------------------------------------
    ------------------------------- Start Memory Instantiation -----------------------------------------------
    MAIN_MEMORY : Memory
    GENERIC MAP(
        Address_bits => 12,
        Data_width   => 32
    )
    PORT MAP(
        clk      => clk,
        reset    => reset,
        writeEn  => MEM_Ctrl(0),
        address  => MEM_address,
        readEn   => MEM_Ctrl(1),
        data_in  => MEM_data_in, --! needs to be connected
        data_out => MEM_data_out
    );
    ------------------------------- End Memory Instantiation -----------------------------------------------
    ------------------------------- Start Execute Stage Instantiation -----------------------------------------------
    EXEC_STAGE : ExecuteStage
    PORT MAP(
        clk               => clk,
        opcode            => ID_EXE_Opcode_out,
        Rsrc1_Data_ID_EXE => ID_EXE_readData1_out,
        result            => EXEC_STAGE_Result,
        CCR               => CCR_out
    );

    ------------------------------- End  Execute Stage Instantiation -----------------------------------------------
    ------------------------------- Start Program Counter Instantiation -----------------------------------------------
    PC_REG : PC
    GENERIC MAP(
        Address_Bits => 12
    )
    PORT MAP(
        clk        => clk,
        reset      => reset,
        enable     => PC_enable,
        writeEn    => PC_writeEn,
        inAddresss => PC_inAddress,
        outAddress => PC_outAddress
    );
    ------------------------------- End  Program Counter Instantiation -----------------------------------------------
    ------------------------------- Start Latch Unit  Instantiation -----------------------------------------------
    LATCH_INST : Latch_Unit
    PORT MAP(
        enable      => Latch_enable,
        reset       => reset,
        input_latch => MEM_WB_readData1_out,
        output_port => out_Port
    );
    PC_enable <= enable_test;

    ------------------------------- End  Latch Unit Instantiation -----------------------------------------------

END ARCHITECTURE;