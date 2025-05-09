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
        readEn   : IN STD_LOGIC;
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
            ELSIF readEn = '1' THEN
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