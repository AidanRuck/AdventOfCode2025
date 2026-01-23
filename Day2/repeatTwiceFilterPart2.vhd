-- Made by Aidan Ruck

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

PACKAGE repeatTwiceFilterPart2 IS
    SUBTYPE idT IS UNSIGNED(63 DOWNTO 0);
    SUBTYPE sumT IS UNSIGNED(63 DOWNTO 0);
    SUBTYPE decStringT IS STRING(1 TO 20);

    FUNCTION pow10(k : NATURAL) RETURN idT;
    FUNCTION sumInvalidInRange(low, high : idT) RETURN sumT;
    PROCEDURE u64ToDecimal(u : IN sumT; s : OUT decStringT);

END PACKAGE repeatTwiceFilterPart2;

PACKAGE BODY repeatTwiceFilterPart2 IS
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

    FUNCTION isPrimitive(x : idT; k : NATURAL) RETURN BOOLEAN IS
        VARIABLE d : NATURAL;
        VARIABLE times : NATURAL;
        VARIABLE pow10d : idT;
        VARIABLE factor : idT;
        VARIABLE p : idT;
        VARIABLE y : idT;
        VARIABLE lowD : idT;
        VARIABLE highD : idT;
        VARIABLE prod128 : UNSIGNED(127 DOWNTO 0);

        BEGIN
            IF k <= 1 THEN
                RETURN TRUE;
            END IF;

            FOR dd IN 1 TO k - 1 LOOP
                IF (k MOD dd) = 0 THEN
                    times := k / dd;
                    pow10d := pow10(dd);

                    factor := TO_UNSIGNED(0, 64);
                    p := TO_UNSIGNED(1, 64);
                    FOR t IN 1 TO times LOOP
                        factor := factor + p;
                        prod128 := p * pow10d;
                        p := RESIZE(prod128, 64);
                    END LOOP;

                    IF (x MOD factor) = TO_UNSIGNED(0, 64) THEN
                        y := x / factor;

                        IF dd = 1 THEN
                            lowD := TO_UNSIGNED(1, 64);
                        ELSE
                            lowD := pow10(dd - 1);
                        END IF;
                        highD := pow10(dd) - TO_UNSIGNED(1, 64);

                        IF (y >= lowD) AND (y <= highD) THEN
                            RETURN FALSE;
                        END IF;
                    END IF;
                END IF;
            END LOOP;

            RETURN TRUE;
    END FUNCTION isPrimitive;

    FUNCTION sumInvalidInRange(low, high : idT) RETURN sumT IS
        VARIABLE total : sumT := (OTHERS => '0');
        VARIABLE pow10k : idT;
        VARIABLE denomination : idT;
        VARIABLE minX : idT;
        VARIABLE maxX : idT;
        VARIABLE lowK : idT;
        VARIABLE highK : idT;
        VARIABLE x : idT;
        VARIABLE value : idT;
        VARIABLE maxDigits : NATURAL;
        VARIABLE maxRepeat : NATURAL;
        VARIABLE p : idT;
        VARIABLE prod128 : UNSIGNED(127 DOWNTO 0);

        BEGIN
            IF high < low THEN
                RETURN total;
            END IF;

            maxDigits := 20;

            FOR kk IN 1 TO maxDigits LOOP
                pow10k := pow10(kk);
                maxRepeat := maxDigits / kk;

                FOR rr IN 2 TO maxRepeat LOOP
                    denomination := TO_UNSIGNED(0, 64);
                    p := TO_UNSIGNED(1, 64);
                    FOR t IN 1 TO rr LOOP
                        denomination := denomination + p;
                        prod128 := p * pow10k;
                        p := RESIZE(prod128, 64);
                    END LOOP;

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
                        x := minX;
                        WHILE x <= maxX LOOP
                            IF isPrimitive(x, kk) THEN
                                prod128 := x * denomination;
                                value := RESIZE(prod128, 64);
                                total := total + value;
                            END IF;
                            x := x + TO_UNSIGNED(1, 64);
                        END LOOP;
                    END IF;
                END LOOP;
            END LOOP;

        RETURN total;
    END FUNCTION sumInvalidInRange;

END PACKAGE BODY;