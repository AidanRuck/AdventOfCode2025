module top(
    input wire clk,
    input wire rst,
    input wire [63:0] romData,
    output wire [19:0] romAddress,
    output wire romEnable,
    output wire [63:0] freshCount,
    output wire done,
    output wire countValid
);

    wire rangeWE;
    wire [11:0] rangeAddress;
    wire [63:0] rangeLowWData, rangeHighWData;
    wire [63:0] rangeLowRData, rangeHighRData;

    freshFilterPart1 u_ctrl(
        .clk(clk),
        .rst(rst),
        .romData(romData),
        .romAddress(romAddress),
        .romEnable(romEnable),
        .freshCount(freshCount),
        .done(done),
        .countValid(countValid),
        .rangeWE(rangeWE),
        .rangeAddress(rangeAddress),
        .rangeLowWData(rangeLowWData),
        .rangeHighWData(rangeHighWData),
        .rangeLowRData(rangeLowRData),
        .rangeHighRData(rangeHighRData)
    );

    rangeBRAM u_mem(
        .clk(clk),
        .we(rangeWE),
        .address(rangeAddress),
        .lowWData(rangeLowWData),
        .highWData(rangeHighWData),
        .lowRData(rangeLowRData),
        .highRData(rangeHighRData)
    );

endmodule
