LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

-- Use same format as python script converion
-- input format is bulk-ROM (1 64-bit hex word per line)
-- 0 = number of ranges (NR)
-- 1 = range0 start
-- 2 = range0 end

-- 2*NR = number of IDs
-- 2*NR + 1 = id0
-- 2*NR + 2 = id1

ENTITY freshFilter IS
    GENERIC(
    gMaxRanges : natural := 4096; -- Max ranges to store (can be edited)
    gAddressWidth : natural := 20 -- ROM depth is 2^(gAddressWidth) words
    );
    
    PORT(
    clk : IN STD_LOGIC;
    rst : IN STD_LOGIC;
    -- Clock and Reset signals
    
    romAddress : OUT STD_LOGIC_VECTOR(gAddressWidth - 1 DOWNTO 0);
    romEnable : OUT STD_LOGIC;
    romData : IN STD_LOGIC_VECTOR(63 DOWNTO 0); -- 64-bit input from ROM (.mem)
    -- Handle the .mem interface (all are input since it should be read-only)
    
    freshValid : OUT STD_LOGIC; -- This will pulse when an ID is fresh
    freshID : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
    done : OUT STD_LOGIC; -- Will be high when finished reading
    countValid : OUT STD_LOGIC; -- Pulse when completed
    freshCount : OUT STD_LOGIC_VECTOR(63 DOWNTO 0)
    );
    
END ENTITY freshFilter;

ARCHITECTURE rtl OF freshFilter IS
    TYPE T_U64_ARRAY is ARRAY(NATURAL RANGE <>) OF UNSIGNED(63 DOWNTO 0); -- Unisgned 64-bit array
    SIGNAL rangeLow : T_U64_ARRAY(0 TO gMaxRanges - 1);
    SIGNAL rangeHigh : T_U64_ARRAY(0 TO gMaxRanges - 1);
    
    SIGNAL rangeCount : NATURAL RANGE 0 TO gMaxRanges := 0;
    -- Store ranges on the chip
    
    SIGNAL addressRegister : UNSIGNED(gAddressWidth - 1 DOWNTO 0) := (OTHERS => '0');
    -- ROM address pointer
    
    SIGNAL numberRangesInFile : UNSIGNED(63 DOWNTO 0) := (OTHERS => '0');
    SIGNAL numberIndexesInFile : UNSIGNED(63 DOWNTO 0) := (OTHERS => '0');
    
    SIGNAL rangesRead : UNSIGNED(63 DOWNTO 0) := (OTHERS => '0');
    SIGNAL idsRead : UNSIGNED(63 DOWNTO 0) := (OTHERS => '0');
    -- Numbers from the file stored on these signals
    
    SIGNAL currentID : UNSIGNED(63 DOWNTO 0) := (OTHERS => '0');
    SIGNAL id : NATURAL RANGE 0 TO gMaxRanges := 0;
    SIGNAL found : STD_LOGIC := '0';
    -- Current ID checking
    
    SIGNAL countRegister : UNSIGNED(63 DOWNTO 0) := (OTHERS => '0');
    -- Final count
    
    SIGNAL tempStart : UNSIGNED(63 DOWNTO 0) := (OTHERS => '0');
    -- Storing range until the end is read
    
    SIGNAL finishPulse : STD_LOGIC := '0';
    -- Ensures countValid only pulses once
    
    TYPE tSTATE IS (
    sReadNR,
    sReadRangeStart,
    sReadRangeEnd,
    sReadNI,
    sReadID,
    sScan,
    sFinish
    );
    
    SIGNAL state : tState := sReadNR;
    
    BEGIN
    
    romEnable <= '1';
    -- ROM is always enabled
    romAddress <= STD_LOGIC_VECTOR(addressRegister);
    -- Address from the register
    
    freshID <= STD_LOGIC_VECTOR(currentID);
    freshCount <= STD_LOGIC_VECTOR(countRegister);
    
    PROCESS(clk)
        VARIABLE lowV : UNSIGNED(63 DOWNTO 0);
        VARIABLE highV : UNSIGNED(63 DOWNTO 0);
        VARIABLE s : UNSIGNED(63 DOWNTO 0);
        VARIABLE e : UNSIGNED(63 DOWNTO 0);
        
    BEGIN
        IF RISING_EDGE(clk) then
            IF rst = '1' then  
                state <= sReadNR;
                
                addressRegister <= (OTHERS => '0');
                rangeCount <= 0;
                
                numberRangesInFile <= (OTHERS => '0');
                numberIndexesInFile <= (OTHERS => '0');
                
                rangesRead <= (OTHERS => '0');
                idsRead <= (OTHERS => '0');
                
                currentID <= (OTHERS => '0');
                id <= 0;
                found <= '0';
                
                countRegister <= (OTHERS => '0');
                
                freshValid <= '0';
                countValid <= '0';
                done <= '0';
                
                finishPulse <= '0';
                
           ELSE
                freshValid <= '0';
                countValid <= '0';
                -- Default pulse is low
                
                CASE state IS
                    WHEN sReadNR =>
                        done <= '0';
                        numberRangesInFile <= UNSIGNED(romData);
                        rangesRead <= (OTHERS => '0');
                        rangeCount <= 0;
                        addressRegister <= addressRegister + 1;
                        state <= sReadRangeStart;
                        -- 0 = NR
                    
                    WHEN sReadRangeStart =>
                        IF rangesRead < numberRangesInFile THEN
                            tempStart <= UNSIGNED(romData);
                            addressRegister <= addressRegister + 1;
                            state <= sReadRangeEnd;
                        -- Read start of the next range
                        ELSE
                            state <= sReadNI;
                            -- Next work id NI
                        END IF;
                        
                    WHEN sReadRangeEnd =>
                        IF rangeCount < gMaxRanges THEN
                            s := tempStart;
                            e := UNSIGNED(romData);
                            
                            IF s <= e THEN
                                rangeLow(rangeCount) <= s;
                                rangeHigh(rangeCount) <= e;
                            ELSE
                                rangeLow(rangeCount) <= e;
                                rangeHigh(rangeCount) <= s;
                            END IF;
                            
                            rangeCount <= rangeCount + 1;
                            -- Increment counter
                         END IF;
                         
                         rangesRead <= rangesRead + 1;
                         addressRegister <= addressRegister +1;
                         state <= sReadRangeStart;
                         -- This process reads the end of the range then stores it
                         
                    WHEN sReadNI =>
                        numberIndexesInFile <= UNSIGNED(romData);
                        idsRead <= (OTHERS => '0');
                        addressRegister <= addressRegister + 1;
                        state <= sReadID;
                    -- Read the Number of Indexes
                    
                    WHEN sReadID =>
                        IF idsRead < numberIndexesInFile THEN
                            currentID <= UNSIGNED(romData);
                            id <= 0;
                            found <= '0';
                            addressRegister <= addressRegister +1;
                            state <= sScan;
                        ELSE
                            state <= sFinish;
                        END IF;
                    -- Read one ID then scan
                    
                    WHEN sScan =>
                        IF id < rangeCount THEN
                            lowV := rangeLow(id);
                            highV := rangeHigh(id);
                            
                            IF(currentID >= lowV) AND (currentID <= highV) THEN
                                found <= '1';
                            END IF;
                            
                            id <= id + 1;
                            -- Scan one range per one cycle
                        ELSE
                            IF found = '1' THEN
                                freshValid <= '1';
                                countRegister <= countRegister + 1;
                            END IF;
                            -- When finished checking current ID
                            
                            idsRead <= idsRead + 1;
                            state <= sReadId;
                        END IF;
                        
                        WHEN sFinish =>
                            done <= '1';
                            
                            IF finishPulse = '0' THEN
                                countValid <= '1'; -- For one pulse
                                finishPulse <= '1';
                            ELSE
                                countValid <= '0';
                            END IF;
                            
                            state <= sFinish;
           END CASE;
        END IF;
     END IF;
  END PROCESS;
END ARCHITECTURE rtl;