-- Made by Aidan Ruck

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE STD.TEXTIO.ALL;

USE WORK.repeatTwiceFilter.ALL;

ENTITY tb_repeatTwiceFilter IS
END ENTITY tb_repeatTwiceFilter;

ARCHITECTURE sim OF tb_repeatTwiceFilter IS
    PROCEDURE parseInteger(s : IN STRING; VARIABLE i : INOUT INTEGER; VARIABLE v : OUT idT) IS
        VARIABLE accumulate : idT := (OTHERS => '0');
        VARIABLE c : CHARACTER;
        VARIABLE d : INTEGER;
        CONSTANT ten : idT := TO_UNSIGNED(10, 64);
        VARIABLE prod128 : UNSIGNED(127 DOWNTO 0);

        BEGIN
            WHILE(i <= s'RIGHT) LOOP
                c := s(i);
                EXIT WHEN(c >= '0' AND c <= '9');
                i := i + 1;
            END LOOP;
            -- Skip separators like commas or dashes
            
            WHILE(i <= s'RIGHT) LOOP
                c := s(i);
                EXIT WHEN NOT(c >= '0' AND c <= '9');
                d := (CHARACTER'POS(c) - CHARACTER'POS('0'));
                prod128 := accumulate * ten;
                accumulate := RESIZE(prod128, 64) + TO_UNSIGNED(d, 64);
                i := i + 1;
            END LOOP;
            -- Make number one digit at a time
            -- It is computed via ascii
            
            v := accumulate;
    END PROCEDURE parseInteger;

    BEGIN
        PROCESS
            FILE f : TEXT OPEN read_mode IS "day2input.txt";
            VARIABLE l : LINE;
            VARIABLE s : STRING(1 TO 200000);
            VARIABLE n : INTEGER := 0;
            VARIABLE i : INTEGER := 1;
            VARIABLE low : idT;
            VARIABLE high : idT;
            VARIABLE total : sumT := (OTHERS => '0');
            VARIABLE part : sumT;
            VARIABLE ch : CHARACTER;
            VARIABLE decOut : decStringT;

            BEGIN
                READLINE(f, l);
                -- Textio gives a line object
                -- I index it into a fixed string bugger, but n is the nuber of valid characters
                
                n := 0;
                WHILE l'LENGTH > 0 LOOP
                    n := n + 1;
                    READ(l, ch);
                    s(n) := ch;
                END LOOP;

                i := 1;
                WHILE i <= n LOOP
                    parseInteger(s(1 TO n), i, low);

                    IF i <= n AND s(i) = '-' THEN
                        i := i + 1;
                    ELSE
                        REPORT "Parsing Error: Expected a '-' at position " & INTEGER'IMAGE(i) SEVERITY NOTE;
                    END IF;

                    parseInteger(s(1 TO n), i, high);

                    part := sumInvalidInRange(low, high);
                    total := total + part;

                    IF i <= n AND s(i) = ',' THEN
                        i := i + 1;
                    ELSE
                        EXIT;
                    END IF;
                END LOOP;
                -- This is a line by line parse of the ranges
                -- Each range has a computed sum of invalid ids
                
                u64ToDecimal(total, decOut);
                REPORT "Total Sum (decimal) = " & decOut;
                WAIT;
            
        END PROCESS;
END ARCHITECTURE sim;