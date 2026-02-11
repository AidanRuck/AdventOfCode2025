% Made by Aidan Ruck

clear;
clc;

filename = "day8input.txt";
% You can remane this if your file is named differently
K = 1000;
% Number of shortest connections to be applied (by prompt)

pts = readmatrix(filename);
% This looks for 3 columns, from prompt
N = size(pts, 1);

if size(pts, 2) ~= 3
    error("Input did not have 3 columns (X, Y, Z)");
end

d = pdist(pts, "euclidean");
% Compute the pairwise euclidean distances using vectors

[~, order] = sort(d, "ascend");
K = min(K, numel(order));
kIdx = order(1:K);
% Sort distances and find the indices of the k smallest pairs

parent = 1:N;
sz = ones(1, N);
% setup for union-find

for t = 1:K
    k = kIdx(t);
    [i, j] = pdistIndexToPair(k, N);
    % Convert pdist index to a pair in i, j

    [parent, sz] = unionSets(i, j, parent, sz);
    % Combine sets
end
% Apply the k shortest connections

roots = zeros(N, 1);
for i = 1:N
    roots(i) = findRoot(i, parent);
end
% Find the final sizes of components

[uniqueRoots, ~, group] = unique(roots);
compSizes = accumarray(group, 1);
% Count sizes of each root

compSizes = sort(compSizes, "descend");
% Sort the component sizes and take top 3

if numel(compSizes) < 3
    error("Less than 3 circuits exist");
end

answer = compSizes(1)*compSizes(2)*compSizes(3);

fprintf("Top 3 circuit sizes: %d, %d, %d \n", compSizes(1), compSizes(2), compSizes(3));
fprintf("Answer = %d", answer);

% Helper functions below

function r = findRoot(x, parent)
    while parent(x) ~= x
        parent(x) = parent(parent(x));
        x = parent(x);
    end
    r = x;
end
% Find root via path compression

function [parent, sz] = unionSets(a, b, parent, sz)
    ra = findRoot(a, parent);
    rb = findRoot(b, parent);
    % Union by size

    if ra == rb
        return;
        % This will happen if already connected
    end

    if sz(ra) < sz(rb)
        tmp = ra;
        ra = rb;
        rb = tmp;
    end
    % Attach the smaller tree to larger tree

    parent(rb) = ra;
    sz(ra) = sz(ra) + sz(rb);
end

function [i, j] = pdistIndexToPair(k, N)
    counts = (N - 1):-1:1;
    % n-1, n-2...
    cumulative = cumsum(counts);
    % cumulative total

    i = find(k <= cumulative, 1, "first");

    if i ==1
        prev = 0;
    else
        prev = cumulative(i - 1);
    end

    offset = k - prev;
    j = i + offset;
end
