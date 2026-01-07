LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY freshFilterPart2 IS
    GENERIC(
        gMaxRanges : NATURAL := 4096;
        gAddressWidth : NATURAL := 20
    );
    PORT(
        clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;
        
        romAddress : OUT STD_LOGIC_VECTOR(gAddressWidth - 1 DOWNTO 0);
        romEnable : OUT STD_LOGIC;
        romData : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
        -- ROM Handling
        
        done : OUT STD_LOGIC;
        countValid : OUT STD_LOGIC;
        freshCount: OUT STD_LOGIC_VECTOR(63 DOWNTO 0)
        -- Outputs
    );
END ENTITY freshFilterPart2;

ARCHITECTURE rtl OF freshFilterPart2 IS

    TYPE t_u64_array IS ARRAY(NATURAL RANGE <>) OF UNSIGNED(63 DOWNTO 0);
    SIGNAL rangeLow : t_u64_array(0 to gMaxRanges - 1);
    SIGNAL rangeHigh : t_u64_array(0 to gMaxRanges - 1);
    SIGNAL rangeCount : NATURAL RANGE 0 TO gMaxRanges := 0;
    -- Storage for Ranges
    
    SIGNAL addressRegister : UNSIGNED(gAddressWidth - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL numberRangesInFile : UNSIGNED(63 DOWNTO 0) := (OTHERS => '0');
    SIGNAL rangesRead : UNSIGNED(63 DOWNTO 0) := (OTHERS => '0');
    SIGNAL tempStart : UNSIGNED(63 DOWNTO 0) := (OTHERS => '0');
    -- Tracking for .mem file
    
    SIGNAL xSort : NATURAL RANGE 0 TO gMaxRanges := 0;
    SIGNAL ySort : NATURAL RANGE 0 TO gMaxRanges := 0;
    -- These are used for sorting
    
    SIGNAL mergeID : NATURAL RANGE 0 TO gMaxRanges := 0;
    SIGNAL currentStart : UNSIGNED(63 DOWNTO 0) := (OTHERS => '0');
    SIGNAL currentEnd : UNSIGNED(63 DOWNTO 0) := (OTHERS => '0');
    SIGNAL totalFreshIDs : UNSIGNED(63 DOWNTO 0) := (OTHERS => '0');
    SIGNAL mergeInitialize : STD_LOGIC := '0';
    -- Signals used for merging
    
    SIGNAL finishPulse : STD_LOGIC := '0';
    -- This will pulse when done
    
    TYPE tState IS(
        sReadNR,
        sReadRangeStart,
        sReadRangeEnd,
        sSortInitialize,
        sSortStep,
        sMergeInitialize,
        sMergeStep,
        sFinish
     );
     
     SIGNAL state : tState := sReadNR;
     
     BEGIN
        
        romEnable <= '1';
        romAddress <= STD_LOGIC_VECTOR(addressRegister);
        freshCount <= STD_LOGIC_VECTOR(totalFreshIDs);
        -- Enable reading of .mem file
        
        PROCESS(clk)    
        
            VARIABLE xLow : UNSIGNED(63 DOWNTO 0);
            VARIABLE xHigh : UNSIGNED(63 DOWNTO 0);
            VARIABLE yLow : UNSIGNED(63 DOWNTO 0);
            VARIABLE yHigh : UNSIGNED(63 DOWNTO 0);
            VARIABLE temp : UNSIGNED(63 DOWNTO 0);
            VARIABLE nextLow : UNSIGNED(63 DOWNTO 0);
            VARIABLE nextHigh : UNSIGNED(63 DOWNTO 0);
            VARIABLE segmentLength : UNSIGNED(63 DOWNTO 0);
            
            BEGIN
                
                IF RISING_EDGE(clk) THEN
                    IF rst = '1' THEN
                        state <= sReadNR;
                        addressRegister <= (OTHERS => '0');
                        numberRangesInFile <= (OTHERS => '0');
                        rangesRead <= (OTHERS => '0');
                        rangeCount <= 0;
                        
                        tempStart <= (OTHERS => '0');
                        xSort <= 0;
                        ySort <= 0;
                        mergeID <= 0;
                        currentStart <= (OTHERS => '0');
                        currentEnd <= (OTHERS => '0');
                        totalFreshIDs <= (OTHERS => '0');
                        mergeInitialize <= '0';
                        
                        done <= '0';
                        countValid <= '0';
                        finishPulse <= '0';
                        
                    ELSE
                        countValid <= '0';
                        -- Default per cycle
                        
                        CASE state IS
                            WHEN sReadNR =>
                                done <= '0';
                                finishPulse <= '0';
                                
                                numberRangesInFile <= UNSIGNED(romData);
                                rangesRead <= (OTHERS => '0');
                                rangeCount <= 0;
                                addressRegister <= addressRegister + 1;
                                
                                state <= sReadRangeStart;
                                -- Read the Number of Ranges on first .mem position
                                
                            WHEN sReadRangeStart =>
                                IF rangesRead < numberRangesInFile THEN
                                    tempStart <= UNSIGNED(romData);
                                    addressRegister <= addressRegister + 1;
                                    state <= sreadRangeEnd;
                                    
                                ELSE
                                    state <= sSortInitialize;
                                    
                                END IF;
                                    -- Read the start of a range
                                    
                            WHEN sReadRangeEnd =>
                                IF rangeCount < gMaxRanges THEN
                                    xLow := tempStart;
                                    xHigh := UNSIGNED(romData);
                                    
                                    IF xLow <= xHigh THEN
                                        rangeLow(rangeCount) <= xLow;
                                        rangeHigh(rangeCount) <= xHigh;
                                        
                                    ELSE
                                        rangeLow(rangeCount) <= xHigh;
                                        rangeHigh(rangeCount) <= xLow;
                                        
                                    END IF;
                                    
                                    rangeCount <= rangeCount + 1;
                                    
                                 END IF;
                                 
                                 rangesRead <= rangesRead +1;
                                 addressRegister <= addressRegister + 1;
                                 state <= sReadRangeStart;                                 
                                 -- Read the end of a range, store it
                                 
                             WHEN sSortInitialize =>
                                xSort <= 0;
                                ySort <= 0;
                                state <= sSortStep;
                                -- Starting position for the sort
                                
                             WHEN sSortStep =>
                                IF rangeCount < 1 THEN
                                    state <= sMergeInitialize;
                                    
                                ELSIF xSort < rangeCount - 1 THEN
                                    IF ySort < (rangeCount - (xSort - 1)) THEN
                                        xLow := rangeLow(ySort);
                                        xHigh := rangeHigh(ySort);
                                        yLow := rangeLow(ySort + 1);
                                        yHigh := rangeHigh(ySort + 1);
                                        
                                        IF (xLow > yLow) OR ((xLow = yLow) AND (xHigh > yHigh)) THEN
                                            rangeLow(ySort) <= yLow;
                                            rangeHigh(ySort) <= yHigh;
                                            rangeLow(ySort + 1) <= xLow;
                                            rangeHigh(ySort + 1) <= xHigh;
                                        END IF;
                                        -- Swap if they are out of order
                                        
                                        ySort <= ySort + 1;
                                        
                                    ELSE
                                        ySort <= 0;
                                        xSort <= xSort + 1;
                                        
                                    END IF;
                                   
                                ELSE
                                    state <= sMergeInitialize;
                                    
                                END IF;
                                
                            WHEN sMergeInitialize =>
                                totalFreshIDs <= (OTHERS => '0');
                                mergeID <= 0;
                                mergeInitialize <= '0';
                                state <= sMergeStep;
                                -- Get ready to start merging
                                
                            WHEN sMergeStep =>
                                IF mergeID < rangeCount THEN
                                    nextLow := rangeLow(mergeID);
                                    nextHigh := rangeHigh(mergeID);
                                    
                                    IF mergeInitialize = '0' THEN
                                        -- Handle first range
                                        currentStart <= nextLow;
                                        currentEnd <= nextHigh;
                                        mergeInitialize <= '1';
                                        mergeID <= mergeId + 1;
                                        
                                    ELSE
                                        -- Handle unconnected ranges
                                        IF nextLow > (currentEnd + 1) THEN
                                            segmentlength := (currentEnd - currentStart) + 1;
                                            totalFreshIDs <= totalFreshIDs + segmentLength;
                                            
                                            currentStart <= nextLow;
                                            currentEnd <= nextHigh;
                                            mergeID <= MergeID + 1;
                                            
                                        ELSE
                                            IF nextHigh > currentEnd THEN
                                                currentEnd <= nextHigh;
                                                
                                            END IF;
                                            
                                            mergeID <= mergeID + 1;
                                        END IF;
                                    END IF;
                                    
                                ELSE
                                    -- Handle last segment
                                    IF mergeInitialize = '1' THEN
                                        segmentLength := (currentEnd - currentStart) + 1;
                                        totalFreshIDs <= totalFreshIDs + segmentLength;
                                        
                                    END IF;
                                    
                                    state <= sFinish;
                                    
                                END IF;
                                
                            WHEN sFinish =>
                                done <= '1';
                                
                                IF finishPulse = '0' THEN
                                    countValid <= '1';
                                    finishPulse <='1';
                                END IF;
                                
                                state <= sFinish;
                                
                            END CASE;
                        END IF;
                    END IF;
                END PROCESS;
END ARCHITECTURE rtl;