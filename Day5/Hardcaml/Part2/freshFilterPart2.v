module freshFilterPart2(
    rangeHighRData,
    romData,
    rangeLowRData,
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
    input [63:0] romData;
    input [63:0] rangeLowRData;
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

    wire [63:0] _67;
    wire _74;
    wire _75;
    wire [63:0] _76;
    wire _45;
    wire [63:0] _49;
    wire [63:0] _51;
    wire [63:0] _1;
    reg [63:0] _48;
    wire _53;
    wire [63:0] _57;
    wire [63:0] _59;
    wire [63:0] _2;
    reg [63:0] _56;
    wire _65;
    wire [63:0] _69;
    wire _63;
    wire [63:0] _70;
    wire _61;
    wire [63:0] _77;
    wire [63:0] _79;
    wire [63:0] _3;
    reg [63:0] _68;
    wire [63:0] _89;
    wire _81;
    wire [63:0] _90;
    wire [63:0] _92;
    wire [63:0] _5;
    reg [63:0] _73;
    wire _107;
    wire _108;
    wire [63:0] _109;
    wire _95;
    wire [63:0] _102;
    wire _94;
    wire [63:0] _106;
    wire _93;
    wire [63:0] _110;
    wire [63:0] _112;
    wire [63:0] _6;
    reg [63:0] _98;
    wire [11:0] _127;
    wire [11:0] _142;
    wire [11:0] _139;
    wire _125;
    wire [11:0] _132;
    wire _123;
    wire [11:0] _134;
    wire _121;
    wire [11:0] _140;
    wire _120;
    wire [11:0] _141;
    wire _119;
    wire [11:0] _143;
    wire _117;
    wire [11:0] _144;
    wire _115;
    wire [11:0] _146;
    wire _113;
    wire [11:0] _150;
    wire [11:0] _152;
    wire [11:0] _8;
    reg [11:0] _128;
    wire _162;
    wire _155;
    wire _157;
    wire _154;
    wire _158;
    wire _153;
    wire _159;
    wire _160;
    wire _10;
    reg _163;
    wire _172;
    wire _167;
    wire _173;
    wire _165;
    wire _174;
    wire _175;
    wire _12;
    reg _170;
    wire _171;
    wire _177;
    wire _176;
    wire _178;
    wire _179;
    wire _13;
    reg _182;
    wire gnd;
    wire _184;
    wire _188;
    wire _183;
    wire _189;
    wire _190;
    wire _15;
    reg _187;
    wire [63:0] _249;
    wire [63:0] _246;
    wire [63:0] _247;
    wire [63:0] _208;
    wire _194;
    wire [63:0] _209;
    wire _192;
    wire [63:0] _210;
    wire [63:0] _212;
    wire [63:0] _17;
    reg [63:0] _197;
    wire [63:0] _241;
    wire [63:0] _242;
    wire _214;
    wire [63:0] _215;
    wire [63:0] _217;
    wire [63:0] _18;
    reg [63:0] _205;
    wire [63:0] _201;
    wire _227;
    wire [63:0] _228;
    wire _218;
    wire [63:0] _222;
    wire [63:0] _224;
    wire [63:0] _20;
    reg [63:0] _221;
    wire [63:0] _229;
    wire _226;
    wire [63:0] _230;
    wire _225;
    wire [63:0] _231;
    wire [63:0] _233;
    wire [63:0] _21;
    reg [63:0] _200;
    wire [63:0] _202;
    wire _206;
    wire _207;
    wire [63:0] _244;
    wire [63:0] _245;
    wire [63:0] _248;
    wire [63:0] _250;
    wire _235;
    wire [63:0] _251;
    wire _234;
    wire [63:0] _253;
    wire [63:0] _255;
    wire [63:0] _22;
    reg [63:0] _238;
    wire [19:0] _425;
    wire [19:0] _430;
    wire [19:0] _427;
    wire [19:0] _428;
    wire _423;
    wire [19:0] _429;
    wire _422;
    wire [19:0] _431;
    wire [4:0] _41;
    wire [4:0] _417;
    wire [4:0] _414;
    wire [4:0] _413;
    wire _256;
    wire [63:0] _257;
    wire [63:0] _259;
    wire [63:0] _26;
    reg [63:0] _87;
    wire [63:0] _263;
    wire _261;
    wire [63:0] _264;
    wire _260;
    wire [63:0] _266;
    wire [63:0] _268;
    wire [63:0] _27;
    reg [63:0] _84;
    wire _88;
    wire [4:0] _415;
    wire [4:0] _408;
    wire [4:0] _407;
    wire [4:0] _409;
    wire [4:0] _405;
    wire [4:0] _403;
    wire [4:0] _401;
    wire [4:0] _399;
    wire [4:0] _396;
    wire [4:0] _393;
    wire [4:0] _395;
    wire [4:0] _397;
    wire [4:0] _389;
    wire [11:0] _378;
    wire [11:0] _379;
    wire _380;
    wire _381;
    wire _376;
    wire _377;
    wire _382;
    wire [4:0] _385;
    wire [11:0] _311;
    wire [11:0] _287;
    wire [11:0] _288;
    wire [11:0] _289;
    wire [11:0] _281;
    wire [11:0] _282;
    wire _272;
    wire [11:0] _283;
    wire _271;
    wire [11:0] _290;
    wire _269;
    wire [11:0] _292;
    wire [11:0] _294;
    wire [11:0] _28;
    reg [11:0] _275;
    wire [11:0] _278;
    wire [11:0] _279;
    wire [11:0] _285;
    wire _286;
    wire [11:0] _312;
    wire _295;
    wire [63:0] _296;
    wire [63:0] _298;
    wire [63:0] _29;
    reg [63:0] _101;
    wire _299;
    wire [63:0] _300;
    wire [63:0] _302;
    wire [63:0] _31;
    reg [63:0] _105;
    wire _284;
    wire [11:0] _313;
    wire [11:0] _307;
    wire [11:0] _308;
    wire _305;
    wire [11:0] _309;
    wire _304;
    wire [11:0] _314;
    wire _303;
    wire [11:0] _316;
    wire [11:0] _318;
    wire [11:0] _32;
    reg [11:0] _137;
    wire [11:0] _276;
    wire _280;
    wire [4:0] _387;
    wire [4:0] _373;
    wire [4:0] _370;
    wire [4:0] _369;
    wire _367;
    wire _368;
    wire [4:0] _371;
    wire [4:0] _364;
    wire [4:0] _362;
    wire [11:0] _322;
    wire _320;
    wire [11:0] _323;
    wire _319;
    wire [11:0] _325;
    wire [11:0] _327;
    wire [11:0] _33;
    reg [11:0] _149;
    wire vdd;
    wire [11:0] _331;
    wire [11:0] _332;
    wire _330;
    wire [11:0] _333;
    wire _329;
    wire [11:0] _334;
    wire _328;
    wire [11:0] _336;
    wire [11:0] _338;
    wire [11:0] _35;
    reg [11:0] _131;
    wire [11:0] _239;
    wire _240;
    wire [4:0] _360;
    wire _355;
    wire [4:0] _357;
    wire _354;
    wire [4:0] _361;
    wire _353;
    wire [4:0] _363;
    wire _352;
    wire [4:0] _365;
    wire _351;
    wire [4:0] _372;
    wire _350;
    wire [4:0] _374;
    wire _349;
    wire [4:0] _388;
    wire _348;
    wire [4:0] _390;
    wire _347;
    wire [4:0] _398;
    wire _346;
    wire [4:0] _400;
    wire _345;
    wire [4:0] _402;
    wire _344;
    wire [4:0] _404;
    wire _343;
    wire [4:0] _406;
    wire _342;
    wire [4:0] _410;
    wire _341;
    wire [4:0] _412;
    wire _340;
    wire [4:0] _416;
    wire _339;
    wire [4:0] _418;
    wire [4:0] _420;
    wire [4:0] _36;
    reg [4:0] _43;
    wire _421;
    wire [19:0] _432;
    wire [19:0] _434;
    wire [19:0] _38;
    reg [19:0] _426;
    assign _67 = 64'b0000000000000000000000000000000000000000000000000000000000000000;
    assign _74 = romData < _73;
    assign _75 = ~ _74;
    assign _76 = _75 ? romData : _73;
    assign _45 = _43 == _401;
    assign _49 = _45 ? rangeHighRData : _48;
    assign _51 = rst ? _67 : _49;
    assign _1 = _51;
    always @(posedge clk or posedge rst) begin
        if (rst)
            _48 <= _67;
        else
            _48 <= _1;
    end
    assign _53 = _43 == _405;
    assign _57 = _53 ? rangeHighRData : _56;
    assign _59 = rst ? _67 : _57;
    assign _2 = _59;
    always @(posedge clk or posedge rst) begin
        if (rst)
            _56 <= _67;
        else
            _56 <= _2;
    end
    assign _65 = _43 == _389;
    assign _69 = _65 ? _56 : _68;
    assign _63 = _43 == _396;
    assign _70 = _63 ? _48 : _69;
    assign _61 = _43 == _414;
    assign _77 = _61 ? _76 : _70;
    assign _79 = rst ? _67 : _77;
    assign _3 = _79;
    always @(posedge clk or posedge rst) begin
        if (rst)
            _68 <= _67;
        else
            _68 <= _3;
    end
    assign _89 = _88 ? romData : _73;
    assign _81 = _43 == _417;
    assign _90 = _81 ? _89 : _73;
    assign _92 = rst ? _67 : _90;
    assign _5 = _92;
    always @(posedge clk or posedge rst) begin
        if (rst)
            _73 <= _67;
        else
            _73 <= _5;
    end
    assign _107 = romData < _73;
    assign _108 = ~ _107;
    assign _109 = _108 ? _73 : romData;
    assign _95 = _43 == _389;
    assign _102 = _95 ? _101 : _98;
    assign _94 = _43 == _396;
    assign _106 = _94 ? _105 : _102;
    assign _93 = _43 == _414;
    assign _110 = _93 ? _109 : _106;
    assign _112 = rst ? _67 : _110;
    assign _6 = _112;
    always @(posedge clk or posedge rst) begin
        if (rst)
            _98 <= _67;
        else
            _98 <= _6;
    end
    assign _127 = 12'b000000000000;
    assign _142 = _137 + _378;
    assign _139 = _137 + _378;
    assign _125 = _43 == _369;
    assign _132 = _125 ? _131 : _128;
    assign _123 = _43 == _408;
    assign _134 = _123 ? _127 : _132;
    assign _121 = _43 == _389;
    assign _140 = _121 ? _139 : _134;
    assign _120 = _43 == _396;
    assign _141 = _120 ? _137 : _140;
    assign _119 = _43 == _403;
    assign _143 = _119 ? _142 : _141;
    assign _117 = _43 == _407;
    assign _144 = _117 ? _137 : _143;
    assign _115 = _43 == _413;
    assign _146 = _115 ? _127 : _144;
    assign _113 = _43 == _414;
    assign _150 = _113 ? _149 : _146;
    assign _152 = rst ? _127 : _150;
    assign _8 = _152;
    always @(posedge clk or posedge rst) begin
        if (rst)
            _128 <= _127;
        else
            _128 <= _8;
    end
    assign _162 = 1'b0;
    assign _155 = _43 == _389;
    assign _157 = _155 ? vdd : gnd;
    assign _154 = _43 == _396;
    assign _158 = _154 ? vdd : _157;
    assign _153 = _43 == _414;
    assign _159 = _153 ? vdd : _158;
    assign _160 = rst ? gnd : _159;
    assign _10 = _160;
    always @(posedge clk or posedge rst) begin
        if (rst)
            _163 <= _162;
        else
            _163 <= _10;
    end
    assign _172 = _171 ? vdd : _170;
    assign _167 = _43 == _370;
    assign _173 = _167 ? _172 : _170;
    assign _165 = _43 == _41;
    assign _174 = _165 ? gnd : _173;
    assign _175 = rst ? gnd : _174;
    assign _12 = _175;
    always @(posedge clk or posedge rst) begin
        if (rst)
            _170 <= _162;
        else
            _170 <= _12;
    end
    assign _171 = _170 == gnd;
    assign _177 = _171 ? vdd : gnd;
    assign _176 = _43 == _370;
    assign _178 = _176 ? _177 : gnd;
    assign _179 = rst ? gnd : _178;
    assign _13 = _179;
    always @(posedge clk or posedge rst) begin
        if (rst)
            _182 <= _162;
        else
            _182 <= _13;
    end
    assign gnd = 1'b0;
    assign _184 = _43 == _370;
    assign _188 = _184 ? vdd : _187;
    assign _183 = _43 == _41;
    assign _189 = _183 ? gnd : _188;
    assign _190 = rst ? gnd : _189;
    assign _15 = _190;
    always @(posedge clk or posedge rst) begin
        if (rst)
            _187 <= _162;
        else
            _187 <= _15;
    end
    assign _249 = _238 + _244;
    assign _246 = _229 - _208;
    assign _247 = _246 + _201;
    assign _208 = _207 ? _197 : _205;
    assign _194 = _43 == _362;
    assign _209 = _194 ? _208 : _197;
    assign _192 = _43 == _373;
    assign _210 = _192 ? rangeLowRData : _209;
    assign _212 = rst ? _67 : _210;
    assign _17 = _212;
    always @(posedge clk or posedge rst) begin
        if (rst)
            _197 <= _67;
        else
            _197 <= _17;
    end
    assign _241 = _200 - _197;
    assign _242 = _241 + _201;
    assign _214 = _43 == _364;
    assign _215 = _214 ? rangeLowRData : _205;
    assign _217 = rst ? _67 : _215;
    assign _18 = _217;
    always @(posedge clk or posedge rst) begin
        if (rst)
            _205 <= _67;
        else
            _205 <= _18;
    end
    assign _201 = 64'b0000000000000000000000000000000000000000000000000000000000000001;
    assign _227 = _200 < _221;
    assign _228 = _227 ? _221 : _200;
    assign _218 = _43 == _364;
    assign _222 = _218 ? rangeHighRData : _221;
    assign _224 = rst ? _67 : _222;
    assign _20 = _224;
    always @(posedge clk or posedge rst) begin
        if (rst)
            _221 <= _67;
        else
            _221 <= _20;
    end
    assign _229 = _207 ? _228 : _221;
    assign _226 = _43 == _362;
    assign _230 = _226 ? _229 : _200;
    assign _225 = _43 == _373;
    assign _231 = _225 ? rangeHighRData : _230;
    assign _233 = rst ? _67 : _231;
    assign _21 = _233;
    always @(posedge clk or posedge rst) begin
        if (rst)
            _200 <= _67;
        else
            _200 <= _21;
    end
    assign _202 = _200 + _201;
    assign _206 = _202 < _205;
    assign _207 = ~ _206;
    assign _244 = _207 ? _67 : _242;
    assign _245 = _238 + _244;
    assign _248 = _245 + _247;
    assign _250 = _240 ? _249 : _248;
    assign _235 = _43 == _362;
    assign _251 = _235 ? _250 : _238;
    assign _234 = _43 == _41;
    assign _253 = _234 ? _67 : _251;
    assign _255 = rst ? _67 : _253;
    assign _22 = _255;
    always @(posedge clk or posedge rst) begin
        if (rst)
            _238 <= _67;
        else
            _238 <= _22;
    end
    assign _425 = 20'b00000000000000000000;
    assign _430 = _88 ? _428 : _426;
    assign _427 = 20'b00000000000000000001;
    assign _428 = _426 + _427;
    assign _423 = _43 == _414;
    assign _429 = _423 ? _428 : _426;
    assign _422 = _43 == _417;
    assign _431 = _422 ? _430 : _429;
    assign _41 = 5'b00000;
    assign _417 = 5'b00001;
    assign _414 = 5'b00010;
    assign _413 = 5'b00011;
    assign _256 = _43 == _41;
    assign _257 = _256 ? romData : _87;
    assign _259 = rst ? _67 : _257;
    assign _26 = _259;
    always @(posedge clk or posedge rst) begin
        if (rst)
            _87 <= _67;
        else
            _87 <= _26;
    end
    assign _263 = _84 + _201;
    assign _261 = _43 == _414;
    assign _264 = _261 ? _263 : _84;
    assign _260 = _43 == _41;
    assign _266 = _260 ? _67 : _264;
    assign _268 = rst ? _67 : _266;
    assign _27 = _268;
    always @(posedge clk or posedge rst) begin
        if (rst)
            _84 <= _67;
        else
            _84 <= _27;
    end
    assign _88 = _84 < _87;
    assign _415 = _88 ? _414 : _413;
    assign _408 = 5'b01011;
    assign _407 = 5'b00100;
    assign _409 = _382 ? _408 : _407;
    assign _405 = 5'b00101;
    assign _403 = 5'b00110;
    assign _401 = 5'b00111;
    assign _399 = 5'b01000;
    assign _396 = 5'b01001;
    assign _393 = _382 ? _408 : _407;
    assign _395 = _286 ? _407 : _393;
    assign _397 = _284 ? _396 : _395;
    assign _389 = 5'b01010;
    assign _378 = 12'b000000000001;
    assign _379 = _149 - _378;
    assign _380 = _275 < _379;
    assign _381 = ~ _380;
    assign _376 = _378 < _149;
    assign _377 = ~ _376;
    assign _382 = _377 | _381;
    assign _385 = _382 ? _408 : _407;
    assign _311 = _137 + _378;
    assign _287 = _275 + _378;
    assign _288 = _286 ? _275 : _287;
    assign _289 = _284 ? _275 : _288;
    assign _281 = _275 + _378;
    assign _282 = _280 ? _275 : _281;
    assign _272 = _43 == _389;
    assign _283 = _272 ? _282 : _275;
    assign _271 = _43 == _399;
    assign _290 = _271 ? _289 : _283;
    assign _269 = _43 == _413;
    assign _292 = _269 ? _127 : _290;
    assign _294 = rst ? _127 : _292;
    assign _28 = _294;
    always @(posedge clk or posedge rst) begin
        if (rst)
            _275 <= _127;
        else
            _275 <= _28;
    end
    assign _278 = _149 - _378;
    assign _279 = _278 - _275;
    assign _285 = _137 + _378;
    assign _286 = _285 < _279;
    assign _312 = _286 ? _311 : _127;
    assign _295 = _43 == _405;
    assign _296 = _295 ? rangeLowRData : _101;
    assign _298 = rst ? _67 : _296;
    assign _29 = _298;
    always @(posedge clk or posedge rst) begin
        if (rst)
            _101 <= _67;
        else
            _101 <= _29;
    end
    assign _299 = _43 == _401;
    assign _300 = _299 ? rangeLowRData : _105;
    assign _302 = rst ? _67 : _300;
    assign _31 = _302;
    always @(posedge clk or posedge rst) begin
        if (rst)
            _105 <= _67;
        else
            _105 <= _31;
    end
    assign _284 = _105 < _101;
    assign _313 = _284 ? _137 : _312;
    assign _307 = _137 + _378;
    assign _308 = _280 ? _307 : _127;
    assign _305 = _43 == _389;
    assign _309 = _305 ? _308 : _137;
    assign _304 = _43 == _399;
    assign _314 = _304 ? _313 : _309;
    assign _303 = _43 == _413;
    assign _316 = _303 ? _127 : _314;
    assign _318 = rst ? _127 : _316;
    assign _32 = _318;
    always @(posedge clk or posedge rst) begin
        if (rst)
            _137 <= _127;
        else
            _137 <= _32;
    end
    assign _276 = _137 + _378;
    assign _280 = _276 < _279;
    assign _387 = _280 ? _407 : _385;
    assign _373 = 5'b01100;
    assign _370 = 5'b10000;
    assign _369 = 5'b01101;
    assign _367 = _378 < _149;
    assign _368 = ~ _367;
    assign _371 = _368 ? _370 : _369;
    assign _364 = 5'b01110;
    assign _362 = 5'b01111;
    assign _322 = _149 + _378;
    assign _320 = _43 == _414;
    assign _323 = _320 ? _322 : _149;
    assign _319 = _43 == _41;
    assign _325 = _319 ? _127 : _323;
    assign _327 = rst ? _127 : _325;
    assign _33 = _327;
    always @(posedge clk or posedge rst) begin
        if (rst)
            _149 <= _127;
        else
            _149 <= _33;
    end
    assign vdd = 1'b1;
    assign _331 = _131 + _378;
    assign _332 = _240 ? _331 : _131;
    assign _330 = _43 == _362;
    assign _333 = _330 ? _332 : _131;
    assign _329 = _43 == _373;
    assign _334 = _329 ? _378 : _333;
    assign _328 = _43 == _408;
    assign _336 = _328 ? _127 : _334;
    assign _338 = rst ? _127 : _336;
    assign _35 = _338;
    always @(posedge clk or posedge rst) begin
        if (rst)
            _131 <= _127;
        else
            _131 <= _35;
    end
    assign _239 = _131 + _378;
    assign _240 = _239 < _149;
    assign _360 = _240 ? _369 : _370;
    assign _355 = _43 == _370;
    assign _357 = _355 ? _370 : _43;
    assign _354 = _43 == _362;
    assign _361 = _354 ? _360 : _357;
    assign _353 = _43 == _364;
    assign _363 = _353 ? _362 : _361;
    assign _352 = _43 == _369;
    assign _365 = _352 ? _364 : _363;
    assign _351 = _43 == _373;
    assign _372 = _351 ? _371 : _365;
    assign _350 = _43 == _408;
    assign _374 = _350 ? _373 : _372;
    assign _349 = _43 == _389;
    assign _388 = _349 ? _387 : _374;
    assign _348 = _43 == _396;
    assign _390 = _348 ? _389 : _388;
    assign _347 = _43 == _399;
    assign _398 = _347 ? _397 : _390;
    assign _346 = _43 == _401;
    assign _400 = _346 ? _399 : _398;
    assign _345 = _43 == _403;
    assign _402 = _345 ? _401 : _400;
    assign _344 = _43 == _405;
    assign _404 = _344 ? _403 : _402;
    assign _343 = _43 == _407;
    assign _406 = _343 ? _405 : _404;
    assign _342 = _43 == _413;
    assign _410 = _342 ? _409 : _406;
    assign _341 = _43 == _414;
    assign _412 = _341 ? _417 : _410;
    assign _340 = _43 == _417;
    assign _416 = _340 ? _415 : _412;
    assign _339 = _43 == _41;
    assign _418 = _339 ? _417 : _416;
    assign _420 = rst ? _41 : _418;
    assign _36 = _420;
    always @(posedge clk or posedge rst) begin
        if (rst)
            _43 <= _41;
        else
            _43 <= _36;
    end
    assign _421 = _43 == _41;
    assign _432 = _421 ? _428 : _431;
    assign _434 = rst ? _425 : _432;
    assign _38 = _434;
    always @(posedge clk or posedge rst) begin
        if (rst)
            _426 <= _425;
        else
            _426 <= _38;
    end
    assign romAddress = _426;
    assign romEnable = vdd;
    assign freshCount = _238;
    assign done = _187;
    assign countValid = _182;
    assign rangeWE = _163;
    assign rangeAddress = _128;
    assign rangeLowWData = _98;
    assign rangeHighWData = _68;

endmodule