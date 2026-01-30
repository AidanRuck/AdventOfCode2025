filename = "day6input.txt";

lines = readlines(filename);
% Read the input from file (as strings)

% Keep lines that are not completely empty
lines = lines(lines ~= "");

numRows = length(lines);

maxLength = 0;
for r = 1:numRows
    maxLength = max(maxLength, strlength(lines(r)));
end
% Find the widest line so we can build a rectangular char grid

grid = repmat(' ', numRows, maxLength);
for r = 1:numRows
    s = char(lines(r));
    grid(r, 1:length(s)) = s;
end
% Build a character matrix padded with spaces

opRow = 0;
for r = numRows:-1:1
    if any(grid(r,:) == '+') || any(grid(r,:) == '*')
        opRow = r;
        break;
    end
end
% Find the operator row (scan from bottom)

if opRow == 0
    error("Could not find an operator row.");
end

isBlankColumn = true(1, maxLength);
for c = 1:maxLength
    if any(grid(:, c) ~= ' ')
        isBlankColumn(c) = false;
    end
end


segments = [];
inSegment = false;
startColumn = 0;
% Each segment will be [startColumn, endColumn]
% A segment is a continuous run of non blank columns

for c = 1:maxLength
    if ~isBlankColumn(c) && ~inSegment
        inSegment = true;
        startColumn = c;
    elseif isBlankColumn(c) && inSegment
        inSegment = false;
        segments = [segments; startColumn, c - 1];
    end
end

if inSegment
    segments = [segments; startColumn, maxLength];
end
% Finish the last segment if the row ends while still "inSegment"

bigInteger = @(x) java.math.BigInteger(char(string(x)));
bigZero = java.math.BigInteger("0");
bigOne  = java.math.BigInteger("1");
% Java BigInteger helpers

grandTotal = bigZero;

for s = 1:size(segments, 1)
    c1 = segments(s, 1);
    c2 = segments(s, 2);

    opSlice = grid(opRow, c1:c2);
    opSliceString = strtrim(string(opSlice));
    % Extract operator text from the operator row for this segment

    hasPlus = contains(opSliceString, "+");
    hasMultiply = contains(opSliceString, "*");

    if hasPlus && hasMultiply
        error("Segment %d contains both operators (+ and *).", s);
    elseif ~hasPlus && ~hasMultiply
        error("Could not find operator for segment %d.", s);
    end

    nums = java.util.ArrayList();
    for r = 1:(opRow - 1)
        slice = grid(r, c1:c2);
        token = strtrim(string(slice));
        % Token is the "number text" in this row for this segment (or blank)

        if strlength(token) > 0
            nums.add(bigInteger(token));
        end
    end
    % Gather all numbers above the operator (ignore blanks)

    if nums.size() == 0
        error("Segment %d had no numbers above its operator.", s);
    end

    if hasPlus
        result = bigZero;
        for i = 0:(nums.size() - 1)
            result = result.add(nums.get(i));
        end
    else
        result = bigOne;
        for i = 0:(nums.size() - 1)
            result = result.multiply(nums.get(i));
        end
    end
    % Compute the result for this segment

    grandTotal = grandTotal.add(result);
    % Add to running grand total
end

disp("Grand Total = " + string(grandTotal.toString()));
