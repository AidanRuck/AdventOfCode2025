# Made by Aidan Ruck
# Made to convert input .txt to output .mem file for VHDL / Vivado handling

import sys

def u64_hex(x: int) -> str:
    return f"{x & ((1 << 64) - 1):016x}"
    # Convert integer into 64-bit hex string
    # Will pad if necessary to EXACTLY 16 hex chars

def main():
    if len(sys.argv) != 3:
        print("Usage: python convertToMem.py <input.txt> <output.mem>")
        sys.exit(1)
        # Handle if input is not 2 CL args

    inpath = sys.argv[1] # Input.txt is first arg
    outpath = sys.argv[2] # Output.mem is second arg (what new file will be titled)

    with open(inpath, "r", encoding = "utf-8") as f:
        lines = [ln.rstrip("\n") for ln in f]
        # Read entire input file
        
    split_id = None
    for i, ln in enumerate(lines):
        if ln.strip() == "":
            split_id = i
            break
    
    if split_id is None:
        raise ValueError("No blank line found (AoC Standard). Input must separate ranges and IDs")
    
    # Find the blank line (AoC Standard file input)
    # If no line, it isn't the correct file (or a wrong input)
    
    range_lines = [ln.strip() for ln in lines[:split_id] if ln.strip() != ""]
    # Each range is start-end

    ranges = [] # Empty array to store the new ranges
    for ln in range_lines:
        a_str, b_str = ln.split("-") # Split at the dash of each range
        start = int(a_str)
        end = int(b_str)
        ranges.append((start, end)) 
        # Put start-end in new ranges array

    id_lines = [ln.strip() for ln in lines[split_id + 1:] if ln.strip() != ""]
    ids = [int(ln) for ln in id_lines]
    # Iterate through the IDs (after the blank line)

    # Memory layout is as follows:
    # One work per line, 64-bit hex
    # 0 = number of ranges (NR)
    # 1 = range0 start
    # 2 = range0 end
    # 3 = range1 start
    # 4 = range1 end

    # 2*NR is number of IDs
    # 2*NR + 1 is id0
    # 2*NR + 2 is id1

    with open(outpath, "w", encoding = "utf-8") as out:
        out.write(u64_hex(len(ranges)) + "\n")
        # Write number of ranges

        for start, end in ranges:
            out.write(u64_hex(start) + "\n")
            out.write(u64_hex(end) + "\n")
        # Each range is (start, end)

        out.write(u64_hex(len(ids)) + "\n")
        # Number of IDs

        for x in ids:
            out.write(u64_hex(x) + "\n")
            # Each ingredient ID

    print(f"Wrote {outpath}")
    print(f"Ranges: {len(ranges)}")
    print(f"IDs: {len(ids)}")
    # Print summary after command

if __name__ == "__main__":
    main()
