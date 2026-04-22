module top #(
    parameter DIVISOR = 50_000_000,
    parameter FILE_NAME = "mem_init.mif",
    parameter ADDR_WIDTH = 6,
    parameter DATA_WIDTH = 16
) (
    input clk,
    input rst_n,
    input [1:0] kbd,
    input [2:0] btn,
    input [8:0] sw,
    output [13:0] mnt,
    output [9:0] led,
    output [27:0] hex
);

    wire clk_div_out;
    clk_div #(.DIVISOR(DIVISOR))clk_div_inst(.clk(clk), .rst_n(rst_n), .out(clk_div_out));

    wire[DATA_WIDTH-1:0] mem_out;

    wire cpu_we;
    wire cpu_status;
    wire [ADDR_WIDTH-1:0] cpu_addr;
    wire [DATA_WIDTH-1:0] cpu_data;
    wire [DATA_WIDTH-1:0] cpu_out;
    wire [ADDR_WIDTH-1:0] cpu_pc;
    wire [ADDR_WIDTH-1:0] cpu_sp;
    cpu cpu_inst(.clk(clk_div_out), .rst_n(rst_n), .mem(mem_out), .in(scan_codes_num), .control(scan_codes_control), .status(cpu_status), .we(cpu_we), .addr(cpu_addr), .data(cpu_data), .out(led[4:0]), 
    .pc(cpu_pc), .sp(cpu_sp));
    
    memory mem_inst(.clk(clk_div_out), .we(cpu_we), .addr(cpu_addr), .data(cpu_data), .out(mem_out));

    wire [3:0] bcd1_ones;
    wire [3:0] bcd1_tens;
    bcd bcd_inst1(.in(cpu_pc), .ones(bcd1_ones), .tens(bcd1_tens));
    // bcd bcd_inst1(.in(ps2_code[15:12]), .ones(bcd1_ones), .tens(bcd1_tens));
    // bcd bcd_inst1(.in(4'h01), .ones(bcd1_ones), .tens(bcd1_tens));

    wire [3:0] bcd2_ones;
    wire [3:0] bcd2_tens;
    bcd bcd_inst2(.in(cpu_sp), .ones(bcd2_ones), .tens(bcd2_tens));
    // bcd bcd_inst2(.in(ps2_code[11:8]), .ones(bcd2_ones), .tens(bcd2_tens));
    // bcd bcd_inst2(.in(4'h02), .ones(bcd2_ones), .tens(bcd2_tens));

    ssd ssd_inst1(.in(bcd1_ones), .out(hex[6:0]));
    ssd ssd_inst2(.in(bcd1_tens), .out(hex[13:7]));
    ssd ssd_inst3(.in(bcd2_ones), .out(hex[20:14]));
    ssd ssd_inst4(.in(bcd2_tens), .out(hex[27:21]));

    wire [15:0] ps2_code;
    ps2 ps2_inst(.clk(clk), .rst_n(rst_n), .ps2_clk(kbd[0]), .ps2_data(kbd[1]), .code(ps2_code));

    wire scan_codes_control;
    wire [3:0] scan_codes_num;
    scan_codes scan_codes_inst(.clk(clk), .rst_n(rst_n), .code(ps2_code), .control(scan_codes_control), .num(scan_codes_num), .status(cpu_status));

    wire [23:0] color_codes_code;
    color_codes color_codes_inst(.num(cpu_out), .code(color_codes_code));

    reg vga_clock_gen;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) vga_clock_gen <= 1'b0;
        else vga_clock_gen <= ~vga_clock_gen;
    end

    vga vga_unit (
        .clk(vga_clock_gen), 
        .rst_n(rst_n), 
        .code(color_codes_code), 
        .hsync(mnt[13]), 
        .vsync(mnt[12]), 
        .red(mnt[11:8]), 
        .green(mnt[7:4]), 
        .blue(mnt[3:0])
    );

    // wire clk_div_out_vga;
    // clk_div #(.DIVISOR(2)) clk_div_inst2(.clk(clk), .rst_n(rst_n), .out(clk_div_out_vga));
    // vga vga_inst(.clk(clk_div_out_vga), .rst_n(rst_n), .code(color_codes_code), .hsync(mnt[13]), .vsync(mnt[12]), .red(mnt[11:8]), .green(mnt[7:4]), .blue(mnt[3:0]));
    
    assign led[5] = cpu_status;

    assign led[4:0] = cpu_out;
endmodule