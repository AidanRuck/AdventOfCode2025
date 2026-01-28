% Made by Aidan Ruck

filename = "day4input.txt";

lines = readlines(filename);
% Read all of the lines from the input file

lines(lines == "") = [];
% Remove potential empty lines

grid = char(lines);
% Convert to a matrix of characters

isRoll = (grid == '@');
% Create logic grid (same as before, where @ is a roll)

kernel = ones(3,3);
% 3x3 matrix of surrounding slots to a given position

totalRemoved = 0;
% Variable to keep track of the total rolls that get removed

roundNumber = 0;

while true
    roundNumber = roundNumber + 1;
    % Keep track of how many times this iterates

    neighborCount = conv2(double(isRoll), kernel, 'same') - double(isRoll);
    % Count neighboring rolls for each positions
    % Subtract the center cell so only the neighbors remain

    accessible = isRoll & (neighborCount < 4);
    % A roll is only accessible if it itself is a roll and has less than 4 neighboring rolls

    removedThisRound = nnz(accessible);
    % Count how many rolls will be removed

    if removedThisRound == 0
        fprintf("No more removable rolls. \n");
        break;
    end

    fprintf("Round %d: Removed %d rolls \n", roundNumber, removedThisRound);
    % Display progress

    isRoll(accessible) = false;
    % Remove all of the accessible rolls

    totalRemoved = totalRemoved + removedThisRound;
    % Update total count

end

fprintf("Total rolls removed = %d \n", totalRemoved);
% Display final results
