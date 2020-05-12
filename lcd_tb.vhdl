LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use ieee.std_logic_textio.all;

library std;
use std.textio.all;

ENTITY tbLCD  IS
END tbLCD ;
 
ARCHITECTURE behavior OF tbLCD IS 
 
    COMPONENT lcd
    PORT(
       clk : in  STD_LOGIC; --Reloj de la maquima
       RESET : in  STD_LOGIC; -- RESET LCD 1
       RS : in  STD_LOGIC; -- REGISTER SELECTOR
       RWDATA : in  STD_LOGIC; -- READ 0 WRITE 1
       DATA : in STD_LOGIC_VECTOR (7 downto 0); -- DATA DEL LCD
   
       RS2 : OUT  STD_LOGIC;  --REGISTER SELECTOR DE LCD SALIDA
       RW : OUT STD_LOGIC;   --RW SALIDA
       EN : OUT  STD_LOGIC;  -- ENABLE
       lcd_DATA  : out STD_LOGIC_VECTOR (7 downto 0)); --DATA AL LCD
    END COMPONENT;

--SENALES INICIALIZADAS EN 0 
   signal CLK : STD_LOGIC := '0';
   signal RESET: STD_LOGIC := '0';
   signal RS : STD_LOGIC := '0';
   signal RWDATA : STD_LOGIC := '0';
   signal DATA: STD_LOGIC_VECTOR (7 downto 0) := "00000000";

   signal RS2 : STD_LOGIC := '0';
   signal RW : STD_LOGIC := '0';
   signal EN : STD_LOGIC := '0';
   signal lcd_DATA : STD_LOGIC_VECTOR (7 downto 0) := "00000000";

   constant CLK_period : time := 50 ns;
   

 
BEGIN
   uut: LCD PORT MAP (CLK,RESET,RS,RWDATA,DATA,RS2,RW,EN,lcd_DATA);

stimulus : process 

      --file fin : TEXT open READ_MODE is "lcdtextoin.txt";
      variable current_read_line : line;
      variable current_read_field1 : string(1 to 5); -- LEE EL PRIMER STRING DEL ARCHIVO 
      variable current_read_field2 : std_logic;  --- LEE LOS NUMERO QUE SE LES ASIGNARAN A NUESTRAS ENTRADAS
      variable current_read_field3 : std_logic_vector(7 downto 0);-- LEE EL DATA QUE ENTRARA 
      variable current_write_line : line; -- VARIABLE DE LECTURA
      file fin : TEXT open READ_MODE is "lcdtextoin.txt"; -- APERTURA DE ARCHIVOS LECTURA/ESCRITURA
      file fout : TEXT open WRITE_MODE is "lcdtextoout.txt"; 
      variable current_line :line; 

      begin 
      readFile : while (not endfile(Fin)) loop  -- LOOP PARA CONTROLAR LA LECTURA ESCRITURA
      readline(fin, current_read_line);
      read(current_read_line, current_read_field1); -- LECTURA DE PRIMER STRING DEL ARCHIVO 
       
      if (current_read_field1(1 to 5) = string'("-----")) then  -- LEE LA DIVISION DE LOS COMANDOS QUE SE VAN METIENDO Y ASIGNA UNA PAUSA 
      wait for 200 ns;

      if (RS2 = '0')  and (EN = '1') then --ENABLE 1  Y SELECTOR DE REGISTRO 0 INSTRUCCION
      write(current_line, string'("instr(")); --FORMATO DE TXT
      write(current_line, to_integer(signed(lcd_DATA))); -- CONVIERTE EL VALOR BINARIO A ENTERO PARA EL SCRIPT POR ESO EL UNSIGNED
      write(current_line, string'(");")); -- FORMATO TXT
      writeline(fout, current_line); -- ESCRITURA LOOP

      elsif (RS2 = '1') and (EN = '1') then --SE INGRESA UN DATO AL LCD -ESRITURA LCD
      write(current_line, string'("data("));--FORMATO DE TXT
      write(current_line, to_integer(signed(lcd_DATA)));-- CONVIERTE EL VALOR BINARIO A ENTERO PARA EL SCRIPT POR ESO EL UNSIGNED LO MANDA ATRAVES DEL LCD
      write(current_line, string'(");"));  --FORMATO DE TXT
      writeline(fout, current_line); --ESCRITURA
	  end if;
	
	  wait for 200 ns;
	   --ASIGNACION DE LOS VALORES DE LECUTRA A NUESTRAS ENTRADAS 
       else 
       if (current_read_field1(1 to 5) = string'("DATAA")) then --BUSCA LA ENTRADA DE DATA
          read(current_read_line, current_read_field3); -- VARIABLE DEL DATA DE 8 BITS

           DATA<= current_read_field3; -- LA ASIGNA A LA ENTRADA

       else 
           read(current_read_line, current_read_field2); --VARIABLE DE 1 BIT DESPUES DEL STRING QUE SON ENTRADAS RESET ,RWDATA,RS

       if (current_read_field1(1 to 5) = string'("RESET")) then  --ASIGNACION A LA VARIABLE RESET
            RESET <= current_read_field2;
       elsif  (current_read_field1(1 to 5) = string'("RWDAT"))  then --ASIGNACION A LA VARIABLE RW
			RWDATA <= current_read_field2;
       elsif  (current_read_field1(1 to 5) = string'("RSELC"))  then --ASIGNACION A LA VARIABLE RSELEC
            RS <= current_read_field2;
        else null;           
        end if;
        end if;
        end if;
		end loop;

      wait;
      end process; 


 CLK_process :process --RELOJ DE LA MAQUINA DE ESTADO PARA EL TB
        begin
             CLK <= '0';
             wait for CLK_period/2;
             CLK <= '1';
             wait for CLK_period/2;
        end process;


END;