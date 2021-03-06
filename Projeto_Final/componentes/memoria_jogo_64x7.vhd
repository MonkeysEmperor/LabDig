-- codigo ADAPTADO do código encontrado no livro 
-- VHDL Descricao e Sintese de Circuitos Digitais
-- Roberto D'Amore, LTC Editora.
--
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY memoria_jogo_64x7 IS
	generic(	constant tam_ascii : integer := 7;
				constant filename : string := "campo_inicial.mif");
   PORT (dado_entrada : IN  STD_LOGIC_VECTOR(tam_ascii-1 DOWNTO 0);
         dado_saida   : OUT STD_LOGIC_VECTOR(tam_ascii-1 DOWNTO 0);
         endereco     : IN  STD_LOGIC_VECTOR(5 DOWNTO 0);         
         we, ce       : IN  STD_LOGIC);
END memoria_jogo_64x7;

ARCHITECTURE ram1 OF memoria_jogo_64x7 IS
  TYPE   arranjo_memoria IS ARRAY(0 TO 63) OF STD_LOGIC_VECTOR(tam_ascii-1 DOWNTO 0);
  SIGNAL memoria : arranjo_memoria;
  attribute ram_init_file: string;
  attribute ram_init_file of memoria: signal is filename;
BEGIN

  PROCESS(we, endereco, ce)
  BEGIN
    IF ce = '0' THEN -- dado armazenado na subida de "we" com "ce=0"
      IF rising_edge(we) THEN  
			memoria(to_integer(unsigned(endereco))) <= dado_entrada;
      END IF;
    END IF;
    dado_saida <= memoria(to_integer(unsigned(endereco)));
  END PROCESS;

  --dado_saida <= memoria(to_integer(unsigned(endereco)));

END ram1;