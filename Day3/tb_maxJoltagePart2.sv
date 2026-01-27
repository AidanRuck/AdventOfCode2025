// Made by Aidan Ruck

module tb_maxJoltagePart2;

    localparam int k = 12;

    function automatic int digitsToInteger(byte c);
        if(c >= "0" && c <= "9")
            digitsToInteger = c - "0";
        else
            digitsToInteger = -1;
    endfunction

    function automatic longint digitsToLongint(byte digits[$]);
        // Since the inputs are much longer, we need to use longs
        longint v;
        int i;
        int d;

        begin
            v = 0;
            for(i = 0; i < digits.size(); i = i + 1) begin
                d = digitsToInteger(digits[i]);
                v = v * 10 + d;
            end

            digitsToLongint = v;
        end
    endfunction

    function automatic longint bankMax12(string line);
        byte digits[$];
        byte stack[$];
        int i;
        int d;
        int m;
        int idx;
        byte c;
        int remaining;
        int neededAfterPop;
        byte outDigits[$];

        begin
            digits.delete();
            stack.delete();
            // Clear previous

            // If the current digit is bigger than the last one, and we can still hit 12 digits, pop it

            for(i = 0; i < line.len(); i = i + 1) begin
                if(line[i] == "\n" || line[i] == "\r") begin
                    break;
                end
                // Skip blank characters

                d = digitsToInteger(line[i]);
                if(d < 0) begin
                    continue;
                end

                digits.push_back(line[i]);
            end

            m = digits.size();

            for(idx = 0; idx < m; idx = idx + 1) begin
                c = digits[idx];

                remaining = m - 1 - idx;

                while(stack.size() > 0) begin
                    neededAfterPop = k - stack.size();

                    if(stack[stack.size() - 1] < c && remaining >= neededAfterPop) begin
                        stack.pop_back();
                    end
                    else begin
                        break;
                    end
                end

                stack.push_back(c);
            end

            outDigits.delete();

            for(i = 0; i < k; i = i + 1) begin
                outDigits.push_back(stack[i]);
            end

            // Take the k digits of line to find max

            bankMax12 = digitsToLongint(outDigits);
        end
    endfunction

    initial begin
        int fd;
        string line;
        longint total;
        longint perLineMax;

        total = 0;

        fd = $fopen("day3input.txt", "r");
        if(fd == 0) begin
            $display("Error. Could not open input file");
            $finish;
        end
        // Handle file opening

        while(!$feof(fd)) begin
            if($fgets(line, fd)) begin
                perLineMax = bankMax12(line);
                total = total + perLineMax;
            end
        end
        // Read each line then compute the max and add it to the total

        $fclose(fd);

        $display("Output Joltage (decimal) = %0d", total);
        $finish;
    end

endmodule