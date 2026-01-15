LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY STD;
USE STD.TEXTIO.ALL;

ENTITY tb_freshFilterPart2 IS
END ENTITY tb_freshFilterPart2;

ARCHITECTURE sim OF tb_freshFilterPart2 IS

    CONSTANT cAddressWidth : NATURAL := 20;
    CONSTANT cROMDepth : NATURAL := 2**cAddressWidth;
    --.mem file size
    
    SIGNAL clk : STD_LOGIC := '0';
    SIGNAL rst : STD_LOGIC := '1';
    
    SIGNAL romAddress : STD_LOGIC_VECTOR(cAddressWidth - 1 DOWNTO 0);
    SIGNAL romEnable : STD_LOGIC;
    SIGNAL romData : STD_LOGIC_VECTOR(63 DOWNTO 0);
    -- .mem to DUT signals
    
    SIGNAL done : STD_LOGIC;
    SIGNAL countValid : STD_LOGIC;
    SIGNAL freshCount : STD_LOGIC_VECTOR(63 DOWNTO 0);
    -- Outputs
    
    TYPE tROM IS ARRAY(0 TO cROMDepth - 1) OF STD_LOGIC_VECTOR(63 DOWNTO 0);
    SIGNAL ROM : tROM := (OTHERS => (OTHERS => '0'));
    -- Signals to read from .mem file
    
    CONSTANT memFile : STRING := "day5input.mem";
    -- This is what my file is named, you will have to adjust based on conversion / file name
    
    FUNCTION hexCharacterToInteger(c : CHARACTER) RETURN INTEGER IS
        BEGIN
            IF(c >= '0' AND c <= '9') THEN
                RETURN CHARACTER'POS(c) - CHARACTER'POS('0');
            ELSIF(c >= 'A' AND c <= 'F') THEN
                RETURN 10 + CHARACTER'POS(c) - CHARACTER'POS('A');
            ELSIF(c >= 'a' AND c <= 'f') THEN
                RETURN 10 + CHARACTER'POS(c) - CHARACTER'POS('a');
            ELSE
                RETURN 0;
            END IF;
     END FUNCTION hexCharacterToInteger;
     -- Helper function to conver .mem's hex characters to integers
     
     FUNCTION parseHex64( s : STRING) RETURN STD_LOGIC_VECTOR IS
        VARIABLE result : STD_LOGIC_VECTOR(63 DOWNTO 0) := (OTHERS => '0');
        VARIABLE nibble : INTEGER;
        
        BEGIN
            FOR i IN 0 TO 15 LOOP
                nibble := hexCharacterToInteger(s(i + 1));
                result(63 - i * 4 DOWNTO 60 - i * 4) := STD_LOGIC_VECTOR(TO_UNSIGNED(nibble, 4));
            END LOOP;
            
            RETURN result;
      END FUNCTION parseHex64;
      -- Helper function to turn 16 hex characters into 64bit vector
      
      FUNCTION u64ToDecimalString(slv : STD_LOGIC_VECTOR(63 DOWNTO 0)) RETURN STRING IS
        VARIABLE value : UNSIGNED(63 DOWNTO 0) := UNSIGNED(slv);
        VARIABLE temp : UNSIGNED(63 DOWNTO 0);
        VARIABLE digit : INTEGER;
        VARIABLE result : STRING(1 TO 32);
        -- This can hold a 64 bit decimal number
        VARIABLE id : INTEGER := 32;
        
        BEGIN
            IF value = 0 THEN
                RETURN "0";
            END IF;
            -- Handle 0
            
            WHILE value /= 0 LOOP
                temp := value / 10;
                digit := TO_INTEGER(value - (temp * 10));
                result(id) := CHARACTER'VAL(CHARACTER'POS('0') + digit);
                id := id - 1;
                value := temp;
            END LOOP;
            
            RETURN result(id + 1 TO 32);
        END FUNCTION u64ToDecimalString;
      
      BEGIN
        clk <= NOT clk AFTER 5 ns;
        -- Clock (10 ns period)
        
        romData <= rom(TO_INTEGER(UNSIGNED(romAddress))) WHEN romEnable = '1' ELSE (OTHERS => '0');
        -- Read .mem file, specifically the word at the current location of romAddress
        
        dut : ENTITY WORK.freshFilterPart2
            GENERIC MAP(
                gMaxRanges => 4096,
                gAddressWidth => cAddressWidth
            )
            PORT MAP(
                clk => clk,
                rst => rst,
                romAddress => romAddress,
                romEnable => romEnable,
                romData => romData,
                done => done,
                countValid => countValid,
                freshCount => freshCount
            );
            -- Map all signals to design fiel
            
            loadROM : PROCESS
                FILE f : TEXT OPEN read_mode IS memFile;
                VARIABLE l : LINE;
                VARIABLE word : STRING(1 TO 16);
                VARIABLE address : INTEGER := 0;
                VARIABLE vector : STD_LOGIC_VECTOR(63 DOWNTO 0);
                
                BEGIN
                    WHILE NOT ENDFILE(f) LOOP
                        READLINE(f, l);
                        
                        READ(l, word);
                        -- Read first line (16 characters)
                        
                        vector := parseHex64(word);
                        
                        IF address < cROMDepth THEN
                            rom(address) <= vector;
                        END IF;
                        
                        address := address + 1;
                     END LOOP;
                     
                     REPORT "ROM loaded from: " & memFile SEVERITY NOTE;
                     WAIT;
            END PROCESS loadROM;
            -- Load contents from the .mem file
            -- Each new line will hold a 64 bit word in 16 hex characters
            
            stim : PROCESS
                BEGIN
                    WAIT FOR 30 ns;
                    rst <= '0';
                    -- Hold reset
                    
                    WAIT UNTIL done = '1';
                    WAIT FOR 20 ns;
                    -- Wait until DUT completes
                    
                    REPORT "DONE. totalFreshIDs = " & u64ToDecimalString(freshCount) SEVERITY NOTE;
                    -- Print 64 bits, different from previous testbench. All are needed to show final count
                    
                    WAIT;
             END PROCESS stim;
             -- Run until done and print final count
      
END ARCHITECTURE sim;