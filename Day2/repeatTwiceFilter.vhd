-- Made by Aidan Ruck

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

PACKAGE repeatTwiceFilter IS
    SUBTYPE idT IS UNSIGNED(63 DOWNTO 0);
    -- 64-bit unsigned for product id
    SUBTYPE sumT IS UNSIGNED(63 DOWNTO 0);
    -- 64-bit accumulator for sum
    SUBTYPE decStringT IS STRING(1 TO 20);

    FUNCTION pow10(k : NATURAL) RETURN idT;
    -- This returns 10^k as 64-bit unsigned
    FUNCTION sumInvalidInRange(low, high : idT) RETURN sumT;
    PROCEDURE u64ToDecimal(u : IN sumT; s : OUT decStringT);

END PACKAGE repeatTwiceFilter;

PACKAGE BODY repeatTwiceFilter IS
    FUNCTION pow10(k : NATURAL) RETURN idT IS
        VARIABLE p : idT := TO_UNSIGNED(1, 64);
        CONSTANT ten : idT := TO_UNSIGNED(10, 64);
        VARIABLE prod128 : UNSIGNED(127 DOWNTO 0);

        BEGIN

            FOR i IN 1 TO k LOOP
                prod128 := p * ten;
                p := RESIZE(prod128, 64);
            END LOOP;
            RETURN p;
    END FUNCTION pow10;

    FUNCTION divFloor(a : idT; d : idT) RETURN idT IS
        BEGIN
            RETURN a / d;
    END FUNCTION divFloor;

    FUNCTION divCeiling(a : idT; d : idT) RETURN idT IS
        BEGIN
            RETURN (a + d - TO_UNSIGNED(1, 64)) / d;
    END FUNCTION divCeiling;
    -- The two helpers above are used to compute the bounds of the x values
    
    PROCEDURE u64ToDecimal(u : IN sumT; s : OUT decStringT) IS
        VARIABLE temp : UNSIGNED(63 DOWNTO 0) := u;
        VARIABLE position : INTEGER := 20;
        VARIABLE digit : INTEGER;
        CONSTANT ten : UNSIGNED(63 DOWNTO 0) := TO_UNSIGNED(10, 64);

        BEGIN
            s := (OTHERS => ' ');

            IF temp = 0 THEN
                s(20) := '0';
                RETURN;
            END IF;

            WHILE temp /= 0 LOOP
                digit := TO_INTEGER(temp MOD ten);
                s(position) := CHARACTER'VAL(CHARACTER'POS('0') + digit);
                temp := temp / ten;
                position := position - 1;
            END LOOP;

    END PROCEDURE u64ToDecimal;
    -- Converts 64-bit unsigned into a decimal string for the problem output
    
    FUNCTION sumInvalidInRange(low, high : idT) RETURN sumT IS
        VARIABLE total : sumT := (OTHERS => '0');
        VARIABLE denomination : idT;
        VARIABLE minX : idT;
        VARIABLE maxX : idT;
        VARIABLE lowK : idT;
        VARIABLE highK : idT;
        VARIABLE maxDigits : NATURAL;

        VARIABLE countN : idT;
        VARIABLE sumX : idT;
        VARIABLE a : idT;
        VARIABLE b : idT;

        VARIABLE prod128 : UNSIGNED(127 DOWNTO 0);

        BEGIN
            IF high < low THEN
                RETURN total;
            END IF;

            maxDigits := 20;

            FOR kk IN 1 TO maxDigits / 2 LOOP
                denomination := pow10(kk) + TO_UNSIGNED(1, 64);

                IF kk = 1 THEN
                    lowK := TO_UNSIGNED(1, 64);
                ELSE
                    lowK := pow10(kk - 1);
                END IF;
                highK := pow10(kk) - TO_UNSIGNED(1, 64);

                minX := divCeiling(low, denomination);
                maxX := divFloor(high, denomination);

                IF minX < lowK THEN
                    minX := lowK;
                END IF;
                IF maxX > highK THEN
                    maxX := highK;
                END IF;

                IF minX <= maxX THEN
                    countN := maxX - minX + TO_UNSIGNED(1, 64);

                    a := minX + maxX;
                    b := countN;

                    IF a(0) = '0' THEN
                        a := SHIFT_RIGHT(a, 1);
                    ELSE
                        b := SHIFT_RIGHT(b, 1);
                    END IF;

                    prod128 := a * b;
                    sumX := RESIZE(prod128, 64);

                    prod128 := sumX * denomination;
                    total := total + RESIZE(prod128, 64);
                END IF;
            END LOOP;

        RETURN total;
    END FUNCTION sumInvalidInRange;

END PACKAGE BODY;