
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use ieee.std_logic_unsigned.alL;

entity Resultado_Jogada_2_Msg is
	port(	vez, passa_vez, venceu 	: in  std_logic;
			resultado_jogada 			: in  std_logic_vector(1 downto 0);
			mensagem 					: out std_logic_vector(2 downto 0));
end Resultado_Jogada_2_Msg;

architecture Resultado_Jogada_2_Msg_arc of Resultado_Jogada_2_Msg is
	signal s_vez, s_passa_vez, s_resultado : std_logic_vector(2 downto 0);
begin
	with venceu select
		mensagem <=	"110" 			when '1',
						s_passa_vez 	when '0';
	
	with passa_vez select
		s_passa_vez	<=	"010" 	when '1',
							s_vez		when '0';
	
	with vez select
		S_vez <= s_resultado WHEN '0',
					"000"			when '1';
	
	with resultado_jogada select
		s_resultado <=	"101" when "10",
							"111" when "11",
							"100" when others;
						
end Resultado_Jogada_2_Msg_arc;