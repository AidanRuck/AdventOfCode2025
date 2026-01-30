filename = "day6input.txt";

lines = readlines(filename);
% Read the input from file

lines = lines(lines ~= "");
% Remove empty lines

numRows = length(lines);

maxLength = 0;
for r = 1:numRows
    maxLength = max(maxLength, strlength(lines(r)));
end
% Find the widest line then make a rectange

grid = repmat(' ', numRows, maxLength);
for r = 1:numRows
    s = char(lines(r));
    grid(r, 1:length(s)) = s;
end
% Build character matrix

opRow = 0;
for r = numRows:-1:1
    if any(grid(r,:) == '+') || any(grid(r,:) == '*')
        opRow = r;
        break;
    end
end
% Find the operator row

if opRow == 0
    error("Could not find operator row.");
end

isBlankColumn = true(1, maxLength);
for c = 1:maxLength
    if any(grid(:, c) ~= ' ')
        isBlankColumn(c) = false;
    end
end
% Find the column ranges

segments = [];
inSegment = false;
startColumn = 0;
% Find non blank column segments
% Each row is (startColumn, endColumn)

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

bigInteger = @(x) java.math.BigInteger(char(string(x)));
bigZero = java.math.BigInteger("0");
bigOne = java.math.BigInteger("1");
% Use the BigInteger shortcuts from Java

grandTotal = bigZero;

for s = 1:size(segments, 1)
    c1 = segments(s, 1);
    c2 = segments(s, 2);

    opSlice = grid(opRow, c1:c2);
    opSliceString = string(opSlice);

    % Get operator from the row

    hasPlus = any(opSlice == '+');
    hasMultiply = any(opSlice == '*');

    if hasPlus && hasMultiply
        error("Segment %d contains two operators (+ and *).", s);
    elseif ~hasPlus && ~hasMultiply
        error("Could not find operator for segment %d", s);
    end
    % Detect any operator errors

    nums = java.util.ArrayList();

    for col = c2:-1:c1
        tokenCharacters = [];
        for r = 1:(opRow - 1)
            ch = grid(r, col);
            if ch >= '0' && ch <= '9'
                tokenCharacters = [tokenCharacters ch];
            end
        end
        % Read columns right to left, digits top to bottom

        if ~isempty(tokenCharacters)
            nums.add(bigInteger(string(tokenCharacters)));
        end
    end

    if nums.size() == 0
        continue;
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
    % Compute segment result
    
    grandTotal = grandTotal.add(result);
end

disp("Grand Total = " + string(grandTotal.toString()));
% Display result
