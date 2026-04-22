module color_codes(
    input  [5:0]  num,
    output reg [23:0] code
);

    localparam [11:0] COLOR_0 = 12'h000; // black
    localparam [11:0] COLOR_1 = 12'hF00; // red
    localparam [11:0] COLOR_2 = 12'hF80; // orange
    localparam [11:0] COLOR_3 = 12'hFF0; // yellow
    localparam [11:0] COLOR_4 = 12'h0F0; // green
    localparam [11:0] COLOR_5 = 12'h0FF; // cyan
    localparam [11:0] COLOR_6 = 12'h08F; // light blue
    localparam [11:0] COLOR_7 = 12'h00F; // blue
    localparam [11:0] COLOR_8 = 12'hF0F; // magenta
    localparam [11:0] COLOR_9 = 12'hFFF; // white

    reg [3:0] tens;
    reg [3:0] ones;

    always @(*) begin
        tens = num / 6'd10;
        ones = num - tens*6'd10;

        case (tens)
            4'd0: code[23:12] = COLOR_0;
            4'd1: code[23:12] = COLOR_1;
            4'd2: code[23:12] = COLOR_2;
            4'd3: code[23:12] = COLOR_3;
            4'd4: code[23:12] = COLOR_4;
            4'd5: code[23:12] = COLOR_5;
            4'd6: code[23:12] = COLOR_6;
            4'd7: code[23:12] = COLOR_7;
            4'd8: code[23:12] = COLOR_8;
            4'd9: code[23:12] = COLOR_9;
            default: code[23:12] = 12'h000;
        endcase

        case (ones)
            4'd0: code[11:0] = COLOR_0;
            4'd1: code[11:0] = COLOR_1;
            4'd2: code[11:0] = COLOR_2;
            4'd3: code[11:0] = COLOR_3;
            4'd4: code[11:0] = COLOR_4;
            4'd5: code[11:0] = COLOR_5;
            4'd6: code[11:0] = COLOR_6;
            4'd7: code[11:0] = COLOR_7;
            4'd8: code[11:0] = COLOR_8;
            4'd9: code[11:0] = COLOR_9;
            default: code[11:0] = 12'h000;
        endcase
    end

endmodule