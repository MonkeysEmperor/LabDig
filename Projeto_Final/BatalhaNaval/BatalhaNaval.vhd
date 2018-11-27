library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use ieee.std_logic_unsigned.alL;

entity BatalhaNaval is
	generic(	constant ratio 		: integer := 434; --Baud rate
				constant log2_ratio 	: integer := 9);
	port(	clock, reset, jogar, vez														: in  std_logic;
			entrada_serial_terminal, entrada_serial_adversario 					: in  std_logic;
			saida_serial_terminal, saida_serial_adversario							: out  std_logic;
			jogada_1, jogada_0, resultado, placar_jogador, placar_adversario 	: out std_logic_vector(6 downto 0);
			fazer_jogada, pronto		 														: out std_logic);
end BatalhaNaval;

architecture batalha_naval_arc of BatalhaNaval is 

	component recebe_jogada_UART is
	generic(	constant N_ascii  : integer := 2;     -- Numero de characteres desejados
				constant log2_N	: integer := 2;
				constant Ratio	: integer := 434;
				constant log2_Ratio : integer := 9);
		port(
			clock, reset, enable:     in std_logic;
			entrada_serial:   		  in std_logic;
			erro:             		  out std_logic;
			pronto:					  out std_logic;
			endereco:					  out std_logic_vector(5 downto 0);
			jogada:         out std_logic_vector (13 downto 0)
	);
	end component;
	
	component operacoes_campo is
		generic( constant ratio 		: integer;
					constant log2_ratio 	: integer);
		 port(clock, reset, iniciar	: in  std_logic;
				operacao, dado         	: in  std_logic_vector(1 downto 0);
				endereco                : in  std_logic_vector(5 downto 0);
				saida_serial, pronto    : out std_logic;
				o_dado						: out std_logic_vector(1 downto 0);									
				
				-- depuracao
				db_saida_serial                           : out std_logic;
				db_reseta, db_partida, db_zera, db_conta	: out std_logic;
				db_carrega, db_pronto, db_we, db_fim  		: out std_logic;
				db_q                                      : out std_logic_vector(5 downto 0);
				db_sel                                    : out std_logic_vector(1 downto 0);
				db_dados                                  : out std_logic_vector(6 downto 0));
	end component;
	
	component decodificadorjogada is
		port(	vez, passa_vez, venceu 	: in  std_logic;
				resultado_jogada 			: in  std_logic_vector(1 downto 0);
				mensagem 					: out std_logic_vector(2 downto 0));
	end component;

	component rx_serial is
		generic(	constant Ratio_m : integer;
					constant Ratio_n : integer);
		port(	clock, reset                                 : in  std_logic;
				entrada_serial, recebe_dado, paridade      	: in  std_logic;
				hex1, hex0, hex_est, hex_cont, hex_ticker   	: out std_logic_vector(6 downto 0);
				tem_dado_recebido, paridade_ok, o_tick      	: out std_logic;
				o_serial, O_FIM                             	: out std_logic;
				o_estado                                    	: out std_logic_vector(3 downto 0);
				o_dados                                     	: out std_logic_vector(9 downto 0);
				o_dado_recebido                             	: out std_logic_vector(6 downto 0));
	end component;
	
	component decoder is
		port(	input  : in  std_logic_vector(6 downto 0);
				output : out std_logic_vector(1 downto 0));
	end component;
	
	component envia_mensagem is
		generic(	constant ratio 		: integer;
					constant log2_ratio 	: integer);
		port(	clock, reset, start	: in  std_logic;
				mensagem_sel			: in std_logic_vector (2 downto 0);
				jogada					: in std_logic_vector (13 downto 0);
				serial, o_pronto		: out std_logic;
				db_pronto, db_transm	: out std_logic;
				db_end 					: out std_logic_vector(2 downto 0);
				db_tick					: out std_logic;
				db_ascii					: out std_logic_vector(6 downto 0));
	end component;
	
	signal s_entrada_serial, s_vez, s_enable_recjog, s_erro_recjog, s_pronto_recjog	: std_logic;
	signal s_enable_jogador, s_saida_serial_jogador, s_pronto_jogador, s_passa_vez 	: std_logic;
	signal s_venceu, s_enable_RecMen, s_pronto_men, s_erro_recmem1, s_erro_recmem 	: std_logic;
	signal s_enable_adversario, s_saida_serial_adversario, s_pronto_adversario			: std_logic;
	signal s_enable_envia_mensagem_adversario, s_pronto_envia_mensagem_adversario		: std_logic;
	signal s_serial_envia_mensagem_adversario 													: std_logic;
	
	signal s_jogada									: std_logic_vector(13 downto 0);
	signal s_MenRec			 						: std_logic_vector( 6 downto 0);
	signal s_endereco_rec		 					: std_logic_vector( 5 downto 0);
	signal s_mensagem									: std_logic_vector( 2 downto 0);
	signal s_operacao_jogador, s_dado_jogador : std_logic_vector( 1 downto 0);
	signal s_dado_rec, s_operacao_adversario 	: std_logic_vector( 1 downto 0);
begin

	with s_vez select
		s_entrada_serial <= 	entrada_serial_terminal 	when '0',
									entrada_serial_adversario 	when '1';
						
	RecebeJ : recebe_jogada_UART
		generic map(2,2,ratio,log2_ratio)
		port map(clock, reset, s_enable_recjog,
					s_entrada_serial,
					s_erro_recjog,
					s_pronto_recjog,
					s_endereco_rec,
					s_jogada);
			
	JOGADOR : operacoes_campo
		generic map(ratio,log2_ratio)
		port map(clock, reset, s_enable_jogador,
					s_operacao_jogador, "00",
					s_endereco_rec,
					s_saida_serial_jogador, s_pronto_jogador,
					s_dado_jogador,
					
					-- depuracao
					open,
					open, open, open, open,
					open, open, open, open,
					open,
					open,
					open);
	
	DecJogadaJogador : decodificadorjogada
		port map(s_vez, s_passa_vez, s_venceu,
					s_dado_jogador,
					s_mensagem);
					
	RecMensage : rx_serial
		generic map(Ratio,log2_Ratio)
		port map(clock, reset,
					s_entrada_serial, s_enable_RecMen, '0',
					open, open, open, open, open,
					s_pronto_men, s_erro_recmem1, open,
					open, open,
					open,
					open,
					s_MenRec);
					
	s_erro_recmem <= s_erro_recmem1;
	
	MenDec : decoder
		port map(s_MenRec, s_dado_rec);
		
	ADVERSARIO : operacoes_campo
		generic map(ratio,log2_ratio)
		port map(clock, reset, s_enable_adversario,
					s_operacao_adversario, s_dado_rec,
					s_endereco_rec,
					s_saida_serial_adversario, s_pronto_adversario,
					open,									
					
					-- depuracao
					open,
					open, open, open, open,
					open, open, open, open,
					open,
					open,
					open);
	
	envia_mensagem_adversario : envia_mensagem
		generic map(ratio,log2_ratio)
		port map(clock, reset, s_enable_envia_mensagem_adversario,
					s_mensagem,
					s_jogada,
					s_serial_envia_mensagem_adversario, s_pronto_envia_mensagem_adversario,
					open, open,
					open,
					open,
					open);
					
end batalha_naval_arc;