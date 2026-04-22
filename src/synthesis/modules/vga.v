module vga(
    input clk,    
    input rst_n,  
    input [23:0] code,  
    output hsync,
    output vsync,
    output [3:0] red,
    output [3:0] green,
    output [3:0] blue
);


    localparam H_VISIBLE = 640;
    localparam H_FRONT_PORCH = 16;
    localparam H_SYNC_PULSE = 96;
    localparam H_BACK_PORCH = 48;
    localparam H_TOTAL = H_VISIBLE + H_FRONT_PORCH + H_SYNC_PULSE + H_BACK_PORCH;

    localparam V_VISIBLE = 480;
    localparam V_FRONT_PORCH = 10;
    localparam V_SYNC_PULSE = 2;
    localparam V_BACK_PORCH = 33;
    localparam V_TOTAL = V_VISIBLE + V_FRONT_PORCH + V_SYNC_PULSE + V_BACK_PORCH;

   
    reg [9:0] h_cnt;
    reg [9:0] v_cnt;
    
    wire h_visible = (h_cnt < H_VISIBLE);
    wire v_visible = (v_cnt < V_VISIBLE);
    wire visible_area = h_visible & v_visible;

    
    assign hsync = ~((h_cnt >= (H_VISIBLE + H_FRONT_PORCH)) && 
                     (h_cnt <  (H_VISIBLE + H_FRONT_PORCH + H_SYNC_PULSE)));
    assign vsync = ~((v_cnt >= (V_VISIBLE + V_FRONT_PORCH)) && 
                     (v_cnt <  (V_VISIBLE + V_FRONT_PORCH + V_SYNC_PULSE)));

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            h_cnt <= 0;
            v_cnt <= 0;
        end else begin
            if (h_cnt == H_TOTAL-1) begin
                h_cnt <= 0;
                if (v_cnt == V_TOTAL-1)
                    v_cnt <= 0;
                else
                    v_cnt <= v_cnt + 1;
            end else begin
                h_cnt <= h_cnt + 1;
            end
        end
    end

    
    wire [11:0] pixel_color = (h_cnt < H_VISIBLE/2) ? code[23:12] : code[11:0];

    assign red   = visible_area ? pixel_color[11:8] : 4'b0000;
    assign green = visible_area ? pixel_color[7:4] : 4'b0000;
    assign blue  = visible_area ? pixel_color[3:0] : 4'b0000;

endmodule