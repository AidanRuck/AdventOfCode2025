`timescale 1ns / 1ps

module tb_top;

    reg clk = 0;
    reg rst = 1;

    wire [19:0] romAddress;
    wire romEnable;
    reg [63:0] romData;
    // DUT interface

    wire [63:0] freshCount;
    wire done;
    wire countValid;
    // Outputs

    localparam integer romDepth = 200000;
    reg [63:0] rom [0:romDepth - 1];
    // using the addressWidth = 20 would be too big to allocate

    localparam romFile = "day5input.mem";
    // This will be whatever your .mem file is named, mine is day5input

    integer i;

    always @(*) begin
        if(romEnable) begin
            if(romAddress < romDepth)
                romData = rom[romAddress];
            else
                romData = 64'h0;
            end else begin
                romData = 64'h0;
        end
    end

    top dut(
        .clk(clk),
        .rst(rst),
        .romData(romData),
        .romAddress(romAddress),
        .romEnable(romEnable),
        .freshCount(freshCount),
        .done(done),
        .countValid(countValid)
    );
    // This will be the wrapper for the top file / DUT

    always #5 clk = ~clk;
    // Clock at 100 MHz

    initial begin
        for(i = 0; i < romDepth; i = i + 1) begin
            rom[i] = 64'h0;
        end
        // Set .mem to 0

        $display("Loading ROM from %s ", romFile);
        $readmemh(romFile, rom);
        $display("ROM load is now complete.");
        // Load the data from AoC into file

        #50;
        rst = 0;
        // Hold reset

        #200000000; // 200 ms sim time
        $display("Timeout. Simulation ended before done.");
        $finish;
    end

    reg printed = 0;
    always @(posedge clk) begin
        if(!printed && countValid) begin
            printed = 1;
            $display("Done. freshCount (decimal) = %0d", freshCount);
            $finish;
        end
    end
    // Print once when countValid pulses to high

endmodule