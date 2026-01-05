LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY STD;
USE STD.TEXTIO.ALL;

ENTITY tb_freshFilter IS
END ENTITY tb_freshFilter;

ARCHITECTURE sim OF tb_freshFilter IS
    CONSTANT cAddressWidth : NATURAL := 20;
    CONSTANT cROMDepth : NATURAL := 2**cAddressWidth;
    
    SIGNAL clk : STD_LOGIC := '0';
    SIGNAL rst : STD_LOGIC := '1';
    
    SIGNAL romAddress : STD_LOGIC_VECTOR(cAddressWidth - 1 DOWNTO 0);
    SIGNAL romEnable : STD_LOGIC;
    SIGNAL romData : STD_LOGIC_VECTOR(63 DOWNTO 0);
    
    SIGNAL freshValid : STD_LOGIC;
    SIGNAL freshID : STD_LOGIC_VECTOR(63 DOWNTO 0);
    
    SIGNAL done : STD_LOGIC;
    SIGNAL countValid : STD_LOGIC;
    SIGNAL freshCount : STD_LOGIC_VECTOR(63 DOWNTO 0);
    
    TYPE tROM IS ARRAY(0 TO cROMDepth - 1) OF STD_LOGIC_VECTOR(63 DOWNTO 0);
    SIGNAL rom : tROM := (OTHERS => (OTHERS => '0'));
    
    CONSTANT memFile : STRING := "day5input.mem"; -- Change this depending on your file input name
    -- This file needs to be in the Sim folder of this project
    
    FUNCTION hexCharacterToInt(c : CHARACTER) RETURN INTEGER IS
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
    END FUNCTION;
    -- Convert hex character to integer value
    
    FUNCTION parseHex64(s : STRING) RETURN STD_LOGIC_VECTOR IS
        VARIABLE result : STD_LOGIC_VECTOR(63 DOWNTO 0) := (OTHERS => '0');
        VARIABLE nibble : INTEGER;
        
        BEGIN
            FOR i IN 0 TO 15 LOOP
                nibble := hexCharacterToInt(s(i + 1));
                result(63 - i*4 DOWNTO 60 - i*4) := STD_LOGIC_VECTOR(TO_UNSIGNED(nibble, 4));
            END LOOP;
            -- This loop expects s(1 to 16)
        RETURN result;
     END FUNCTION;
     -- Parse the 16 hex character string to 64-bit STD Logic Vector
     
     BEGIN
        clk <= NOT clk AFTER 5 ns;
        -- Create clock cycle
        
        romData <= rom(TO_INTEGER(UNSIGNED(romAddress))) WHEN romEnable = '1' ELSE (OTHERS => '0');
        -- Read combinational ROM
        
        dut : ENTITY WORK.freshFilter
        -- DUT is Design Under Test (verify the circuit design code)
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
                freshValid => freshValid,
                freshID => freshID,
                done => done,
                countValid => countValid,
                freshCount => freshCount
                );
     
            loadROM: PROCESS
                FILE f : TEXT OPEN read_mode IS memFile;
                VARIABLE l : LINE;
                VARIABLE word : STRING(1 TO 16);
                VARIABLE address : INTEGER := 0;
                VARIABLE vector : STD_LOGIC_VECTOR(63 DOWNTO 0);
                
            BEGIN
                WHILE NOT ENDFILE(f) LOOP
                    READLINE(f, l);
                    
                    READ(l, word);
                    -- Read the first thing on line (should be 16 hex characters)
                    
                    vector := parseHex64(word);
                    
                    IF address < cROMDepth THEN
                        rom(address) <= vector;
                    END IF;
                    
                    address := address + 1;
                END LOOP;
                
                REPORT "ROM LOADED FROM " & memFile SEVERITY NOTE;
                WAIT;
             END PROCESS;
             
             stim: process
                BEGIN
                    WAIT FOR 30 ns;
                    rst <= '0';
                    
                    WAIT UNTIL done = '1';
                    WAIT FOR 20 ns;
                    
                    REPORT "Done. freshCount (low 32 bits) = " & INTEGER'IMAGE(TO_INTEGER(UNSIGNED(freshCount(31 DOWNTO 0)))) SEVERITY NOTE;
                    
                    WAIT;
             END PROCESS;
             
             monitor: process(clk)
             BEGIN
                IF RISING_EDGE(clk) THEN
                    IF freshValid = '1' THEN
                        REPORT "Fresh ID Found: " & INTEGER'IMAGE(TO_INTEGER(UNSIGNED(freshID(31 DOWNTO 0)))) SEVERITY NOTE;
                    END IF;
                    
                    IF countValid = '1' THEN
                        REPORT "Final count pulse asserted" SEVERITY NOTE;
                    END IF;
                END IF;
              END PROCESS;
              
END ARCHITECTURE;