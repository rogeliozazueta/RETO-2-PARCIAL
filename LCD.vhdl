library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity lcd is
    port ( 
    clk : in  std_logic; --Reloj para el lcd
    reset : in  std_logic;  --Alto para iniciar el lcd
    rs: in  std_logic;    --seleccion de registro 
    rwdata : in  std_logic; --Selector de senal de escritura o lectura
    data : in std_logic_vector (7 downto 0);  --Instrucciones que se envian al lcd
	
	
 --LINEAS DE CONTROL DEL LCD
    rs2 : out  std_logic; --seleccion del registro 
    rw : out std_logic;   -- 0(Escritura)/1(Lectura)
    en : out  std_logic;  -- senal enable
    lcd_data  : out std_logic_vector (7 downto 0)); --data al lcd



end lcd;

architecture arch of lcd is
	

	type state is(idle,start); --MAQUINA MEALY
	signal  present: state; --ESTADO PRESENTE
	

	begin
	

	  process(clk)
	  begin 
	

	  if rising_edge(clk)  then
	

	  if(reset = '1') then --SI EL RESET ACTIVADO TODO EN 0
	  rs2 <= '0';
	  rw <= '0';
	  en <= '0'; 
	  lcd_data <= "00000000";
	  present <= idle;
	  else   --DECLARACION DE LOS ESTADOS 
	  case present is
	  when idle=>
	    if (rwdata = '1') then  --ESTADO DE ESPERA O INICIANILIZACION
	    present <=start;
	    else
	    rs2 <= '0';
	    rw <= '0';
	    en <= '0'; 
	    lcd_data <= "00000000";
	    present <=idle; -- ESTADO DE ESPERA
	    end if; 
	                    
	    when start=> --ESTADO DE ESCRITURA
	      if  (rwdata = '1') then  -- RWDATA 1  SALIDAS<=ENTRADAS
	      rs2 <= rs;
	      rw <= rwdata;
	      en <= '1'; 
	      lcd_data <= data;
	       else 
	        present <= idle;
	        end if;
	      when others => null;  --NEGACION DE LOS OTROS CASOS
	       end case;
	       end if;
	        end if;
	    end process; 
	

	end arch;
