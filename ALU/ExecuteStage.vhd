LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY ExecuteStage IS
	PORT (
		clk              : IN STD_LOGIC;
		opcode           : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
		Rsrc1_Data_ID_EXE : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		result           : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		CCR              : OUT STD_LOGIC_VECTOR(2 DOWNTO 0) -- Z(0), N(1), C(2)
	);
END ExecuteStage;

ARCHITECTURE Behavioral OF ExecuteStage IS
	SIGNAL alu_result : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL Z, N, C    : STD_LOGIC;
BEGIN

	PROCESS (clk)
	BEGIN
		IF rising_edge(clk) THEN
			CASE opcode IS
					-- (1): SETC (N-Type)
				WHEN "000010" =>
					alu_result <= Rsrc1_Data_ID_EXE; -- No operation result change
					IF alu_result = x"00000000" THEN
						Z <= '1';
					ELSE
						Z <= '0';
					END IF;
					N <= '0';
					C <= '1';

					-- (2): NOT (R-Type)
				WHEN "010000" =>
					alu_result <= NOT Rsrc1_Data_ID_EXE;
					IF alu_result = x"00000000" THEN
						Z <= '1';
					ELSE
						Z <= '0';
					END IF;
					N <= alu_result(31);
					C <= '0'; -- Not affected

					-- (3): INC (R-Type)
				WHEN "010001" => -- INC
					alu_result <= STD_LOGIC_VECTOR(unsigned(Rsrc1_Data_ID_EXE) + 1);
					IF alu_result = x"00000000" THEN
						Z <= '1';
					ELSE
						Z <= '0';
					END IF;
					N <= alu_result(31);
					IF Rsrc1_Data_ID_EXE = x"FFFFFFFF" THEN -- Carry when overflow
						C <= '1';
					ELSE
						C <= '0';
					END IF;

				WHEN OTHERS           =>
					alu_result <= (OTHERS => '0');
					Z          <= '0';
					N          <= '0';
					C          <= '0';
			END CASE;

			result <= alu_result;
			CCR    <= C & N & Z;
		END IF;
	END PROCESS;

END Behavioral;