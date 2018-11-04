library ieee;
use ieee.std_logic.all;

entity recebe_jogada_fd is
	port(
		clock, escreve:       in std_logic;
		enable_c:  			  in std_logic;
		reset_c, reset_r:     in std_logic;
		jogada_parcial:       in std_logic_vector (6 downto 0);
		fim_c:                out std_logic;
		jogada:               out std_logic_vector (13 downto 0)
	);
end entity;

architecture recebe_jogada_fd_arch of recebe_jogada_fd is
	signal endereco: std_logic;

	component contador_m is
		generic (
			constant M: integer;  -- m�dulo do contador
			constant N: integer  -- n�mero de bits da sa�da
		);
		 port (
			  CLK, zera, conta: in STD_LOGIC;
			  Q: out STD_LOGIC_VECTOR (N-1 downto 0);
			  fim: out STD_LOGIC
		 );
	end component;
	
	component buffer_jogada is
		port(
			clock, reset:   in std_logic;
			endereco:       in std_logic;
			jogada_parcial: in std_logic_vector (6 downto 0);
			escreve:        in std_logic;
			jogada:         out std_logic_vector (13 downto 0)
		);
	end component;
	
begin
	
	U1: contador_m  generic map (2, 2)
					port map (clock, reset_c, enable_c, endereco, fim_c);
	U2: buffer_jogada port map (clock, reset_r, endereco(0), jogada_parcial, escreve, jogada);

end architecture;
