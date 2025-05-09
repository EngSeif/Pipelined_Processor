-- LIBRARY ieee;
-- USE ieee.std_logic_1164.ALL;
-- USE ieee.numeric_std.ALL;

-- ENTITY memory IS
--     GENERIC (
--         Address_bits : INTEGER := 12;
--         Data_width   : INTEGER := 32
--     );
--     PORT (
--         clk       : IN STD_LOGIC;
--         reset     : IN STD_LOGIC;
--         writeEn   : IN STD_LOGIC;
--         inAddress : IN STD_LOGIC_VECTOR(Address_bits - 1 DOWNTO 0);
--         dataIn    : IN STD_LOGIC_VECTOR(Data_width - 1 DOWNTO 0);
--         dataOut   : OUT STD_LOGIC_VECTOR(Data_width - 1 DOWNTO 0)
--     );
-- END ENTITY memory;

-- ARCHITECTURE rtl OF memory IS
--     TYPE memType IS ARRAY ((2 ** Address_bits) - 1 DOWNTO 0) OF STD_LOGIC_VECTOR(31 DOWNTO 0);
--     SIGNAL myMemory : memType;
-- BEGIN
--     PROCESS (clk, reset)
--     BEGIN
--         IF reset = '1' THEN -- see if syncronous
--             -- Reset all memory locations to '0' on reset
--             FOR loc IN 0 TO (2 ** Address_bits) - 1 LOOP
--                 myMemory(loc) <= (OTHERS => '0');
--             END LOOP;

--         ELSIF rising_edge(clk) THEN
--             -- Write to memory on rising edge if write enable is active
--             IF writeEn = '1' THEN
--                 myMemory(to_integer(unsigned(inAddress))) <= dataIn;
--             END IF;

--         ELSIF falling_edge(clk) THEN
--             -- Read from memory on falling edge
--             dataOut <= myMemory(to_integer(unsigned(inAddress)));
--         END IF;
--     END PROCESS;
-- END ARCHITECTURE;

-- LIBRARY ieee;
-- USE ieee.std_logic_1164.ALL;
-- USE ieee.numeric_std.ALL;

-- ENTITY Memory IS
--     GENERIC (
--         Address_bits : INTEGER := 12;
--         Data_width   : INTEGER := 32
--     );
--     PORT (
--         clk      : IN STD_LOGIC;
--         reset    : IN STD_LOGIC;
--         address  : IN STD_LOGIC_VECTOR(Address_bits - 1 DOWNTO 0);
--         data_in  : IN STD_LOGIC_VECTOR(Data_width - 1 DOWNTO 0);
--         we       : IN STD_LOGIC;-- write enable
--         data_out : OUT STD_LOGIC_VECTOR(Data_width - 1 DOWNTO 0)
--     );
-- END ENTITY;

-- ARCHITECTURE rtl OF Memory IS
--     -- 1MB of 32-bit words = 2^20 locations
--     TYPE memory_array IS ARRAY (0 TO (2 ** Address_bits - 1)) OF STD_LOGIC_VECTOR(31 DOWNTO 0);
--     SIGNAL mem : memory_array;
-- BEGIN

--     PROCESS (clk)
--     BEGIN
--         IF rising_edge(clk) THEN
--             IF reset = '1' THEN
--                 FOR i IN 0 TO 2 ** Address_bits - 1 LOOP
--                     mem(i) <= (OTHERS => '0');
--                 END LOOP;
--                 data_out <= (OTHERS => '0');
--             ELSE
--                 IF we = '1' THEN
--                     mem(to_integer(unsigned(address))) <= data_in;
--                 END IF;
--                 data_out <= mem(to_integer(unsigned(address)));
--             END IF;
--         END IF;
--     END PROCESS;
-- END ARCHITECTURE;

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY Memory IS
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
END ENTITY;

ARCHITECTURE rtl OF Memory IS
    TYPE memory_array IS ARRAY (0 TO (2 ** Address_bits - 1)) OF STD_LOGIC_VECTOR(Data_width - 1 DOWNTO 0);
    SIGNAL mem : memory_array := (OTHERS => (OTHERS => '0'));
BEGIN

    -- Rising edge: write and reset logic
    PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF reset = '1' THEN
                data_out <= (OTHERS => '0');
            ELSE
                data_out <= mem(to_integer(unsigned(address)));
            END IF;
        END IF;
    END PROCESS;

    -- WRITE on FALLING edge
    PROCESS (clk)
    BEGIN
        IF falling_edge(clk) THEN
            IF reset = '1' THEN
                FOR i IN 0 TO (2 ** Address_bits - 1) LOOP
                    mem(i) <= (OTHERS => '0');
                END LOOP;
            ELSIF writeEn = '1' THEN
                mem(to_integer(unsigned(address))) <= data_in;
            END IF;
        END IF;
    END PROCESS;
END ARCHITECTURE;