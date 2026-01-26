// Made by Aidan Ruck

module tb_maxJoltage;

    function automatic int digitToInteger (byte c);
        if (c >= "0" && c <= "9")
            digitToInteger = c - "0";
        else
            digitToInteger = -1;
    endfunction

    function automatic int bankMax (string line);
        int bestTens;
        // Store the best tens number (two digits)
        int best;
        int i;
        int d;
        // Newest candidate for the ones place

        begin
            // This will scan from the left to the right and then find the maximum over the whole line
            bestTens = -1;
            best = 0;

            for (i = 0; i < line.len(); i = i + 1) begin
                if (line[i] == "\n" || line[i] == "\r") begin
                    break;
                end
                // Stop on newline characters

                d = digitToInteger(line[i]);

                if (d < 0) begin
                    continue;
                end
                // Ignore non-digits

                if (bestTens >= 0) begin
                    if (10*bestTens + d > best) begin
                        best = 10*bestTens + d;
                    end
                end
                // Create best from parts

                if (d > bestTens) begin
                    bestTens = d;
                end
                // Update the new digits

            end

            bankMax = best;
        end
    endfunction

    initial begin
        int fd;
        string line;
        longint total;
        int perLineMax;

        total = 0;

        fd = $fopen("day3input.txt", "r");
        if (fd == 0) begin
            $display("Error. Could not open the input file");
            $finish;
        end
        // Handle file opening (or if the file is misplaced)

        while (!$feof(fd)) begin
            if ($fgets(line, fd)) begin
                perLineMax = bankMax(line);
                total = total + perLineMax;
            end
        end
        // Read each line then compute the max and add it to the total

        $fclose(fd);

        $display("Output Joltage (decimal) = %0d", total);
        $finish;
    end

endmodule