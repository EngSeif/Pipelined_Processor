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
        write_reg1  : IN STD_LOGIC_VECTOR(2 DOWNTO 0);   -- Address for 1st write port
        write_reg2  : IN STD_LOGIC_VECTOR(2 DOWNTO 0);   -- Address for 2nd write port
        write_data1 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);  -- Data1 to write
        write_data2 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);  -- Data2 to write
        RegWrite1   : IN STD_LOGIC;                      -- 1st Write enable signal
        RegWrite2   : IN STD_LOGIC;                      -- 2nd Write enable signal
        read_data1 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0); -- Data from 1st read port
        read_data2 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)  -- Data from 2nd read port

    );
END Register_File;

ARCHITECTURE Behavioral OF Register_File IS
    TYPE reg_array IS ARRAY (7 downto 0) OF STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL regs : reg_array := (OTHERS => (OTHERS => '0'));

BEGIN
    PROCESS (clk)
    BEGIN


        if reset = '1' then
            regs <= (others => (others => '0'));

        elsif rising_edge(clk) then --read logic
            read_data1 <= regs(to_integer(unsigned(read_reg1)));
            read_data2 <= regs(to_integer(unsigned(read_reg2)));

        elsif falling_edge(clk) then
            if RegWrite1 = '1' and RegWrite2 = '0' then -- write logic
                regs(to_integer(unsigned(write_reg1))) <= write_data1;


            elsif RegWrite1 = '1' and RegWrite2 = '1' then
                regs(to_integer(unsigned(write_reg1))) <= write_data1;
                regs(to_integer(unsigned(write_reg2))) <= write_data2;

            end if;
            
        end if;

    END PROCESS;

END Behavioral;