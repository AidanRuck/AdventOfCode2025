# Advent of Code 2025 - Day 5
**Author:** Aidan Ruck

**Languages:** C++ -> VHDL -> Hardcaml

---

## Overview
Day 5 revolves around working with a database of Ingredients and ID Ranges. Each range represents IDs that are considered Fresh.
The file contains:
1. A list of fresh ingredient ID ranges (inclusive)
2. A single blank line
3. Then a list of available ingredient IDs

The goal of Part 1 is to determine which IDs are fresh. Part 2 is counting all Fresh Ingredient IDs.

I figured to take on a challenge like moving my code from objct-oriented to a hardware description language, I would first build a solution in C++ to reference as I created it in other languages.

## Part 1 - C++

### Initial Approach
First, my thoughts were:
- Put all ranges into a vector
- Read the ingredient IDs
- Check if the ID falls in any of the ranges
- Mark it as fresh if so

### Issues and Fixes
Initially, I had ingredient IDs and ranges stored as `ints`.
When running the program with the input, the program kept creashing with:
`std::out_of_range
what(): stoi`

After inspecting the input file, it became clear to me that the file inputs were larger than 32-bit integers.
My fixes were:
- Switching all `int` to `long long`
- Switching all `stoi` to `stoll`

I also notices a large issue with using standard `cin` commands, so I swapped over to `getline` commands to safely read large inputs and filter whitespace.

### Running the Program
After running the command `Get-Content day5input.txt | ./Day5Part1`, I recieved a list of all ingredient IDs that were fresh as well as a total number at the end.

### Moving to the Second Part of Day 5
The second part of Today's problem revolves around how many integers are covered by the combination of all ranges, ignoring which of the ingredient IDs are available and fresh.

It seemed not feasible to loop through every number, or to store every ID in memory since it would be time-consuming and memory-intensive.

I decided to:
1. Read all of the ranges
2. Sort the ranges with their starting values
3. Merge all overlapping or close ranges (within 1)
4. For each merged range, add together
5. Compute the result

This ensures:
- Each ingredient ID is counted once
- Overlapping ranges don't cause double counting
- An efficient solution over a large range.

### Results
- Part 1 ran smoothly, successfully identifying which IDs were fresh
- Part 2 correctly counted which number of fresh ingredient IDs were in the ranges
- Handles the large numbers with long long
- Input handling required no sanitization from the line endings or whitespace.

## Part 2 - Transitioning to VHDL
After completing my prototype in C++, I then moved to translate my design into VHDL that could be synthesized in RTL via Xilinx Vivado.
