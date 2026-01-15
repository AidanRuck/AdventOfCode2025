module freshFilterPart1 (
    rangeHighRData,
    rangeLowRData,
    romData,
    clk,
    rst,
    romAddress,
    romEnable,
    freshCount,
    done,
    countValid,
    rangeWE,
    rangeAddress,
    rangeLowWData,
    rangeHighWData
);

    input [63:0] rangeHighRData;
    input [63:0] rangeLowRData;
    input [63:0] romData;
    input clk;
    input rst;
    output [19:0] romAddress;
    output romEnable;
    output [63:0] freshCount;
    output done;
    output countValid;
    output rangeWE;
    output [11:0] rangeAddress;
    output [63:0] rangeLowWData;
    output [63:0] rangeHighWData;

    wire [63:0] _41;
    wire _46;
    wire _47;
    wire [63:0] _48;
    wire _39;
    wire [63:0] _49;
    wire [63:0] _51;
    wire [63:0] _1;
    reg [63:0] _42;
    wire [63:0] _61;
    wire _53;
    wire [63:0] _62;
    wire [63:0] _64;
    wire [63:0] _3;
    reg [63:0] _45;
    wire _69;
    wire _70;
    wire [63:0] _71;
    wire _65;
    wire [63:0] _72;
    wire [63:0] _74;
    wire [63:0] _4;
    reg [63:0] _68;
    wire [11:0] _79;
    wire _77;
    wire [11:0] _84;
    wire _75;
    wire [11:0] _88;
    wire [11:0] _90;
    wire [11:0] _6;
    reg [11:0] _80;
    wire _96;
    wire _91;
    wire _93;
    wire _94;
    wire _8;
    reg _97;
    wire _106;
    wire _101;
    wire _107;
    wire _99;
    wire _108;
    wire _109;
    wire _10;
    reg _104;
    wire _105;
    wire _111;
    wire _110;
    wire _112;
    wire _113;
    wire _11;
    reg _116;
    wire _118;
    wire _122;
    wire _117;
    wire _123;
    wire _124;
    wire _13;
    reg _121;
    wire [63:0] _165;
    wire [63:0] _166;
    wire _149;
    wire _150;
    wire [63:0] _137;
    wire _126;
    wire [63:0] _138;
    wire [63:0] _140;
    wire [63:0] _17;
    reg [63:0] _129;
    wire _147;
    wire _148;
    wire _151;
    wire gnd;
    wire _154;
    wire _143;
    wire _153;
    wire _141;
    wire _155;
    wire _156;
    wire _18;
    reg _146;
    wire _152;
    wire _164;
    wire [63:0] _167;
    wire [63:0] _168;
    wire _157;
    wire [63:0] _169;
    wire [63:0] _171;
    wire [63:0] _19;
    reg [63:0] _160;
    wire [19:0] _258;
    wire [19:0] _266;
    wire [19:0] _260;
    wire [19:0] _261;
    wire [19:0] _262;
    wire _256;
    wire [19:0] _263;
    wire _255;
    wire [19:0] _264;
    wire _254;
    wire [19:0] _265;
    wire _253;
    wire [19:0] _267;
    wire [2:0] _35;
    wire [2:0] _248;
    wire [2:0] _245;
    wire [2:0] _244;
    wire _172;
    wire [63:0] _173;
    wire [63:0] _175;
    wire [63:0] _22;
    reg [63:0] _59;
    wire [63:0] _179;
    wire _177;
    wire [63:0] _180;
    wire _176;
    wire [63:0] _182;
    wire [63:0] _184;
    wire [63:0] _23;
    reg [63:0] _56;
    wire _60;
    wire [2:0] _246;
    wire [2:0] _240;
    wire [2:0] _237;
    wire [2:0] _236;
    wire [2:0] _238;
    wire [2:0] _234;
    wire [11:0] _187;
    wire [11:0] _188;
    wire _186;
    wire [11:0] _189;
    wire _185;
    wire [11:0] _191;
    wire [11:0] _193;
    wire [11:0] _24;
    reg [11:0] _87;
    wire _195;
    wire [63:0] _196;
    wire [63:0] _198;
    wire [63:0] _26;
    reg [63:0] _135;
    wire vdd;
    wire [63:0] _202;
    wire [63:0] _203;
    wire _200;
    wire [63:0] _204;
    wire _199;
    wire [63:0] _206;
    wire [63:0] _208;
    wire [63:0] _28;
    reg [63:0] _132;
    wire _136;
    wire [11:0] _216;
    wire [11:0] _212;
    wire [11:0] _213;
    wire _210;
    wire [11:0] _214;
    wire _209;
    wire [11:0] _217;
    wire [11:0] _219;
    wire [11:0] _29;
    reg [11:0] _83;
    wire [11:0] _162;
    wire _163;
    wire [2:0] _232;
    wire _227;
    wire [2:0] _229;
    wire _226;
    wire [2:0] _233;
    wire _225;
    wire [2:0] _235;
    wire _224;
    wire [2:0] _239;
    wire _223;
    wire [2:0] _241;
    wire _222;
    wire [2:0] _243;
    wire _221;
    wire [2:0] _247;
    wire _220;
    wire [2:0] _249;
    wire [2:0] _251;
    wire [2:0] _30;
    reg [2:0] _37;
    wire _252;
    wire [19:0] _268;
    wire [19:0] _270;
    wire [19:0] _32;
    reg [19:0] _259;
    assign _41 = 64'b0000000000000000000000000000000000000000000000000000000000000000;
    assign _46 = romData < _45;
    assign _47 = ~ _46;
    assign _48 = _47 ? romData : _45;
    assign _39 = _37 == _245;
    assign _49 = _39 ? _48 : _42;
    assign _51 = rst ? _41 : _49;
    assign _1 = _51;
    always @(posedge clk or posedge rst) begin
        if (rst)
            _42 <= _41;
        else
            _42 <= _1;
    end
    assign _61 = _60 ? romData : _45;
    assign _53 = _37 == _248;
    assign _62 = _53 ? _61 : _45;
    assign _64 = rst ? _41 : _62;
    assign _3 = _64;
    always @(posedge clk or posedge rst) begin
        if (rst)
            _45 <= _41;
        else
            _45 <= _3;
    end
    assign _69 = romData < _45;
    assign _70 = ~ _69;
    assign _71 = _70 ? _45 : romData;
    assign _65 = _37 == _245;
    assign _72 = _65 ? _71 : _68;
    assign _74 = rst ? _41 : _72;
    assign _4 = _74;
    always @(posedge clk or posedge rst) begin
        if (rst)
            _68 <= _41;
        else
            _68 <= _4;
    end
    assign _79 = 12'b000000000000;
    assign _77 = _37 == _237;
    assign _84 = _77 ? _83 : _80;
    assign _75 = _37 == _245;
    assign _88 = _75 ? _87 : _84;
    assign _90 = rst ? _79 : _88;
    assign _6 = _90;
    always @(posedge clk or posedge rst) begin
        if (rst)
            _80 <= _79;
        else
            _80 <= _6;
    end
    assign _96 = 1'b0;
    assign _91 = _37 == _245;
    assign _93 = _91 ? vdd : gnd;
    assign _94 = rst ? gnd : _93;
    assign _8 = _94;
    always @(posedge clk or posedge rst) begin
        if (rst)
            _97 <= _96;
        else
            _97 <= _8;
    end
    assign _106 = _105 ? vdd : _104;
    assign _101 = _37 == _236;
    assign _107 = _101 ? _106 : _104;
    assign _99 = _37 == _35;
    assign _108 = _99 ? gnd : _107;
    assign _109 = rst ? gnd : _108;
    assign _10 = _109;
    always @(posedge clk or posedge rst) begin
        if (rst)
            _104 <= _96;
        else
            _104 <= _10;
    end
    assign _105 = _104 == gnd;
    assign _111 = _105 ? vdd : gnd;
    assign _110 = _37 == _236;
    assign _112 = _110 ? _111 : gnd;
    assign _113 = rst ? gnd : _112;
    assign _11 = _113;
    always @(posedge clk or posedge rst) begin
        if (rst)
            _116 <= _96;
        else
            _116 <= _11;
    end
    assign _118 = _37 == _236;
    assign _122 = _118 ? vdd : _121;
    assign _117 = _37 == _35;
    assign _123 = _117 ? gnd : _122;
    assign _124 = rst ? gnd : _123;
    assign _13 = _124;
    always @(posedge clk or posedge rst) begin
        if (rst)
            _121 <= _96;
        else
            _121 <= _13;
    end
    assign _165 = 64'b0000000000000000000000000000000000000000000000000000000000000001;
    assign _166 = _160 + _165;
    assign _149 = rangeHighRData < _129;
    assign _150 = ~ _149;
    assign _137 = _136 ? romData : _129;
    assign _126 = _37 == _240;
    assign _138 = _126 ? _137 : _129;
    assign _140 = rst ? _41 : _138;
    assign _17 = _140;
    always @(posedge clk or posedge rst) begin
        if (rst)
            _129 <= _41;
        else
            _129 <= _17;
    end
    assign _147 = _129 < rangeLowRData;
    assign _148 = ~ _147;
    assign _151 = _148 & _150;
    assign gnd = 1'b0;
    assign _154 = _136 ? gnd : _146;
    assign _143 = _37 == _234;
    assign _153 = _143 ? _152 : _146;
    assign _141 = _37 == _240;
    assign _155 = _141 ? _154 : _153;
    assign _156 = rst ? gnd : _155;
    assign _18 = _156;
    always @(posedge clk or posedge rst) begin
        if (rst)
            _146 <= _96;
        else
            _146 <= _18;
    end
    assign _152 = _146 | _151;
    assign _164 = _152 == vdd;
    assign _167 = _164 ? _166 : _160;
    assign _168 = _163 ? _160 : _167;
    assign _157 = _37 == _234;
    assign _169 = _157 ? _168 : _160;
    assign _171 = rst ? _41 : _169;
    assign _19 = _171;
    always @(posedge clk or posedge rst) begin
        if (rst)
            _160 <= _41;
        else
            _160 <= _19;
    end
    assign _258 = 20'b00000000000000000000;
    assign _266 = _60 ? _261 : _259;
    assign _260 = 20'b00000000000000000001;
    assign _261 = _259 + _260;
    assign _262 = _136 ? _261 : _259;
    assign _256 = _37 == _240;
    assign _263 = _256 ? _262 : _259;
    assign _255 = _37 == _244;
    assign _264 = _255 ? _261 : _263;
    assign _254 = _37 == _245;
    assign _265 = _254 ? _261 : _264;
    assign _253 = _37 == _248;
    assign _267 = _253 ? _266 : _265;
    assign _35 = 3'b000;
    assign _248 = 3'b001;
    assign _245 = 3'b010;
    assign _244 = 3'b011;
    assign _172 = _37 == _35;
    assign _173 = _172 ? romData : _59;
    assign _175 = rst ? _41 : _173;
    assign _22 = _175;
    always @(posedge clk or posedge rst) begin
        if (rst)
            _59 <= _41;
        else
            _59 <= _22;
    end
    assign _179 = _56 + _165;
    assign _177 = _37 == _245;
    assign _180 = _177 ? _179 : _56;
    assign _176 = _37 == _35;
    assign _182 = _176 ? _41 : _180;
    assign _184 = rst ? _41 : _182;
    assign _23 = _184;
    always @(posedge clk or posedge rst) begin
        if (rst)
            _56 <= _41;
        else
            _56 <= _23;
    end
    assign _60 = _56 < _59;
    assign _246 = _60 ? _245 : _244;
    assign _240 = 3'b100;
    assign _237 = 3'b101;
    assign _236 = 3'b111;
    assign _238 = _136 ? _237 : _236;
    assign _234 = 3'b110;
    assign _187 = 12'b000000000001;
    assign _188 = _87 + _187;
    assign _186 = _37 == _245;
    assign _189 = _186 ? _188 : _87;
    assign _185 = _37 == _35;
    assign _191 = _185 ? _79 : _189;
    assign _193 = rst ? _79 : _191;
    assign _24 = _193;
    always @(posedge clk or posedge rst) begin
        if (rst)
            _87 <= _79;
        else
            _87 <= _24;
    end
    assign _195 = _37 == _244;
    assign _196 = _195 ? romData : _135;
    assign _198 = rst ? _41 : _196;
    assign _26 = _198;
    always @(posedge clk or posedge rst) begin
        if (rst)
            _135 <= _41;
        else
            _135 <= _26;
    end
    assign vdd = 1'b1;
    assign _202 = _132 + _165;
    assign _203 = _163 ? _132 : _202;
    assign _200 = _37 == _234;
    assign _204 = _200 ? _203 : _132;
    assign _199 = _37 == _244;
    assign _206 = _199 ? _41 : _204;
    assign _208 = rst ? _41 : _206;
    assign _28 = _208;
    always @(posedge clk or posedge rst) begin
        if (rst)
            _132 <= _41;
        else
            _132 <= _28;
    end
    assign _136 = _132 < _135;
    assign _216 = _136 ? _79 : _83;
    assign _212 = _83 + _187;
    assign _213 = _163 ? _212 : _83;
    assign _210 = _37 == _234;
    assign _214 = _210 ? _213 : _83;
    assign _209 = _37 == _240;
    assign _217 = _209 ? _216 : _214;
    assign _219 = rst ? _79 : _217;
    assign _29 = _219;
    always @(posedge clk or posedge rst) begin
        if (rst)
            _83 <= _79;
        else
            _83 <= _29;
    end
    assign _162 = _83 + _187;
    assign _163 = _162 < _87;
    assign _232 = _163 ? _237 : _240;
    assign _227 = _37 == _236;
    assign _229 = _227 ? _236 : _37;
    assign _226 = _37 == _234;
    assign _233 = _226 ? _232 : _229;
    assign _225 = _37 == _237;
    assign _235 = _225 ? _234 : _233;
    assign _224 = _37 == _240;
    assign _239 = _224 ? _238 : _235;
    assign _223 = _37 == _244;
    assign _241 = _223 ? _240 : _239;
    assign _222 = _37 == _245;
    assign _243 = _222 ? _248 : _241;
    assign _221 = _37 == _248;
    assign _247 = _221 ? _246 : _243;
    assign _220 = _37 == _35;
    assign _249 = _220 ? _248 : _247;
    assign _251 = rst ? _35 : _249;
    assign _30 = _251;
    always @(posedge clk or posedge rst) begin
        if (rst)
            _37 <= _35;
        else
            _37 <= _30;
    end
    assign _252 = _37 == _35;
    assign _268 = _252 ? _261 : _267;
    assign _270 = rst ? _258 : _268;
    assign _32 = _270;
    always @(posedge clk or posedge rst) begin
        if (rst)
            _259 <= _258;
        else
            _259 <= _32;
    end
    assign romAddress = _259;
    assign romEnable = vdd;
    assign freshCount = _160;
    assign done = _121;
    assign countValid = _116;
    assign rangeWE = _97;
    assign rangeAddress = _80;
    assign rangeLowWData = _68;
    assign rangeHighWData = _42;

endmodule
