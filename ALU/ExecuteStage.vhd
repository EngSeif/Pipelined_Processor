library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ExecuteStage is
    Port (
        clk               : in  std_logic;
		  opcode            : in  std_logic_vector(5  downto 0);
		  Rsrc1_Data_IF_ID  : in  std_logic_vector(31 downto 0);
        result            : out std_logic_vector(31 downto 0);
        CCR               : out std_logic_vector(2  downto 0) -- Z(0), N(1), C(2)
    );
end ExecuteStage;

architecture Behavioral of ExecuteStage is
    signal alu_result : std_logic_vector(31 downto 0);
    signal Z, N, C : std_logic;
begin

    process(clk)
    begin
        if rising_edge(clk) then
            case opcode is
					-- (1): SETC (N-Type)
               when "000010" =>
                  alu_result <= Rsrc1_Data_IF_ID; -- No operation result change
						if alu_result = x"00000000" then
							Z <= '1';
						else
						   Z <= '0';
						end if;
						 N <= '0'; 
						 C <= '1';

					-- (2): NOT (R-Type)
               when "010000" =>
                  alu_result <= not Rsrc1_Data_IF_ID;
					   if alu_result = x"00000000" then
							Z <= '1';
						else
						   Z <= '0';
						end if;
                  N <= alu_result(31);
                  C <= '0'; -- Not affected

					-- (3): INC (R-Type)
               when "010001" =>  -- INC
                  alu_result <= std_logic_vector(unsigned(Rsrc1_Data_IF_ID) + 1);
						if alu_result = x"00000000" then
							Z <= '1';
						else
						   Z <= '0';
						end if;
                  N <= alu_result(31);
						if Rsrc1_Data_IF_ID = x"FFFFFFFF" then -- Carry when overflow
							C <= '1';
						else
						   C <= '0';
						end if;

               when others =>
                   alu_result <= (others => '0');
                   Z <= '0';
						 N <= '0'; 
						 C <= '0';
           end case;

            result <= alu_result;
            CCR <= C & N & Z;
        end if;
    end process;

end Behavioral;