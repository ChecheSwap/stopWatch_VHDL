library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY ACT3_BASE IS PORT(
	CLK : IN STD_LOGIC;
	XRST : IN STD_LOGIC;
	XSTOP : IN STD_LOGIC;
	XOUTPUT : OUT STD_LOGIC_VECTOR(7 DOWNTO 0):=(OTHERS => '0');
	XPOS : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
	L1 : OUT STD_LOGIC;
	L2 : OUT STD_LOGIC;
	L3 : OUT STD_LOGIC;
	L4 : OUT STD_LOGIC
);
END ACT3_BASE;

	---------------------------------------------------------------------@CHECHESWAP
ARCHITECTURE ACT OF ACT3_BASE IS

	CONSTANT BIN_ZERO : STD_LOGIC_VECTOR(7 DOWNTO 1) := "0000001";
	CONSTANT BIN_ONE : STD_LOGIC_VECTOR(7 DOWNTO 1) := "1001111";
	CONSTANT BIN_TWO : STD_LOGIC_VECTOR(7 DOWNTO 1) := "0010010";
	CONSTANT BIN_THREE : STD_LOGIC_VECTOR(7 DOWNTO 1) := "0000110";
	CONSTANT BIN_FOUR : STD_LOGIC_VECTOR(7 DOWNTO 1) := "1001100";
	CONSTANT BIN_FIVE : STD_LOGIC_VECTOR(7 DOWNTO 1) := "0100100";
	CONSTANT BIN_SIX : STD_LOGIC_VECTOR(7 DOWNTO 1) := "0100000";
	CONSTANT BIN_SEVEN : STD_LOGIC_VECTOR(7 DOWNTO 1) := "0001111";
	CONSTANT BIN_EIGHT : STD_LOGIC_VECTOR(7 DOWNTO 1) := "0000000";
	CONSTANT BIN_NINE : STD_LOGIC_VECTOR(7 DOWNTO 1) := "0001100";	
	CONSTANT BIN_STOP : STD_LOGIC_VECTOR(7 DOWNTO 1) := "0000000";	
	
	SIGNAL OUTPUT : STD_LOGIC_VECTOR(7 DOWNTO 0):=(OTHERS => '0');
	
	CONSTANT MARK_CENTISEG : INTEGER := 10000; --- CLOCK CYCLES TO MIN MARK OF CENTISEGS
	CONSTANT MARK_REFRESH : INTEGER := 5000; 
	
	SIGNAL CENTISEGS : INTEGER RANGE 0 TO 9:=0;
	SIGNAL DECISEGS : INTEGER RANGE 0 TO 9:=0;
	SIGNAL SEGS : INTEGER RANGE 0 TO 9:= 0;
	SIGNAL DECASEGS : INTEGER RANGE 0 TO 9:= 0;
	SIGNAL ANPOS : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0111";
	SIGNAL FLAG : STD_LOGIC := '1';
	SIGNAL NUMBER : INTEGER := 0;
	SIGNAL MYPOS : INTEGER := 0;
	SIGNAL LEDSTATE : STD_LOGIC := '0';
	
	---------------------------------------------------------------------@CHECHESWAP
	
BEGIN

	CLOCK_BASE : PROCESS(CLK, XRST, XSTOP) 
		VARIABLE CC : INTEGER := 0;
	BEGIN		
		
		IF XRST = '0' THEN
				CC := 0;
				CENTISEGS <= 0;
				DECISEGS <=0;
				SEGS <= 0;
				DECASEGS <= 0;
		ELSIF XSTOP = '0' THEN
			NULL;
		ELSIF CLK'EVENT AND CLK = '1' THEN
			IF CC = MARK_CENTISEG THEN
				
				IF CENTISEGS = 9 THEN
																
					IF DECISEGS = 9 THEN					
						DECISEGS <= 0;
						
						IF SEGS = 9 THEN
							SEGS <= 0;
							
							IF DECASEGS = 9 THEN 
								DECASEGS <= 0;
							ELSE
								DECASEGS <= 1 + DECASEGS;
							END IF;
						ELSE
							SEGS <= 1 + SEGS;
						END IF;
					ELSE
						DECISEGS <= 1 + DECISEGS;					
					END IF;
					
					CENTISEGS <= 0;
					
				ELSE
					CENTISEGS <= 1 + CENTISEGS;
				END IF;					
				
				CC := 0;
				
			ELSE			
				CC := CC + 1;			
			END IF;
		END IF;
			
	END PROCESS;

	---------------------------------------------------------------------@CHECHESWAP
	LCD_REFRESH : PROCESS(CLK) 
		VARIABLE CC : INTEGER := 0;
	BEGIN
	
		IF CLK'EVENT AND CLK = '1' THEN
		
			IF CC >= MARK_REFRESH THEN
				IF MYPOS = 3 THEN
					MYPOS <= 0;
				ELSE
					MYPOS <= 1 + MYPOS;
				END IF;
				
				CC := 0;
			ELSE
				CC := CC + 1;
			END IF;
		
		END IF;
		
	END PROCESS;
	---------------------------------------------------------------------@CHECHESWAP
	LCD_DIGIT : PROCESS(MYPOS) BEGIN
	
		CASE MYPOS IS
		 WHEN 0 => ANPOS <= "0111"; FLAG <= '0'; NUMBER <= CENTISEGS; 
		 WHEN 1 => ANPOS <= "1011"; FLAG <= '0'; NUMBER <= DECISEGS; 
		 WHEN 2 => ANPOS <= "1101"; FLAG <= '1'; NUMBER <= SEGS; 
		 WHEN 3 => ANPOS <= "1110"; FLAG <= '0'; NUMBER <= DECASEGS; 
		 WHEN OTHERS => ANPOS <= "0111"; FLAG <= '0'; NUMBER <= CENTISEGS; 
		END CASE;
	
	END PROCESS;
	---------------------------------------------------------------------@CHECHESWAP
	LCD_PRINT: PROCESS(NUMBER) BEGIN
		
		IF FLAG = '1' THEN
		
			CASE NUMBER IS
				WHEN 1 => OUTPUT <= BIN_ONE & '0';
				WHEN 2 => OUTPUT <= BIN_TWO & '0';
				WHEN 3 => OUTPUT <= BIN_THREE & '0';
				WHEN 4 => OUTPUT <= BIN_FOUR & '0';
				WHEN 5 => OUTPUT <= BIN_FIVE & '0';
				WHEN 6 => OUTPUT <= BIN_SIX & '0';
				WHEN 7 => OUTPUT <= BIN_SEVEN & '0';
				WHEN 8 => OUTPUT <= BIN_EIGHT & '0';
				WHEN 9 => OUTPUT <= BIN_NINE & '0';
				WHEN 0 => OUTPUT <= BIN_ZERO & '0';
				WHEN OTHERS => OUTPUT <= BIN_ZERO & '0';			
			END CASE;
		
		ELSE
		
			CASE NUMBER IS
				WHEN 1 => OUTPUT <= BIN_ONE & '1';
				WHEN 2 => OUTPUT <= BIN_TWO & '1';
				WHEN 3 => OUTPUT <= BIN_THREE & '1';
				WHEN 4 => OUTPUT <= BIN_FOUR & '1';
				WHEN 5 => OUTPUT <= BIN_FIVE & '1';
				WHEN 6 => OUTPUT <= BIN_SIX & '1';
				WHEN 7 => OUTPUT <= BIN_SEVEN & '1';
				WHEN 8 => OUTPUT <= BIN_EIGHT & '1';
				WHEN 9 => OUTPUT <= BIN_NINE & '1';
				WHEN 0 => OUTPUT <= BIN_ZERO & '1';
				WHEN OTHERS => OUTPUT <= BIN_ZERO & '1';			
			END CASE;
			
		END IF;
		
	END PROCESS;
	
	
	XPOS <= ANPOS;
	XOUTPUT <= OUTPUT;
	L1 <= LEDSTATE;
	L2 <= NOT LEDSTATE;
	L3 <= LEDSTATE;
	L4 <= NOT LEDSTATE;
	
	
	LED_CONTROLS : PROCESS (CLK) 
		VARIABLE CC : INTEGER := 0;
	BEGIN
		IF CLK'EVENT AND CLK = '1' THEN
			IF CC = MARK_CENTISEG * 6 THEN
				
				CC := 0;
				LEDSTATE <= NOT LEDSTATE;
				
			ELSE
			
				CC := CC+1;
			
			END IF;
		END IF;
	END PROCESS;
	
	---------------------------------------------------------------------@CHECHESWAP
	
END ACT;

	---------------------------------------------------------------------@CHECHESWAP
