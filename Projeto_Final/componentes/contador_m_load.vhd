-- contador_m_load.vhd
-- baseado no componente v74x163.vhd
-- retirado do livro: Wakerly, Digital design: principles and practices 4e - page 722

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use ieee.std_logic_unsigned.alL;

entity contador_m_load is
		generic (
				constant M: integer := 50;  -- modulo do contador
				constant N: integer := 6    -- numero de bits da saida
		);
		port (
				CLK, zera, conta, carrega: in STD_LOGIC;
				D: in STD_LOGIC_VECTOR (N-1 downto 0);
				Q: out STD_LOGIC_VECTOR (N-1 downto 0);
				fim: out STD_LOGIC
		);
end contador_m_load;

architecture contador_m_load_arch of contador_m_load is
	signal IQ: UNSIGNED (N-1 downto 0);
begin
	
	process (CLK,zera,conta,IQ)
	begin
		if zera='1' then IQ <= (others => '0');   
		elsif CLK'event and CLK='1' then
			if carrega='1' then
				IQ <= unsigned(D);
			elsif conta='1' then 
				if IQ=M-1 then IQ <= (others => '0'); else IQ <= IQ + 1; end if;
			end if;
		end if;
		
		if IQ=M-1 then fim <= '1'; else fim <= '0'; end if;
		Q <= CONV_STD_LOGIC_VECTOR(IQ,N); 
				
	end process;
end contador_m_load_arch;