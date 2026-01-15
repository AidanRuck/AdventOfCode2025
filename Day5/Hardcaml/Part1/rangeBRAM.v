module rangeBRAM #(
    parameter addressWidth = 12,
    parameter depth = (1 << addressWidth)
)(
    input wire clk,
    input wire we,
    input wire [addressWidth -1 :0] address,
    input wire [63:0] lowWData,
    input wire [63:0] highWData,
    output reg [63:0] lowRData,
    output reg [63:0] highRData
);

    reg [63:0] memLow [0:depth - 1];
    reg [63:0] memHigh [0:depth - 1];

    always @(posedge clk) begin
        if (we) begin
            memLow[address] <= lowWData;
            memHigh[address] <= highWData;
        end
        lowRData <= memLow[address];
        highRData <= memHigh[address];
    end
endmodule