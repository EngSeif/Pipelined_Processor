LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY Stack_Ptr IS
    GENERIC (
        Address_Bits : INTEGER := 12
    );
    PORT (
        clk      : IN STD_LOGIC;
        reset    : IN STD_LOGIC;
        enable   : IN STD_LOGIC; -- enable update
        push_Pop : IN STD_LOGIC; -- if '1': SP--; if '0': SP++
        sp_value : OUT STD_LOGIC_VECTOR(Address_Bits - 1 DOWNTO 0)
    );
END ENTITY Stack_Ptr;

ARCHITECTURE rtl OF Stack_Ptr IS
    SIGNAL sp_reg : STD_LOGIC_VECTOR(Address_Bits - 1 DOWNTO 0) := (OTHERS => '0');
BEGIN
    PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF reset = '1' THEN
                sp_reg <= STD_LOGIC_VECTOR(to_unsigned(2 ** 12 - 1, Address_Bits)); -- initial value: 0xFFF
            ELSIF enable = '1' THEN
                IF push_Pop = '1' THEN
                    sp_reg <= STD_LOGIC_VECTOR(unsigned(sp_reg) - 1);
                ELSE-- else it is pop so increment stack pointer
                    IF unsigned(sp_reg) < to_unsigned(2 ** Address_Bits - 1, Address_Bits) THEN

                        sp_reg <= STD_LOGIC_VECTOR(unsigned(sp_reg) + 1);

                    END IF;
                END IF;
            END IF;
        END IF;
    END PROCESS;

    sp_value <= sp_reg;

END ARCHITECTURE;