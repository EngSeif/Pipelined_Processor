library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ForwardingUnit is
    Port (
        clk                      : in  std_logic;
		 
		-- Decode/Execute
		Rsrc1_ID_EX              : in  std_logic_vector(2 downto 0);
		Rsrc2_ID_EX              : in  std_logic_vector(2 downto 0);
		
		-- Execute/Memory
		Rsrc2_EX_MEM             : in  std_logic_vector(2 downto 0);
		Rdest_EX_MEM             : in  std_logic_vector(2 downto 0);
		RegWrite1_SIGNAL_EX_MEM  : in  std_logic;

		-- Memory/WriteBack
		Rdest_MEM_WB             : in  std_logic_vector(2 downto 0);
		RegWrite1_SIGNAL_MEM_WB  : in  std_logic;
 
        Forward_Signal_A         : out std_logic_vector(1 downto 0);
        Forward_Signal_B         : out std_logic_vector(1 downto 0)
    );
end ForwardingUnit;

architecture Behavioral of ForwardingUnit is
    signal frd_sig_a : std_logic_vector(1 downto 0); -- Upper Mux (Rsrc1)
    signal frd_sig_b : std_logic_vector(1 downto 0); -- Lower Mux (Rsrc2)
begin
           -- and (Rsrc2_EX_MEM /= (others => '0')
    process(clk)
    begin
        if rising_edge(clk) then
            if ( RegWrite1_SIGNAL_EX_MEM = '1' and Rdest_EX_MEM = Rsrc1_ID_EX ) then -- ALU to ALU (Rsrc1)
				frd_sig_a <= "10";
			elsif ( RegWrite1_SIGNAL_MEM_WB = '1' and Rdest_MEM_WB = Rsrc1_ID_EX) then -- Memory to ALU (Rsrc1)
				frd_sig_a <= "01";
			end if;

			if ( RegWrite1_SIGNAL_EX_MEM = '1' and Rdest_EX_MEM = Rsrc2_ID_EX ) then -- ALU to ALU (Rsrc2)
				frd_sig_b <= "10";
			elsif ( RegWrite1_SIGNAL_MEM_WB = '1' and Rdest_MEM_WB = Rsrc2_ID_EX) then  -- Memory to ALU (Rsrc2)
				frd_sig_a <= "01";
			end if;

            Forward_Signal_A <= frd_sig_a;
			Forward_Signal_B <= frd_sig_b;
        end if;
    end process;

end Behavioral;