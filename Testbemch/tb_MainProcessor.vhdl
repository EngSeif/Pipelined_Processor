LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY tb_MainProcessor IS
END ENTITY;

ARCHITECTURE sim OF tb_MainProcessor IS

    COMPONENT MainProcessor
        PORT (
            clk            : IN STD_LOGIC;
            reset          : IN STD_LOGIC;
            enable_test    : IN STD_LOGIC;
            interrupt_port : IN STD_LOGIC;
            in_port        : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            out_Port       : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    END COMPONENT;

    SIGNAL clk            : STD_LOGIC := '0';
    SIGNAL reset          : STD_LOGIC := '1';
    SIGNAL enable_test    : STD_LOGIC := '0';
    SIGNAL interrupt_port : STD_LOGIC := '0';
    SIGNAL in_port        : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL out_port       : STD_LOGIC_VECTOR(31 DOWNTO 0);

BEGIN

    -- Clock generation
    clk_process : PROCESS
    BEGIN
        WHILE TRUE LOOP
            clk <= '0'; WAIT FOR 10 ns;
            clk <= '1'; WAIT FOR 10 ns;
        END LOOP;
    END PROCESS;

    -- Unit under test
    DUT: MainProcessor
        PORT MAP (
            clk            => clk,
            reset          => reset,
            enable_test    => enable_test,
            interrupt_port => interrupt_port,
            in_port        => in_port,
            out_Port       => out_port
        );

    -- Stimuli
    stim_proc: PROCESS
    BEGIN
        -- Hold reset
        WAIT FOR 50 ns;
        reset <= '0';

        -- Start execution
        enable_test <= '1';

        -- Insert optional interrupts or I/O input if desired
        -- in_port <= x"0000000A";

        -- Wait to observe behavior
        WAIT FOR 1000 ns;

        -- Stop simulation
        ASSERT FALSE REPORT "Simulation finished." SEVERITY FAILURE;
    END PROCESS;

END ARCHITECTURE;
