% Made by Aidan Ruck

filename = "day4input.txt";
% My input is stored in this text file, you can edit it to be whatever yours is named and this will function

lines = readlines(filename);
lines(lines == "") = [];
% Read all lines
% Remove empty lines

grid = char(lines);
% The lines become a matrix of characters with each line being a row

isRoll = (grid == '@');
% In the grid, the @ character is a roll, wheras a . is empty

kernel = ones(3,3);
% Each cell should count the rolls in the 8 closest positions
neighborCount = conv2(double(isRoll), kernel, 'same') - double(isRoll);
% Use convolution method with a 3x3 matrix and subtract the center

accessible = isRoll & (neighborCount < 4);
% A position is accessible if it is a roll and there are fewer than 4
% adjacent rolls near it

answer = nnz(accessible);
% Final answer

disp("Accessible rolls = " + answer);
% Display the final answer to command window
