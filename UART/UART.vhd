library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;

entity UART is
	generic(constant Ratio_m : integer := 100;
			  constant Ratio_n : integer := 7);
	port(e_dado_ascii             : in  std_logic_vector(6 downto 0);
		  transmite_dado           : in  std_logic;
		  transm_andamento, pronto : out std_logic;
		  serial_saida             : out std_logic;
		  
		  o_dado_ascii              : out std_logic_vector(6 downto 0);
		  paridade_ok, tem_dado_rec : out std_logic;
		  recebe_dado               : in  std_logic;
		  serial_entrada            : in  std_logic;
		  
		  clock, reset : in std_logic);
end UART;

Architecture UART_ark of UART is
	signal s_dados: std_logic_vector(9 downto 0);

	component tx_serial
		generic(constant Ratio_m : integer := 100;
				  constant Ratio_n : integer := 7);
				  
		port(clock, reset, partida, paridade : in  std_logic;
			  dados_ascii                     : in  std_logic_vector (6 downto 0);
			  saida_serial, pronto            : out std_logic);
	end component;
	
	component rx_serial
		 generic(constant Ratio_m : integer := 100;
					constant Ratio_n : integer := 7);
					
		 port(clock, reset: in std_logic;
			   entrada_serial, partida                      : in  std_logic;
			   hex1, hex0, hex_est, hex_cont, hex_ticker    : out std_logic_vector(6 downto 0);
			   pronto, paridade_ok, o_tick, o_serial, O_FIM : out std_logic;
			   o_estado                                     : out std_logic_vector(3 downto 0);
			   o_dados                                      : out std_logic_vector(9 downto 0);
			   o_reg1, o_reg2                               : out std_logic_vector(6 downto 0));
	end component;

begin

	TX: tx_serial
	generic map(Ratio_m,Ratio_n)
	port map(clock, reset, transmite_dado, '0',
		      e_dado_ascii,
		      serial_saida, pronto);
	
	RX: rx_serial
	generic map(Ratio_m,Ratio_n)
	port map(clock, reset,
			   Serial_entrada, recebe_dado,
			   open, open, open, open, open,
			   tem_dado_rec, paridade_ok, open, open, open,
			   open,
			   s_dados,
			   open, open);
	
	o_dado_ascii <= s_dados(6 downto 0);

end UART_ark;