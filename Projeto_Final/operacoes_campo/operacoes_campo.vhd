-- constantes para operacao
--  IMPRIME := "00"
--  ESCREVE := "01"
-- o_dado := "11"
-- LabDig 2018
--
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;


entity operacoes_campo is
	generic( constant ratio 		: integer := 434;
				constant log2_ratio 	: integer := 9;
				constant tam_ascii : integer := 7;
				constant filename : string := "campo_inicial.mif");
    port(clock, reset, iniciar	: in  std_logic;
			operacao, dado         	: in  std_logic_vector(1 downto 0);
			endereco                : in  std_logic_vector(5 downto 0);
			editavel						: in  std_logic;
			saida_serial, pronto    : out std_logic;
			o_dado						: out std_logic_vector(1 downto 0);
			tamanho_campo : in std_logic;									
			
			-- depuracao
			db_saida_serial                           : out std_logic;
			db_reseta, db_partida, db_zera, db_conta	: out std_logic;
			db_carrega, db_pronto, db_we, db_fim  		: out std_logic;
			db_q                                      : out std_logic_vector(5 downto 0);
			db_sel                                    : out std_logic_vector(1 downto 0);
			db_dados                                  : out std_logic_vector(tam_ascii-1 downto 0));
end operacoes_campo;

architecture operacoes_campo of operacoes_campo is
	signal s_saida_serial, s_reset, s_iniciar_0, s_verifica: std_logic;
    signal s_iniciar, s_reseta, s_partida, s_zera, s_conta, s_carrega, s_pronto, s_we, s_fim, s_fim_linha: std_logic;
    signal s_sel: std_logic_vector(1 downto 0);
    -- depuracao
    signal s_q: std_logic_vector(5 downto 0);
     
    component operacoes_campo_uc 
	 port ( 
         clock, reset, iniciar: in std_logic;
         operacao: in std_logic_vector(1 downto 0);
         pronto, fim, fim_linha: in std_logic;
         zera, reseta, conta, carrega, we, partida, pronto_out: out std_logic;
         sel: out std_logic_vector(1 downto 0);
			o_verifica : out std_logic
    );
    end component;

    component operacoes_campo_fd 
	generic( constant ratio 		: integer := 434;
				constant log2_ratio 	: integer := 9;
				constant tam_ascii : integer := 8;
				constant filename : string := "campo_inicial.mif");
    port (
        clock, reset: in std_logic;
        partida : in std_logic;                    	-- tx_serial
        we: in std_logic;                          	-- memoria_jogo_16x7
        conta, zera, carrega: in std_logic;        	-- contador_m_load
        endereco: in std_logic_vector(5 downto 0); 	-- contador_m_load
        dado, sel: in std_logic_vector(1 downto 0);   -- mux3x1_n
        fim, fim_linha: out std_logic;             	-- contador_m_load
        saida_serial, pronto : out std_logic;      	-- tx_serial
        db_q: out std_logic_vector(5 downto 0);
        db_dados: out std_logic_vector(tam_ascii-1 downto 0);
        verifica: out std_logic_vector(1 downto 0);
		  i_verifica : in std_logic;
		  editavel : in std_logic
    );
    end component;
    
    component edge_detector is port (
  i_clk                       : in  std_logic;
  i_rstb                      : in  std_logic;
  i_input                     : in  std_logic;
  o_pulse                     : out std_logic);
    end component;

begin

s_reset <= reset;
s_iniciar_0 <= iniciar;

    -- sinais reset e partida mapeados em botoes ativos em alto
    U1: operacoes_campo_uc port map (clock=>clock, reset=>s_reset, iniciar=> s_iniciar, operacao=>operacao, pronto=>s_pronto, 
                                 fim=>s_fim, fim_linha=>s_fim_linha, zera=>s_zera, reseta=>s_reseta, conta=>s_conta,
                                 carrega=>s_carrega, we=>s_we, partida=>s_partida, pronto_out=>pronto, sel=>s_sel, o_verifica => s_verifica);
    U2: operacoes_campo_fd
	generic map(ratio,log2_ratio,tam_ascii,filename)
	 port map (clock=>clock, reset=>s_reseta, partida=>s_partida , we=>s_we, 
                                 conta=>s_conta, zera=>s_zera, carrega=>s_carrega, endereco=>endereco, dado=>dado, sel=>s_sel, 
                                 fim=>s_fim, fim_linha=>s_fim_linha, 
                                 saida_serial=>s_saida_serial, pronto=>s_pronto, 
                                 db_q=>s_q, db_dados=>db_dados, verifica=> o_dado, i_verifica => S_verifica, 
											editavel => editavel);
    U3: edge_detector port map (clock, '1', s_iniciar_0, s_iniciar);


-- depuracao
db_reseta<= s_reseta;
db_partida<=s_partida;
db_zera<=s_zera;
db_conta<=s_conta;
db_carrega<=s_carrega;
db_pronto<=s_pronto;
db_we<=s_we;
db_fim<=s_fim;
db_q<=s_q;
db_sel <= s_sel;

saida_serial    <= s_saida_serial;
db_saida_serial <= s_saida_serial;

end operacoes_campo;

