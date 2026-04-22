module ps2 (
    input clk,
    input rst_n,
    input ps2_clk,
    input ps2_data,
    output [15:0] code
);
    wire clk_clean;
    wire dat_clean;

    debouncer db_u1 (
        .clk(clk),
        .rst_n(rst_n),
        .in(ps2_clk),
        .out(clk_clean)
    );

    debouncer db_u2 (
        .clk(clk),
        .rst_n(rst_n),
        .in(ps2_data),
        .out(dat_clean)
    );

    reg [1:0] fsm_state, fsm_next;
    reg [3:0] bit_ptr, bit_ptr_next;
    reg [7:0] data_shifter, data_shifter_next;
    reg chk_parity, chk_parity_next;
    reg [15:0] out_buffer, out_buffer_next;
    reg is_extended, is_extended_next;
    reg is_released, is_released_next;

    assign code = out_buffer;

    localparam IDLE = 2'd0;
    localparam FETCH = 2'd1;
    localparam CHECK_PAR = 2'd2;
    localparam VERIFY_ST = 2'd3;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            fsm_state    <= IDLE;
            bit_ptr      <= 0;
            data_shifter <= 0;
            chk_parity   <= 0;
            out_buffer   <= 0;
            is_extended  <= 0;
            is_released  <= 0;
        end else begin
            fsm_state    <= fsm_next;
            bit_ptr      <= bit_ptr_next;
            data_shifter <= data_shifter_next;
            chk_parity   <= chk_parity_next;
            out_buffer   <= out_buffer_next;
            is_extended  <= is_extended_next;
            is_released  <= is_released_next;
        end
    end

    always @(negedge clk_clean) begin
        fsm_next = fsm_state;
        bit_ptr_next = bit_ptr;
        data_shifter_next = data_shifter;
        chk_parity_next = chk_parity;
        out_buffer_next = out_buffer;
        is_extended_next = is_extended;
        is_released_next = is_released;

        case (fsm_state)
            IDLE: begin
                if (dat_clean == 0) begin
                    bit_ptr_next = 0;
                    data_shifter_next = 0;
                    fsm_next = FETCH;
                end
            end

            FETCH: begin
                data_shifter_next[bit_ptr] = dat_clean;
                if (bit_ptr == 7)
                    fsm_next = CHECK_PAR;
                else
                    bit_ptr_next = bit_ptr + 1;
            end

            CHECK_PAR: begin
                chk_parity_next = dat_clean;
                fsm_next = VERIFY_ST;
            end

            VERIFY_ST: begin
                if (dat_clean == 1) begin
                    if ((^data_shifter) == ~chk_parity) begin
                        if (data_shifter == 8'hE0) begin
                            is_extended_next = 1;
                        end else if (data_shifter == 8'hF0) begin
                            is_released_next = 1;
                            out_buffer_next  = {out_buffer[7:0], data_shifter};
                        end else begin
                            out_buffer_next  = {out_buffer[7:0], data_shifter};
                            
                            is_extended_next = 0;
                            is_released_next = 0;
                        end
                    end
                end
                fsm_next = IDLE;
            end
        endcase
    end
endmodule