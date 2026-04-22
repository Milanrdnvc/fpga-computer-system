module scan_codes(
    input        clk,
    input        rst_n,
    input [15:0] code,  
    input        status, 
    output reg   control,
    output reg [3:0] num 
);

    localparam [7:0] 
        SC_0 = 8'h45,
        SC_1 = 8'h16,
        SC_2 = 8'h1E,
        SC_3 = 8'h26,
        SC_4 = 8'h25,
        SC_5 = 8'h2E,
        SC_6 = 8'h36,
        SC_7 = 8'h3D,
        SC_8 = 8'h3E,
        SC_9 = 8'h46;

    reg [7:0] last_code;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            num       <= 4'd0;
            control   <= 1'b0;
            last_code <= 8'd0;
        end else begin
            
            control <= 1'b0;

            if (status) begin
               
                if (code[15:8] == 8'hF0) begin
                    last_code <= code[7:0];

                    case (code[7:0])
                        SC_0: num <= 4'd0;
                        SC_1: num <= 4'd1;
                        SC_2: num <= 4'd2;
                        SC_3: num <= 4'd3;
                        SC_4: num <= 4'd4;
                        SC_5: num <= 4'd5;
                        SC_6: num <= 4'd6;
                        SC_7: num <= 4'd7;
                        SC_8: num <= 4'd8;
                        SC_9: num <= 4'd9;
                    endcase

                    control <= 1'b1;
                end
            end
        end
    end

endmodule