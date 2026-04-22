module cpu #(
    parameter ADDR_WIDTH = 6,
    parameter DATA_WIDTH = 16
)(
    input clk,
    input rst_n,
    input [DATA_WIDTH-1:0] mem,
    input [DATA_WIDTH-1:0] in,
    input control,
    output status,
    output we,
    output [ADDR_WIDTH-1:0] addr,
    output [DATA_WIDTH-1:0] data,
    output [DATA_WIDTH-1:0] out,
    output [ADDR_WIDTH-1:0] pc,
    output [ADDR_WIDTH-1:0] sp
);

    localparam PCidx = 0;
    localparam SPidx = 1;
    localparam IR0idx = 2;
    localparam IR1idx = 3;
    localparam MARidx = 4;
    localparam MDRidx = 5;
    localparam Aidx = 6;

    localparam INIT = 6'd0;

    localparam IF1 = 6'd1;
    localparam IF2 = 6'd2;
    localparam IF3 = 6'd3;

    // localparam IF4 = 6'd35;
    // localparam IF5 = 6'd36;
    // localparam IF6 = 6'd37;

    localparam ID1 = 6'd4;
    localparam ID2 = 6'd5;
    localparam ID3 = 6'd6;
    localparam ID4 = 6'd7;
    localparam ID5 = 6'd8;
    localparam ID6 = 6'd9;
    localparam ID7 = 6'd10;
    localparam ID8 = 6'd11;
    localparam ID9 = 6'd12;
    localparam ID10 = 6'd13;
    localparam ID11 = 6'd14;
    localparam ID12 = 6'd15;
    localparam ID13 = 6'd16;
    localparam ID14 = 6'd17;
    localparam ID15 = 6'd18;
    localparam ID16 = 6'd19;
    localparam ID17 = 6'd20;
    localparam ID18 = 6'd21;
    localparam ID19 = 6'd22;
    localparam ID20 = 6'd23;
    localparam ID21 = 6'd24;
    localparam ID22 = 6'd25;
    localparam ID23 = 6'd26;
    localparam ID24 = 6'd27;
    localparam ID25 = 6'd28;
    localparam ID26 = 6'd29;
    localparam ID27 = 6'd30;

    localparam EX1 = 6'd31;
    localparam EX2 = 6'd32;
    localparam EX3 = 6'd33;

    localparam HALT = 6'd34;

    localparam MOV = 4'b0000;
    localparam ADD = 4'b0001;
    localparam SUB = 4'b0010;
    localparam MUL = 4'b0011;
    localparam DIV = 4'b0100;
    localparam IN = 4'b0111;
    localparam OUT = 4'b1000;
    localparam STOP = 4'b1111;

    // localparam BGT = ...;
    
    reg [3:0] opX_next, opX_reg, opY_next, opY_reg, opZ_next, opZ_reg, OC_next, OC_reg;
    reg [DATA_WIDTH-1:0] opXdata_next, opXdata_reg, opYdata_next, opYdata_reg, opZdata_next, opZdata_reg;

    reg[5:0] state_next, state_reg;

    reg cl[6:0], ld[6:0], inc[6:0], dec[6:0], sr[6:0], ir[6:0], sl[6:0], il[6:0];
    reg [DATA_WIDTH-1:0] inReg[6:0];
    wire [DATA_WIDTH-1:0] outReg[6:0];

    reg [ADDR_WIDTH-1:0] addr_next, addr_reg;
    reg [DATA_WIDTH-1:0] data_next, data_reg;
    reg [DATA_WIDTH-1:0] out_next, out_reg;
    reg [ADDR_WIDTH-1:0] pc_next, pc_reg;
    reg [ADDR_WIDTH-1:0] sp_next, sp_reg;
    reg we_next, we_reg;
    reg status_next, status_reg;

    assign addr = addr_reg;
    assign data = data_reg;
    assign out = out_reg;
    assign pc = pc_reg;
    assign sp = sp_reg;
    assign we = we_reg;
    assign status = status_reg;

    reg [2:0] aluOC;
    reg [DATA_WIDTH-1:0] aluA;
    reg [DATA_WIDTH-1:0] aluB;
    wire [DATA_WIDTH-1:0] aluOUT;

    alu #(DATA_WIDTH) alu_inst(.oc(aluOC), .a(aluA), .b(aluB), .f(aluOUT));

    register #(ADDR_WIDTH) reg_inst_pc(.clk(clk), 
                                       .rst_n(rst_n), 
                                       .cl(cl[PCidx]), 
                                       .ld(ld[PCidx]), 
                                       .in(inReg[PCidx]), 
                                       .inc(inc[PCidx]), 
                                       .dec(dec[PCidx]), 
                                       .sr(sr[PCidx]), 
                                       .ir(ir[PCidx]), 
                                       .sl(sl[PCidx]), 
                                       .il(il[PCidx]), 
                                       .out(outReg[PCidx]));

    register #(ADDR_WIDTH) reg_inst_sp(.clk(clk), 
                                       .rst_n(rst_n), 
                                       .cl(cl[SPidx]), 
                                       .ld(ld[SPidx]), 
                                       .in(inReg[SPidx]), 
                                       .inc(inc[SPidx]), 
                                       .dec(dec[SPidx]), 
                                       .sr(sr[SPidx]), 
                                       .ir(ir[SPidx]), 
                                       .sl(sl[SPidx]), 
                                       .il(il[SPidx]), 
                                       .out(outReg[SPidx]));

     register #(DATA_WIDTH) reg_inst_ir0(.clk(clk), 
                                .rst_n(rst_n), 
                                .cl(cl[IR0idx]), 
                                .ld(ld[IR0idx]), 
                                .in(inReg[IR0idx]), 
                                .inc(inc[IR0idx]), 
                                .dec(dec[IR0idx]), 
                                .sr(sr[IR0idx]), 
                                .ir(ir[IR0idx]), 
                                .sl(sl[IR0idx]), 
                                .il(il[IR0idx]), 
                                .out(outReg[IR0idx]));

     register #(DATA_WIDTH) reg_inst_ir1(.clk(clk), 
                                .rst_n(rst_n), 
                                .cl(cl[IR1idx]), 
                                .ld(ld[IR1idx]), 
                                .in(inReg[IR1idx]), 
                                .inc(inc[IR1idx]), 
                                .dec(dec[IR1idx]), 
                                .sr(sr[IR1idx]), 
                                .ir(ir[IR1idx]), 
                                .sl(sl[IR1idx]), 
                                .il(il[IR1idx]), 
                                .out(outReg[IR1idx]));                                                                        

     register #(ADDR_WIDTH) reg_inst_mar(.clk(clk), 
                                .rst_n(rst_n), 
                                .cl(cl[MARidx]), 
                                .ld(ld[MARidx]), 
                                .in(inReg[MARidx]), 
                                .inc(inc[MARidx]), 
                                .dec(dec[MARidx]), 
                                .sr(sr[MARidx]), 
                                .ir(ir[MARidx]), 
                                .sl(sl[MARidx]), 
                                .il(il[MARidx]), 
                                .out(outReg[MARidx])); 

     register #(DATA_WIDTH) reg_inst_mdr(.clk(clk), 
                                .rst_n(rst_n), 
                                .cl(cl[MDRidx]), 
                                .ld(ld[MDRidx]), 
                                .in(inReg[MDRidx]), 
                                .inc(inc[MDRidx]), 
                                .dec(dec[MDRidx]), 
                                .sr(sr[MDRidx]), 
                                .ir(ir[MDRidx]), 
                                .sl(sl[MDRidx]), 
                                .il(il[MDRidx]), 
                                .out(outReg[MDRidx]));

     register #(DATA_WIDTH) reg_inst_a(.clk(clk), 
                                .rst_n(rst_n), 
                                .cl(cl[Aidx]), 
                                .ld(ld[Aidx]), 
                                .in(inReg[Aidx]), 
                                .inc(inc[Aidx]), 
                                .dec(dec[Aidx]), 
                                .sr(sr[Aidx]), 
                                .ir(ir[Aidx]), 
                                .sl(sl[Aidx]), 
                                .il(il[Aidx]), 
                                .out(outReg[Aidx]));     

    always @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            addr_reg <= {ADDR_WIDTH{1'b0}};
            data_reg <= {DATA_WIDTH{1'b0}};
            out_reg <= {DATA_WIDTH{1'b0}};
            pc_reg <= 6'b001000;
            sp_reg <= 6'b111111;
            we_reg <= 1'b0;

            state_reg <= INIT;

            opX_reg <= 4'h0;
            opY_reg <= 4'h0;
            opZ_reg <= 4'h0;
            OC_reg <= 4'h0;

            opXdata_reg <= {DATA_WIDTH{1'b0}};
            opYdata_reg <= {DATA_WIDTH{1'b0}};
            opZdata_reg <= {DATA_WIDTH{1'b0}};

            status_reg <= 1'b0;
        end
        else begin
            addr_reg <= addr_next;
            data_reg <= data_next;
            out_reg <= out_next;
            pc_reg <= pc_next;
            sp_reg <= sp_next;
            we_reg <= we_next;  

            state_reg <= state_next; 

            opX_reg <= opX_next;
            opY_reg <= opY_next;
            opZ_reg <= opZ_next;
            OC_reg <= OC_next;   

            opXdata_reg <= opXdata_next;
            opYdata_reg <= opYdata_next;
            opZdata_reg <= opZdata_next;

            status_reg <= status_next;
        end
    end

    integer i;

    always @(*) begin
        addr_next = addr_reg;
        data_next = data_reg;
        out_next = out_reg;
        pc_next = pc_reg;
        sp_next = sp_reg;
        we_next = 1'b0;

        state_next = state_reg;

        opX_next = opX_reg;
        opY_next = opY_reg;
        opZ_next = opZ_reg;
        OC_next = OC_reg;

        opXdata_next = opXdata_reg;
        opYdata_next = opYdata_reg;
        opZdata_next = opZdata_reg;

        for (i = 0; i < 7; i = i + 1) begin
            cl[i] = 1'b0;
            ld[i] = 1'b0;
            inc[i] = 1'b0;
            dec[i] = 1'b0;
            sr[i] = 1'b0;
            sl[i] = 1'b0;
        end

        case (state_reg)
        INIT: begin
            inReg[PCidx] = 6'b01000;
            ld[PCidx] = 1'b1;

            inReg[SPidx] = 6'b111111;
            ld[SPidx] = 1'b1;

            state_next = IF1;
        end
        IF1: begin
            addr_next = outReg[PCidx];

            pc_next = addr_next;

            state_next = IF2;
        end
        IF2: begin
            we_next = 1'b0;
            state_next = IF3;
        end
        IF3: begin
            inReg[IR0idx] = mem;
            ld[IR0idx] = 1'b1;
            inc[PCidx] = 1'b1;

            // if (mem[15:12] == ADD || mem[15:12] == BGT (ili neka nova koju daju) ) state_next = IF4;
            // else state_next = ID1;
            state_next = ID1;
        end
        // ovo je citanje druge reci, ali samo po potrebi
        // to mogu da proverim gore (npr. iz IR0 registra vidim da li je OC za ADD ili tako nesto i onda procitam i drugu rec)
        // u suprotnom skocim odma na ID1
        // IF4: begin
	    // addr_next = outReg[PCidx];

	    // pc_next = addr_next;

	    // state_next = IF5;
        // end
        // IF5: begin
        //     we_next = 1'b0;
        //     state_next = IF6;
        // end
        // IF6: begin
        //     inReg[IR1idx] = mem;
        //     ld[IR1idx] = 1'b1;
        //     inc[PCidx] = 1'b1;

        //     state_next = ID1;
        // end
        // X
        ID1: begin
            OC_next = outReg[IR0idx][15:12];

            inReg[MARidx] = {3'b000, outReg[IR0idx][10:8]};
            ld[MARidx] = 1'b1;
            opX_next = {3'b000, outReg[IR0idx][10:8]};

            state_next = ID2;
        end
        ID2: begin
            addr_next = outReg[MARidx];

            state_next = ID3;
        end
        ID3: begin
            we_next = 1'b0;

            state_next = ID4;
        end
        ID4: begin
            inReg[MDRidx] = mem;
            ld[MDRidx] = 1'b1;

            state_next = ID5;
        end
        ID5: begin
            // indirektno X
            if (outReg[IR0idx][11] == 1) begin
                inReg[MARidx] = {3'b000, outReg[MDRidx][2:0]};
                ld[MARidx] = 1'b1;
                opX_next = {3'b000, outReg[MDRidx][2:0]};

                state_next = ID6;
            end
            else begin
                opXdata_next = outReg[MDRidx];

                state_next = ID10; // skoci na razresavanje Y
            end
        end
        ID6: begin
            addr_next = outReg[MARidx];

            state_next = ID7;
        end
        ID7: begin
            we_next = 1'b0;

            state_next = ID8;
        end
        ID8: begin
            inReg[MDRidx] = mem;
            ld[MDRidx] = 1'b1;

            state_next = ID9;
        end
        ID9: begin
            opXdata_next = outReg[MDRidx];

            state_next = ID10;
        end

        // Y
        ID10: begin
            inReg[MARidx] = {3'b000, outReg[IR0idx][6:4]};
            ld[MARidx] = 1'b1;
            opY_next = {3'b000, outReg[IR0idx][6:4]};

            state_next = ID11;
        end
        ID11: begin
            addr_next = outReg[MARidx];

            state_next = ID12;
        end
        ID12: begin
            we_next = 1'b0;

            state_next = ID13;
        end
        ID13: begin
            inReg[MDRidx] = mem;
            ld[MDRidx] = 1'b1;

            state_next = ID14;
        end
        ID14: begin
            // indirektno Y
            if (outReg[IR0idx][7] == 1) begin
                inReg[MARidx] = {3'b000, outReg[MDRidx][2:0]};
                ld[MARidx] = 1'b1;
                opY_next = {3'b000, outReg[MDRidx][2:0]};

                state_next = ID15;
            end
            else begin
                opYdata_next = outReg[MDRidx];

                state_next = ID19; // skoci na razresavanje Z
            end
        end
        ID15: begin
            addr_next = outReg[MARidx];

            state_next = ID16;
        end
        ID16: begin
            we_next = 1'b0;

            state_next = ID17;
        end
        ID17: begin
            inReg[MDRidx] = mem;
            ld[MDRidx] = 1'b1;

            state_next = ID18;
        end
        ID18: begin
            opYdata_next = outReg[MDRidx];

            state_next = ID19;
        end

        // Z
        ID19: begin
            inReg[MARidx] = {3'b000, outReg[IR0idx][2:0]};
            ld[MARidx] = 1'b1;
            opZ_next = {3'b000, outReg[IR0idx][2:0]};

            state_next = ID20;
        end
        ID20: begin
            addr_next = outReg[MARidx];

            state_next = ID21;
        end
        ID21: begin
            we_next = 1'b0;

            state_next = ID22;
        end
        ID22: begin
            inReg[MDRidx] = mem;
            ld[MDRidx] = 1'b1;

            state_next = ID23;
        end
        ID23: begin
            // indirektno Z
            if (outReg[IR0idx][3] == 1) begin
                inReg[MARidx] = {3'b000, outReg[MDRidx][2:0]};
                ld[MARidx] = 1'b1;
                opZ_next = {3'b000, outReg[MDRidx][2:0]};

                state_next = ID24;
            end
            else begin
                opZdata_next = outReg[MDRidx];

                state_next = EX1; // skoci na EX
            end
        end
        ID24: begin
            addr_next = outReg[MARidx];

            state_next = ID25;
        end
        ID25: begin
            we_next = 1'b0;

            state_next = ID26;
        end
        ID26: begin
            inReg[MDRidx] = mem;
            ld[MDRidx] = 1'b1;

            state_next = ID27;
        end
        ID27: begin
            opZdata_next = outReg[MDRidx];

            state_next = EX1;
        end

        EX1: begin
            case (OC_reg)
                MOV: begin
                    if (opZ_reg == 4'h0) begin
                        inReg[MDRidx] = opYdata_reg;
                        ld[MDRidx] = 1'b1;
                        inReg[MARidx] = opX_reg;
                        ld[MARidx] = 1'b1;

                        state_next = EX2;
                    end
                    else begin
                        state_next = IF1;
                    end
                end
                ADD: begin
                    // if (opYdata_reg == 16'h0000) begin
                    //     aluA = opZdata_reg;
                    //     aluB = outReg[IR1idx];
                    //     aluOC = 3'b000;

                    //     inReg[MDRidx] = aluOUT;
                    //     ld[MDRidx] = 1'b1;
                    //     inReg[MARidx] = opX_reg;
                    //     ld[MARidx] = 1'b1;
                    // end
                    // else begin
                    //     // ... ovo sto imam ispod
                    // end
                    aluA = opYdata_reg;
                    aluB = opZdata_reg;
                    aluOC = 3'b000;
                    inReg[MDRidx] = aluOUT;
                    ld[MDRidx] = 1'b1;
                    inReg[MARidx] = opX_reg;
                    ld[MARidx] = 1'b1;

                    state_next = EX2;
                end
                SUB: begin
                    aluA = opYdata_reg;
                    aluB = opZdata_reg;
                    aluOC = 3'b001;
                    inReg[MDRidx] = aluOUT;
                    ld[MDRidx] = 1'b1;
                    inReg[MARidx] = opX_reg;
                    ld[MARidx] = 1'b1;

                    state_next = EX2;
                end
                MUL: begin
                    aluA = opYdata_reg;
                    aluB = opZdata_reg;
                    aluOC = 3'b010;
                    inReg[MDRidx] = aluOUT;
                    ld[MDRidx] = 1'b1;
                    inReg[MARidx] = opX_reg;
                    ld[MARidx] = 1'b1;

                    state_next = EX2;
                end
                DIV: begin
                    state_next = IF1;
                end
                IN: begin
                    if (control == 1'b0) begin
                        status_next = 1'b1;

                        state_next = EX1;
                    end
                    else begin
                        status_next = 1'b0;

                        inReg[MDRidx] = in;
                        ld[MDRidx] = 1'b1;
                        inReg[MARidx] = opX_reg;
                        ld[MARidx] = 1'b1;

                        state_next = EX2;
                    end
                end
                OUT: begin
                    out_next = opXdata_reg;

                    state_next = IF1;
                end
                STOP: begin
                    if (opX_reg != 4'h0) begin
                        out_next = opXdata_reg;
                    end 
                    else if (opY_reg != 4'h0) begin
                        out_next = opYdata_reg;
                    end 
                    else if (opZ_reg != 4'h0) begin
                        out_next = opZdata_reg;
                    end
                    state_next = HALT;
                end
                default: begin
                    
                end
            endcase
        end
        EX2: begin
            case (OC_reg)
                MOV: begin
                    addr_next = outReg[MARidx];
                    data_next = outReg[MDRidx];

                    state_next = EX3;
                end
                ADD: begin
                    addr_next = outReg[MARidx];
                    data_next = outReg[MDRidx];

                    state_next = EX3;
                end
                SUB: begin
                    addr_next = outReg[MARidx];
                    data_next = outReg[MDRidx];

                    state_next = EX3;
                end
                MUL: begin
                    addr_next = outReg[MARidx];
                    data_next = outReg[MDRidx];

                    state_next = EX3;
                end
                IN: begin
                    addr_next = outReg[MARidx];
                    data_next = outReg[MDRidx];

                    state_next = EX3;
                end
                default: begin
                    
                end
            endcase
        end
        EX3: begin
            case (OC_reg)
                MOV: begin
                    we_next = 1'b1;

                    state_next = IF1;
                end
                ADD: begin
                    we_next = 1'b1;

                    state_next = IF1;
                end
                SUB: begin
                    we_next = 1'b1;

                    state_next = IF1;
                end
                MUL: begin
                    we_next = 1'b1;

                    state_next = IF1;
                end
                IN: begin
                    we_next = 1'b1;

                    state_next = IF1;
                end
                default: begin
                    
                end
            endcase
        end
        HALT: begin
            state_next = HALT;
        end
        default: begin
            
        end
        endcase
    end       
endmodule