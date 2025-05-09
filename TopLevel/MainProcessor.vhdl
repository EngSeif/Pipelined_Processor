LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.math_real.ALL;
ENTITY MainProcessor IS
    PORT (
        clk      : IN STD_LOGIC;
        reset    : IN STD_LOGIC;
        in_port  : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        out_Port : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)

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
            M  : IN STD_LOGIC;
            WB : IN STD_LOGIC;

            PC : IN STD_LOGIC_VECTOR(11 DOWNTO 0);

            index     : IN STD_LOGIC;
            readData1 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            readData2 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            Rsrc1     : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            Rsrc2     : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            Rdest     : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            Opcode    : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
            Off_Imm   : IN STD_LOGIC_VECTOR(31 DOWNTO 0);

            ID_EXE_M  : OUT STD_LOGIC;
            ID_EXE_WB : OUT STD_LOGIC;

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

            M  : IN STD_LOGIC;
            WB : IN STD_LOGIC;

            PC : IN STD_LOGIC_VECTOR(11 DOWNTO 0);

            index      : IN STD_LOGIC;
            readData1  : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            readData2  : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            ALU_result : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            Rsrc1      : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            Rsrc2      : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            Rdest      : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            Opcode     : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
            Off_Imm    : IN STD_LOGIC_VECTOR(31 DOWNTO 0);

            EXE_MEM_M  : OUT STD_LOGIC;
            EXE_MEM_WB : OUT STD_LOGIC;

            EXE_MEM_PC : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);

            EXE_MEM_index      : OUT STD_LOGIC;
            EXE_MEM_readData1  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            EXE_MEM_readData2  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            EXE_MEM_ALU_result : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            EXE_MEM_Rsrc1      : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            EXE_MEM_Rsrc2      : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            EXE_MEM_Rdest      : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            EXE_MEM_Opcode     : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
            EXE_MEM_Off_Imm    : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    END COMPONENT;

    ----------------------------------------------------------
    ----------------------------------------------------------
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
            data_in  : IN STD_LOGIC_VECTOR(Data_width - 1 DOWNTO 0);
            data_out : OUT STD_LOGIC_VECTOR(Data_width - 1 DOWNTO 0)
        );
    END COMPONENT;

    ------------------------------- End Memory Declaration -----------------------------------------------
    ------------------------------- Start Program Counter Declaration -----------------------------------------------

    COMPONENT PC
        GENERIC (
            Address_Bits : INTEGER := 32
        );
        PORT (
            clk        : IN STD_LOGIC;
            reset      : IN STD_LOGIC;
            enable     : IN STD_LOGIC;
            inAddresss : IN STD_LOGIC_VECTOR(Address_Bits - 1 DOWNTO 0);
            outAddress : OUT STD_LOGIC_VECTOR(Address_Bits - 1 DOWNTO 0)
        );
    END COMPONENT;

    ------------------------------- End Program Counter Declaration -----------------------------------------------
BEGIN
    ------------------------------- Start pipeline registers Instantiation -----------------------------------------------
    Fetch_Decode_REG : Fetch_Decode
    PORT MAP(
        clk                 => clk,
        reset               => reset,
        fetched_instruction => fetched_instruction,
        PC                  => PC,
        IF_ID_Write         => IF_ID_Write,
        MemDest             => MemDest,
        IF_ID_Instruction   => IF_ID_Instruction_sig,
        IF_ID_PC            => IF_ID_PC_sig
    );

    ----------------------------------------------------------
    ----------------------------------------------------------

    Decode_Execute_REG : Decode_Execute
    PORT MAP(
        clk              => clk,
        reset            => reset,
        EX               => EX,
        M                => M,
        WB               => WB,
        PC               => IF_ID_PC_sig,
        index            => index,
        readData1        => readData1,
        readData2        => readData2,
        Rsrc1            => Rsrc1,
        Rsrc2            => Rsrc2,
        Rdest            => Rdest,
        Opcode           => Opcode,
        Off_Imm          => Off_Imm,
        ID_EXE_M         => ID_EXE_M_sig,
        ID_EXE_WB        => ID_EXE_WB_sig,
        ID_EXE_PC        => ID_EXE_PC_sig,
        ID_EXE_index     => ID_EXE_index_sig,
        ID_EXE_readData1 => ID_EXE_readData1_sig,
        ID_EXE_readData2 => ID_EXE_readData2_sig,
        ID_EXE_Rsrc1     => ID_EXE_Rsrc1_sig,
        ID_EXE_Rsrc2     => ID_EXE_Rsrc2_sig,
        ID_EXE_Rdest     => ID_EXE_Rdest_sig,
        ID_EXE_Opcode    => ID_EXE_Opcode_sig,
        ID_EXE_Off_Imm   => ID_EXE_Off_Imm_sig
    );

    ----------------------------------------------------------
    ----------------------------------------------------------

    Execute_Memory_REG : Execute_Memory
    PORT MAP(
        clk                => clk,
        reset              => reset,
        M                  => ID_EXE_M_sig,
        WB                 => ID_EXE_WB_sig,
        PC                 => ID_EXE_PC_sig,
        index              => ID_EXE_index_sig,
        readData1          => ID_EXE_readData1_sig,
        readData2          => ID_EXE_readData2_sig,
        ALU_result         => ALU_result,
        Rsrc1              => ID_EXE_Rsrc1_sig,
        Rsrc2              => ID_EXE_Rsrc2_sig,
        Rdest              => ID_EXE_Rdest_sig,
        Opcode             => ID_EXE_Opcode_sig,
        Off_Imm            => ID_EXE_Off_Imm_sig,
        EXE_MEM_M          => EXE_MEM_M_sig,
        EXE_MEM_WB         => EXE_MEM_WB_sig,
        EXE_MEM_PC         => EXE_MEM_PC_sig,
        EXE_MEM_index      => EXE_MEM_index_sig,
        EXE_MEM_readData1  => EXE_MEM_readData1_sig,
        EXE_MEM_readData2  => EXE_MEM_readData2_sig,
        EXE_MEM_ALU_result => EXE_MEM_ALU_result_sig,
        EXE_MEM_Rsrc1      => EXE_MEM_Rsrc1_sig,
        EXE_MEM_Rsrc2      => EXE_MEM_Rsrc2_sig,
        EXE_MEM_Rdest      => EXE_MEM_Rdest_sig,
        EXE_MEM_Opcode     => EXE_MEM_Opcode_sig,
        EXE_MEM_Off_Imm    => EXE_MEM_Off_Imm_sig
    );

    ------------------------------- End pipeline Registers Instantiation -----------------------------------------------
    ------------------------------- Start Registers File Instantiation -----------------------------------------------

    REG_FILE : Register_File
    PORT MAP(
        clk         => clk,
        reset       => reset,
        read_reg1   => read_reg1,
        read_reg2   => read_reg2,
        write_reg1  => write_reg1,
        write_reg2  => write_reg2,
        write_data1 => write_data1,
        write_data2 => write_data2,
        RegWrite1   => RegWrite1,
        RegWrite2   => RegWrite2,
        read_data1  => read_data1,
        read_data2  => read_data2
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
        writeEn  => writeEn,
        address  => address,
        data_in  => data_in,
        data_out => data_out
    );
    ------------------------------- End Memory Instantiation -----------------------------------------------
    ------------------------------- Start Program Counter Instantiation -----------------------------------------------
    PC_REG : PC
    GENERIC MAP(
        Address_Bits => 32
    )
    PORT MAP(
        clk        => clk,
        reset      => reset,
        enable     => enable,
        inAddresss => inAddresss,
        outAddress => outAddress
    );
    ------------------------------- End  Program Counter Instantiation -----------------------------------------------

END ARCHITECTURE;