library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


entity BatalhaNaval_uc is port ( 
							clock, reset, vez, jogar	: in std_logic;
							vitoria_adversario, erro	: in std_logic; 
							prontoC, prontoJ, pronto	: in std_logic;
							ganhei, acertou, prontoM	: in std_logic;
							enableM, enableJog, enableAdv : in std_logic;
							
							operacoes					: out std_logic_vector(2 downto 0);
							o_soma_ponto_adv, troca_vez			: out std_logic;
							
							--depuração
							db_hex_estado					: out std_logic_vector(6 downto 0)
							 );
end BatalhaNaval_uc;

architecture BatalhaNaval_uc_arch of BatalhaNaval_uc is
	type State_type is (	inicia,
								prepara,
								
								-- Estados do jogador										
								espera_jogada,
								envia_jogada,
								espera_confirmacao,
								espera_mensagem,
								atualiza_tabuleiro,
								soma_ponto,
								espera_vez,
								troca_vez_2,
								
								-- Estados do adversário									
								espera_jogada_adv,
								consulta_mapa,
								envia_resultado,
								espera_pronto,
								imprime_tabuleiro_jog,
								imprime_tabuleiro_adv,
								comunica_vez,
								espera_pronto_cv,
								troca_vez_2,
								comunica_vitoria,
								
								-- Estados finais
								venceu,
								perdeu);
	signal Sreg, Snext: State_type;

-- constantes
constant IMPRIME :	std_logic_vector(1 downto 0) := "00";
constant ESCREVE :	std_logic_vector(1 downto 0) := "01";
constant VERIFICA:	std_logic_vector(1 downto 0) := "10";

begin
	process (reset, clock)
	begin
		if reset = '1' then
			Sreg <= inicia;
		elsif clock'event and clock = '1' then
			Sreg <= Snext; 
		end if;
	end process;

	-- proximo estado
	process (iniciar, operacao, pronto, fim, fim_linha, Sreg) 
	begin
		case Sreg is
			-- Estados iniciais
			when inicia => 				if jogar='1' then Snext <= prepara;
												else 					Snext <= inicia;
												end if;
												
			when prepara =>				if vez='1' then 	Snext <= espera_jogada;
												else 					Snext <= espera_resposta;
												end if;
			-- Estados do jogador										
			when espera_jogada =>		if prontoC='1' then	Snext <= envia_jogada;
												else 						Snext <= espera_jogada;
												end if;
												
			when envia_jogada => 		Snext <= espera_confirmacao;
			
			when espera_confirmacao => if prontoJ='1' then 	Snext <= verifica_resposta;
												else 						Snext <= espera_confirmacao;
												end if;
												
			when espera_mensagem =>		if prontoM = '0' then 	Snext <= espera_mensagem;
												else
													if ganhei='1' then 	Snext <= venceu;
													else 						Snext <= atualiza_tabuleiro;
													end if;
												end if;
			
			when atualiza_tabuleiro => if acertou = 1 then	snext <= soma_ponto;
												else						Snext <= espera_vez;
												end if;
												
			when soma_ponto =>			snext <= espera_vez;
			
			when espera_vez => 			if prontoM = '0' then	snext <= espera_vex;
												else							snext <= troca_vez_2;
												end if;
												
			when troca_vez_2 =>			snext <= espera_jogada_adv;
												
			-- Estados do adversário									
			when espera_jogada_adv => 	if prontoJ='1' then 	Snext <= consulta_mapa;
												else 						Snext <= espera_jogada_adv;
												end if;
												
			when consulta_mapa => 		Snext <= envia_resposta;
			
			when envia_resultado => 	Snext <= espera_pronto;
			
			when espera_pronto => 		if prontoJ='1' then 	Snext <= imprime_tabuleiro;
												else 						Snext <= espera_pronto;
												end if;
											
			when imprime_tabuleiro_jog =>	if prontoc = '0' then	snext <= imprime_tabuleiro_jog;
													else							snext <= imprime_tabuleiro_adv;
													end if;
																					
			when imprime_tabuleiro_adv =>	if prontoc = '0' then					snext <= imprime_tabuleiro_adv;
													else							
														if vitoria_adversario='1' then 	Snext <= comunica_derrota;
														else 										Snext <= comunica_vez;
														end if;
													end if;
	
			when comunica_vez =>  		Snext <= espera_pronto_cv;
			
			when espera_pronto_cv		if pronto = '0' then snext <= espera_pronto_cv;
												else						snext <= troca_vez_1;
												end if;
			
			when troca_vez_1 =>			snext <= espera_jogada; 
			
			when comunica_vitoria => 	Snext <= perdeu;
		
			-- Estados finais
			when venceu => 				Snext <= venceu;
			
			when perdeu => 				Snext <= perdeu;
		end case;
	end process;

	-- saidas
	with Sreg select
		zera <= '1' when inicial, '0' when others;
	with Sreg select
		reseta <= '1' when inicial, '0' when others;
	
		with sreg select
			operacoes	<= VERIFICA when consulta_mapa,
								IMPRIME	when imprime_tabuleiro,
								ESCREVE	when others;
								
	with sreg select
		o_soma_ponto_adv <= '1' when soma_ponto, '0' when others;
	
	with sreg select
		enableM <= '1' when espera_mensagem|espera_vez, '0' when others;
		
	with sreg select
		enableJ <= '1' when espera_jogada|espera_jogada_adv, '0' when others;
		
	with sreg select
		troca_vez <= '1' when troca_vez_1|troca_vez_2, '0' when others;
		
	with sreg select 	
		enableJog <= '1' when consulta_mapa|imprime_tabuleiro_jog, '0' when others
		
	with sreg select 
		enableAdv <= '1' when atualiza_tabuleiro|imprime_tabuleiro_adv, '0' when others;
		
end BatalhaNaval_uc_arch;