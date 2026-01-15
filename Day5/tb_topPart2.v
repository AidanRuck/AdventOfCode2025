`timescale 1ns / 1ps

module tb_topPart2;

    reg clk = 0;
    reg rst = 1;

    wire [19:0] romAddress;
    wire romEnable;
    reg [63:0] romData;

    wire [63:0] freshCount;
    wire done;
    wire countValid;

    localparam integer romDepth = 200000;
    reg [63:0] rom [0:romDepth - 1];

    localparam romFile = "day5input.mem";

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

    topPart2 dut(
        .clk(clk),
        .rst(rst),
        .romData(romData),
        .romAddress(romAddress),
        .romEnable(romEnable),
        .freshCount(freshCount),
        .done(done),
        .countValid(countValid)
    );

    always #5 clk = ~clk;

    initial begin
        for(i = 0; i < romDepth; i = i + 1) begin
            rom[i] = 64'h0;
        end

        $display("Loading ROM from %s ", romFile);
        $readmemh(romFile, rom);
        $display("ROM load is now complete.");

        #50;
        rst = 0;

        #200000000;
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

endmodule