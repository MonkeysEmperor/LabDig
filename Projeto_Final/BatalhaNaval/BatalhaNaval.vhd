library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;

entity BatalhaNaval is
	generic( constant ratio 		: integer := 7;
				constant log2_ratio 	: integer := 3);
  port (clock, reset : in std_logic;
			entrada_serial : in std_logic;
			saida_serial : out std_logic;
			
			inicia : in std_logic;
			end1, end0 : out std_logic_vector(2 downto 0);
			menRec : out std_logic_vector(6 downto 0));
end BatalhaNaval;

architecture BatalhaNavalArch of BatalhaNaval is

	component BatalhaNaval_fd is
	generic( constant ratio 		: integer;
				constant log2_ratio 	: integer);
		port(	clock, reset : in std_logic;
				entrada_serial : in std_logic;
				
				enableRecJog, enableEnvMen, enableRecMen, enableOpCam : in std_logic;
				
				end1, end0 : out std_logic_vector(2 DOWNTO 0);
				menRec : out std_logic_vector(6 downto 0);
				saida_serial : out std_logic;
				
				prontoRecJog, prontoEnvMen, prontoRecMen, prontoOpCam : out std_logic);
	end component;
	
	signal s_enableRecJog, s_enableRecMen, s_enableEnvMen, s_enableOpCam : std_logic;
	signal s_prontoRecJog, s_prontoEnvMen, s_prontoRecMen, s_prontoOpCam : std_logic;
begin
	FD : BatalhaNaval_fd
		generic map(ratio,log2_ratio)
		port map(clock, reset,
					entrada_serial,
					
					s_enableRecJog, s_enableRecMen, s_enableEnvMen, s_enableOpCam,
					
					end1, end0,
					menRec,
					saida_serial,
					
					s_prontoRecJog, s_prontoEnvMen, s_prontoRecMen, s_prontoOpCam);
end BatalhaNavalArch ; -- BatalhaNavalArch