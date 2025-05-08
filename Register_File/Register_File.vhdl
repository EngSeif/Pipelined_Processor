LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.math_real.ALL;

ENTITY Register_File IS
    PORT (
        clk        : IN STD_LOGIC;
        reset      : IN STD_LOGIC;
        read_reg1  : IN STD_LOGIC_VECTOR(2 DOWNTO 0);   -- Address for 1st read port
        read_reg2  : IN STD_LOGIC_VECTOR(2 DOWNTO 0);   -- Address for 2nd read port
        write_reg  : IN STD_LOGIC_VECTOR(2 DOWNTO 0);   -- Address for write port
        write_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);  -- Data to write
        write_en   : IN STD_LOGIC;                      -- Write enable signal
        read_data1 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0); -- Data from 1st read port
        read_data2 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)  -- Data from 2nd read port
    );
END Register_File;

ARCHITECTURE Behavioral OF Register_File IS
    TYPE reg_array IS ARRAY (0 TO 7) OF STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL regs : reg_array := (OTHERS => (OTHERS => '0'));
BEGIN
    PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF reset = '1' THEN
                regs <= (OTHERS => (OTHERS => '0'));
            ELSIF write_en = '1' THEN
                regs(to_integer(unsigned(write_reg))) <= write_data;
            END IF;
        END IF;
    END PROCESS;

    -- Asynchronous read
    read_data1 <= regs(to_integer(unsigned(read_reg1)));
    read_data2 <= regs(to_integer(unsigned(read_reg2)));

END Behavioral;