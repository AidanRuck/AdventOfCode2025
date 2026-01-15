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

I figured to take on a challenge like moving my code from object-oriented software to a hardware description language, I would first build a solution in C++ to reference as I created it in other languages.

# Part 1 - C++

### Initial Approach
First, my thoughts were:
- Put all ranges into a vector
- Read the ingredient IDs
- Check if the ID falls in any of the ranges
- Mark it as fresh if so

### Issues and Fixes
Initially, I had ingredient IDs and ranges stored as `ints`.
When running the program with the input, the program kept crashing with:
`std::out_of_range
what(): stoi`

After inspecting the input file, it became clear to me that the file inputs were larger than 32-bit integers.
My fixes were:
- Switching all `int` to `long long`
- Switching all `stoi` to `stoll`

I also noticed a large issue with using standard `cin` commands, so I swapped over to `getline` commands to safely read large inputs and filter whitespace.

### Running the Program
After running the command `Get-Content day5input.txt | ./Day5Part1`, I received a list of all ingredient IDs that were fresh as well as a total count at the end.

## Moving to the Second Part of Day 5
The second part of today's problem revolves around how many integers are covered by the combination of all ranges, ignoring which of the ingredient IDs are available and fresh.

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

To run this program, very similarly to Part 1, run the command: `Get-Content day5input.txt | ./Day5Part2`.

### Results
- Part 1 ran smoothly, successfully identifying which IDs were fresh
- Part 2 correctly counted which number of fresh ingredient IDs were in the ranges
- Handles the large numbers with long long
- Input handling required no sanitization from the line endings or whitespace.

---

# Part 2 - Transitioning to VHDL
After completing my prototype in C++, I then moved to translate my design into VHDL that could be synthesized in RTL via Xilinx Vivado.

### Inputting Text to VHDL
I realized early on to the development of my VHDL version that I could not use a .txt file as an input like I did with my C++ implementation.

I figured that I could convert my .txt input to some form of file readable in Vivado for simulation on Hardware. I settled on a .mem input (ROM format), which can be read for Part 1 and Part 2.

I then created a short Python script that should convert my input into a .mem file. The file:
- Converts the text input into a 64-bit memory image
- Mirrors the original file
- Removes text parsing such that VHDL can process it autonomously
  
The mentioned Python script can be found labelled as `convertToMem.py` in this folder. To run the script, use the following command: `python convertToMem.py <input.txt> <output.mem>` in a terminal at the same location as your input file.

### High-Level Ideas (RTL Design)

My DUT:
1. Reads the Number of Ranges
2. Stores the ranges as (start/end) pairs
3. Reads the Number of Indexes
4. For each ID
   - Check it against all ranges
   - If it is in a range, it is fresh

Ranges stored using arrays `rangeLow(i)` and `rangeHigh(i)`.

Maximum Number of Ranges represented by a generic, `gMaxRanges`.

My design functions off of a simple FSM with States:
- sReadNR: Read Number of Ranges
- sReadRangeStart: Read the start of a range
- sReadRangeEnd: Read the end of a range and store it
- sReadNI: Read the Number of IDs
- sReadID: Read one ingredient ID
- sScan: Scan all of the stored Ranges for the given ID
- sFinish: Mark as complete and output the final result

This generates a few different outputs:
- freshValid: This pulses when a fresh ID is detected
- freshID: The ID that is detected when freshValid goes to 1
- freshCount: The total number of fresh IDs that have been counted
- done: This stays high when all values have been processed
- countValid: One pulse when the final count is valid

### Testbench Design

This testbench file:
- Uses `textio` (VHDL) to load the .mem file into a simulated ROM array
- Drives the clock and reset signals
- Connects the ROM model to the DUT interface
- Prints the IDs and final count when done

To ensure that the simulator can see the .mem file in Vivado (or alternative software):
- Add it as a Simulation Source (if using Vivado)
- Or: Place it in the simulation run directory that xSim will use

### Issues and Fixes (cont.)

Originally, countValid stayed high forever when sFinish was triggered, so the monitor continuously printed that it was done every clock cycle. This made it such that the final count was buried when extra padding time had been given for the simulation to complete.

To combat this issue, I updated it that once the state triggered, and it verified that it was done, I ensured that it never kept cycling, only triggering the finished state once.

There are also negative "Fresh ID Found: " prints which are caused by printing the low 32 bits as a signed integer (instead of unsigned as they're stored) which causes values above 2^31 to be negative. Though this did not impact functionality (as I still got the correct answer output), I theorized that this could be fixed by displaying them as hex, or changing them to be stored as unsigned variables.

### How to Run

1. Convert the AoC input to a .mem file as outlined above
2. Open Vivado (or similar software)
3. Add `freshFilter.vhd` as a Design Source
4. Add `tb_freshFilter.vhd` as a Simulation Source
5. Add `day5input.mem` (or equivalent file) under Simulation Source (if doing it this way)
6. Run a Behavioral Simulation
7. Outputs can be seen in the transcript / log via `freshCount`, `freshValid`, `done,` and `freshID`.

## Moving to Part Two in VHDL

As above, Part Two ignores the list of IDs and instead asks for the unique IDs covered by all ranges (inclusive).

### High-Level Design

1. Read the ranges from the .mem file (the same as Part One)
2. Sort the ranges using bubble sort
3. Merge ranges in one single pass, gathering total length
4. Output `freshCount` as a total of the ranges
5. Pulse `done` and `countValid`

In theory, this should work if:
- Ranges overlap
- Ranges are out of order

This question does not need the list of IDs, so we will just ignore them for now.

Though this is not the fastest solution, it should be able to scale to 1000+ ranges given enough simulation time.

### Architecture

This will use the same .mem file input as Part One but looks for something else once all ranges have been read.

Once the (start, end) pairs are stored, the program then goes to:
1. Sorting
2. Merging and Accumulation

This is all in one finite state machine to keep the control flow easily traceable.

### Sorting

Ranges are sorted first by ascending start value, then by ascending end value (of the starts happen to be equal). 

I also used bubble sort for this stage, though it can be inefficient in software. For hardware, however, there are many advantages:
- Easy to implement in HDLs / RTL
- Easy to debug
- No extra memory usage
- Stable and very deterministic.

Each swap and comparison occurs in a single clock cycle. This means that sorting happens in O(n^2) cycles, but for simulation-scale inputs, this is acceptable.

Once sorted, the design uses a single linear pass to ensure the union of every range. It keeps track of the beginning of the current merged interval `currentStart`, and the end of the current merged interval `currentEnd`.

For each new range:
- If disjoint (the next start is greater than the current end point + 1), then:
  - The length of the previous interval is added to the total
  - A new interval is started
- If it overlaps / touches: 
  -  The interval is extended

All of the ranges are inclusive, so the lengths are computed as (end - start) + 1.

At the end of the merge pass, the final interval is computed and the total gets stored in `freshCount`.

### Testbench Design (Part Two)

The testbench:
- Loads the .mem file using `textio`
- Models the ROM
- Drives the clock and reset signals
- Waits for the done signal to pulse to '1'
- Prints the final result

Since VHDL does not support printing 64-bit unsigned integers directly, a custom conversion function had to be implemented to correctly display the large value.

### Final Results for Part Two in VHDL

This design exactly matches the result from my C++ version, meaning that:
- Range sorting is correct
- The merge logic is correct
- Inclusive range handling works as intended
- No double counting occurs

### Issues and Fixes (cont.)

1. Sorting runtime
   - Bubble sort required a significantly longer simulation time
   - It was fixed by running the simulation for at least .2 milliseconds (which covers my file, though it may be different)
2. Total printing was incorrect
   - Initially, only the lowest 32 bits of `freshCount` were being printed
   - This was obviously incorrect (the output was larger than 32 bits)
   - I then verified that the output was the equivalent to modulo 2^32
   - I then fixed this by implementing a full 64-bit decimal conversion helper function

### VHDL Design Summary

My design shows that a text based software problem can translated into a hardware description language that can be synthesized and ran. This design uses:
- .mem file bulk input
- Finite state machines
- On-chip storage
- Sorting and merging algorithms created in RTL

### How to Run (cont.)

1. Open Vivado (or similar software)
2. Add `freshFilterPart2.vhd` as a Design Source
3. Add `tb_freshFilterPart2.vhd` as a Simulation Source
4. Add `day5input.mem` (or equivalent file) under Simulation Source (if doing it this way)
   - This should have been created during the last process, use the same file as before.
5. Run a Behavioral Simulation
6. Outputs can be seen in the transcript / log via `freshCount`, `freshValid`, `done,` and `freshID`.

---

# Transitioning to Hardcaml

First, I had to install Hardcaml and review the documentation. Admittedly, this is the first time that I have used the language, so I had a lot to learn.

I reviewed the documentation the [Jane Street GitHub repository for Hardcaml](https://github.com/janestreet/hardcaml/tree/master), as well as brushed up on Ocaml.

I then created my project folder within WSL (I personally have Ubuntu installed) and got to work. I first made a bare-bones model of my first part, just to confirm that I could build and compile a file.

## Part One - Hardcaml

After I successfully validated each part in VHDL, I moved on to remaking the design using Hardcaml.

Unlike VHDL, Hardcaml allows RTL designs to be make using:
- Functional abstractions
- Explicit signal compositions
- Strong compile-time typing

My goal was not to simplify the design, but to reproduce the same behavior that I had already made, using a fundamentally different design methodology.

In Hardcaml:
- All state is represented explicitly with registers
- FSM transitions are constructed with Always.compile
- Signal widths have to be defined everywhere
- There is no implicit clocking or reset behavior

This made for a very deliberate and structured transition of my VHDL design.

### Part 1 Architecture

The Part 1 Hardcaml design mirrors my VHDL version very closely:
1. Read the number of ranges from the .mem file
2. Store each range as (low, high) pairs in the BRAM
3. Read each stored ingredient ID
4. Scan all stored ranges for inclusion
5. Count how many IDs are fresh

The FSM states are directly mapped from VHDL with:
- Explicit state registers
- Explicit comparison signals
- Explicit write-enabled pulses for BRAM

### Interfacing with Verilog

Once the Hardcaml design was complete, it was:
1. Built using `dune build`
2. Emitted as Verilog using `Rtl.print Verilog`
3. Transferred using the command `dune exec -- bin/main.ml > freshFilterPart1.v`
4. Imported into Vivado alongside:
   - A hand-written Verilog BRAM
   - A Verilog testbench
   - The same .mem file input as the VHDL implementation

This confirmed that:
- Hardcaml-generated RTL integrated cleanly with traditional HDLs (what I am used to)
- The simulation environment does not need to be rewritten

### Issues and Fixes (cont.)

1. **`Always.t` vs `Always.t list` Type Errors**

  One of the earliest issues I had was Hardcaml rejecting what appeared to be a valid FSM code with type expression errors. This primarily occured when using nested if statements inside FSM states.

To fix this, I ensured
- Every if expression appreared as its own list element
- Nested if statements were placed inside list brackets explicitly

2. **Boolean and Signal Confusion**
   
  I frequently encountered errors that expected a `Signal.t` but recieved a `bool` instead.

I learned that all conditions must be signal-level comparisons, and accidentally using the normal OCaml comparisons instead of signal operators caused these issues. I went ahead and replaced all that I could see, for example replacing `=` with `==:`.

3. **BRAM Read Timing Mismatch**
   
  Initially, my design always read zeros from BRAM when scanning the ranges.
I learned that this was because Verilog uses synchronous reads, which meant that the data was valid one cycle after the address was presented. My design initially set rangeAddress and then immediately consumed the Low R Data and High R Data in the same cycle, which caused an error.

To fix this, I introduced new FSM states that:
- Request the address
- Wait one cycle
- Read the data

This solved my zero-data issue.

4. **Output Always Printing Zero**
   
  Even after my FSM completed, my testbench would always print a 0.

I found that this was a timing issue as `freshCount` would update correctly, but `countValid` was pulsed too early. I added a new register for `finishPulse` and delayed my `countValid` pulse by one cycle.

### Results (Hardcaml)

This implementation:
- Produced the exact same result as the C++ and VHDL versions
- Correctly pulsed `countValid`
- Correctly terminated simulation
- Demonstrated functional equivalence across the three languages

## Part Two - Hardcaml

Part two was significantly more complex than Part one, as it required:
- Sorting ranges
- Merging overlapping intervals
- Accumulating huge 64-bit totals

### Key Challenges

Some of the notable challenges I had when implementing this part were:
- Bubble sort requires careful index management
- All comparisons must be signal-based (with no booleans)
- Every arithmetic operation must explicitly manage bit width
- Multi-cycle memory access must be sequenced manually

Unlike software, even the simplest of control flow requires precise FSM staging.

### Sorting and Merging

The design performs:
1. Bubble sort on (low, high) pairs stored in BRAM
2. A linear merge pass after sorting
3. Accumulation of merged segment lengths using 64-bit arithmetic

All of the arithmetic follows `segmentLength = (high - low) + 1`
Ranges that overlap or touch are merged, ensuring no double counting.

### Issues and Fixes (cont.)

1. **Extremely Large Incorrect Output Value**

My design kept producing the number `594674218583` which was nowhere close to my known C++ answer.

I figured this was because it was double-counting merged segments, caused by the FSM adding segment lengths both when the merge failed, and again at the end of the loop.

To fix this, I separated `currentSegmentLength` and `finalSegmentLength` and ensured that each segment only contributed to `freshCount` once.

2. **Merge FSM Ordering Errors**

Early iterations of my FSM would:
- Advance the merge index
- Update `currentRangeLow` and `currentRangeHigh`
- Incorrectly re-evaluate merge conditions

I figured this was because the transitions occurred in the same cycle as data updates, which caused stale values to be reused, and incorrect comparisons.

I implemented a strict sequence:
1. Read next range
2. Decide mergeability
3. Either merge or close segment
4. Advance index on the next cycle

3. **Sorting Logic Not Fully Completing**

The bubble sort FSM initially terminated too early, which left the range list unsorted. I figured this was because sortDone's inner boundary was off by at least one.

I rewrote the logic to use `(rangeCount - 1) - sortOuterIndex` which ensured full completion.

### Results (cont.)

The final Hardcaml implementation:
- Matches my C++ output exactly
- Matches my VHDL output exactly
- Correctly handles very large 64-bit totals
- Uses the same .mem input file with no modification.

---

# Overall Project Summary

This project demonstrates a complete transition pipeline from:
1. C++ (software reference)
2. VHDL (traditional RTL)
3. Hardcaml (functional RTL generation)

Across all implementations:
- The same algorithm intent is preserved
- The same inputs produce the same outputs
- Increasing abstraction levels did not sacrifice correctness

This project served both as:
- A deep dive into RTL design
- A first-principles introduction to Hardcaml
- A validation of software/hardware equivalence
