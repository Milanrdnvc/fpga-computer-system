`include "uvm_macros.svh"
import uvm_pkg::*;

//---------------------------------------------------------
// Sequence Item
//---------------------------------------------------------
class reg_item extends uvm_sequence_item;
    rand bit cl;
    rand bit ld;
    rand bit [15:0] in;
    rand bit inc;
    rand bit dec;
    rand bit sr;
    rand bit ir;
    rand bit sl;
    rand bit il;

    constraint one_operation {
        (cl + ld + inc + dec + sr + sl) == 1;
    }

    bit [15:0] out;

    `uvm_object_utils_begin(reg_item)
        `uvm_field_int(cl, UVM_DEFAULT)
        `uvm_field_int(ld, UVM_DEFAULT)
        `uvm_field_int(in, UVM_ALL_ON)
        `uvm_field_int(inc, UVM_DEFAULT)
        `uvm_field_int(dec, UVM_DEFAULT)
        `uvm_field_int(sr, UVM_DEFAULT)
        `uvm_field_int(ir, UVM_DEFAULT)
        `uvm_field_int(sl, UVM_DEFAULT)
        `uvm_field_int(il, UVM_DEFAULT)
        `uvm_field_int(out, UVM_NOPRINT)
    `uvm_object_utils_end

    function new(string name="reg_item");
        super.new(name);
    endfunction

    virtual function string my_print();
        return $sformatf(
            "cl=%b ld=%b in=%h inc=%b dec=%b sr=%b ir=%b sl=%b il=%b out=%h",
            cl, ld, in, inc, dec, sr, ir, sl, il, out
        );
    endfunction
endclass

//---------------------------------------------------------
// Sequence
//---------------------------------------------------------
class generator extends uvm_sequence #(reg_item);

    `uvm_object_utils(generator)

    function new(string name = "generator");
        super.new(name);
    endfunction

    int num = 200;

    virtual task body();
        for (int i = 0; i < num; i++) begin
            reg_item item = reg_item::type_id::create("item");
            start_item(item);
            item.randomize();
            `uvm_info("Generator", $sformatf("Item %0d/%0d created", i + 1, num), UVM_LOW)
            item.print();
            finish_item(item);
        end
    endtask
endclass

//---------------------------------------------------------
// Driver
//---------------------------------------------------------
class driver extends uvm_driver #(reg_item);

    `uvm_component_utils(driver)

    function new(string name = "driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual reg_if#(16) vif;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual reg_if#(16))::get(this, "", "reg_vif", vif))
            `uvm_fatal("Driver", "No interface.")
    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        forever begin
            reg_item item;
            seq_item_port.get_next_item(item);
            `uvm_info("Driver", $sformatf("%s", item.my_print()), UVM_LOW)

            vif.cl <= item.cl;
            vif.ld <= item.ld;
            vif.in <= item.in;
            vif.inc <= item.inc;
            vif.dec <= item.dec;
            vif.sr <= item.sr;
            vif.ir <= item.ir;
            vif.sl <= item.sl;
            vif.il <= item.il;

            @(posedge vif.clk);
            seq_item_port.item_done();
        end
    endtask
endclass

//---------------------------------------------------------
// Monitor
//---------------------------------------------------------
class monitor extends uvm_monitor;

    `uvm_component_utils(monitor)

    function new(string name = "monitor", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual reg_if#(16) vif;
    uvm_analysis_port #(reg_item) mon_analysis_port;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual reg_if#(16))::get(this, "", "reg_vif", vif))
            `uvm_fatal("Monitor", "No interface.")
        mon_analysis_port = new("mon_analysis_port", this);
    endfunction

	virtual task run_phase(uvm_phase phase);
	  forever begin
		reg_item item = reg_item::type_id::create("item");
		
		@(posedge vif.clk);
		
		#1; 
		
		item.cl  = vif.cl;
		item.ld  = vif.ld;
		item.in  = vif.in;
		item.inc = vif.inc;
		item.dec = vif.dec;
		item.sr  = vif.sr;
		item.ir  = vif.ir;
		item.sl  = vif.sl;
		item.il  = vif.il;
		item.out = vif.out;

		`uvm_info("Monitor", $sformatf("Uhvatio: in=%h out=%h", item.in, item.out), UVM_LOW)
		mon_analysis_port.write(item);
	  end
	endtask
endclass

//---------------------------------------------------------
// Agent
//---------------------------------------------------------
class agent extends uvm_agent;

    `uvm_component_utils(agent)

    function new(string name = "agent", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    driver d0;
    monitor m0;
    uvm_sequencer #(reg_item) s0;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        d0 = driver::type_id::create("d0", this);
        m0 = monitor::type_id::create("m0", this);
        s0 = uvm_sequencer#(reg_item)::type_id::create("s0", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        d0.seq_item_port.connect(s0.seq_item_export);
    endfunction
endclass

//---------------------------------------------------------
// Scoreboard
//---------------------------------------------------------
class scoreboard extends uvm_scoreboard;
    `uvm_component_utils(scoreboard)
    `uvm_analysis_imp_decl(_mon)
    
    uvm_analysis_imp_mon #(reg_item, scoreboard) mon_analysis_imp;
    
    bit [15:0] ref_reg = 16'h0; 

    function new(string name = "scoreboard", uvm_component parent = null);
        super.new(name, parent);
        mon_analysis_imp = new("mon_analysis_imp", this);
    endfunction

    virtual function void write_mon(reg_item item);
        if (item.out !== ref_reg) begin
            `uvm_error("SCOREBOARD", $sformatf("FAIL! expected=%h got=%h", ref_reg, item.out))
        end else begin
            `uvm_info("SCOREBOARD", "PASS", UVM_LOW)
        end

        if (item.cl) begin
            ref_reg = 16'h0;
        end else if (item.ld) begin
            ref_reg = item.in;
        end else if (item.inc) begin
            ref_reg = ref_reg + 1;
        end else if (item.dec) begin
            ref_reg = ref_reg - 1;
        end else if (item.sr) begin
            ref_reg = {item.ir, ref_reg[15:1]};
        end else if (item.sl) begin
            ref_reg = {ref_reg[14:0], item.il};
        end
    endfunction
endclass

//---------------------------------------------------------
// Environment
//---------------------------------------------------------
class env extends uvm_env;

    `uvm_component_utils(env)

    function new(string name = "env", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    agent a0;
    scoreboard sb0;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        a0 = agent::type_id::create("a0", this);
        sb0 = scoreboard::type_id::create("sb0", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        a0.m0.mon_analysis_port.connect(sb0.mon_analysis_imp);
    endfunction
endclass

//---------------------------------------------------------
// Test
//---------------------------------------------------------
class test extends uvm_test;

    `uvm_component_utils(test)

    function new(string name = "test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual reg_if#(16) vif;

    env e0;
    generator g0;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual reg_if#(16))::get(this, "", "reg_vif", vif))
            `uvm_fatal("Test", "No interface.")
        e0 = env::type_id::create("e0", this);
        g0 = generator::type_id::create("g0");
    endfunction

    virtual function void end_of_elaboration_phase(uvm_phase phase);
        uvm_top.print_topology();
    endfunction

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this);

        vif.rst_n <= 0;
        #20 vif.rst_n <= 1;

        g0.start(e0.a0.s0);

        phase.drop_objection(this);
    endtask
endclass

//---------------------------------------------------------
// Interface
//---------------------------------------------------------
interface reg_if #(parameter DATA_WIDTH = 16) (input bit clk);
    logic rst_n;
    logic cl;
    logic ld;
    logic [DATA_WIDTH-1:0] in;
    logic inc;
    logic dec;
    logic sr;
    logic ir;
    logic sl;
    logic il;
    logic [DATA_WIDTH-1:0] out;
endinterface

//---------------------------------------------------------
// Testbench
//---------------------------------------------------------
module testbench_uvm;
    reg clk;

    reg_if#(16) dut_if (.clk(clk));

    register #(.DATA_WIDTH(16)) dut (
        .clk(dut_if.clk),
        .rst_n(dut_if.rst_n),
        .cl(dut_if.cl),
        .ld(dut_if.ld),
        .in(dut_if.in),
        .inc(dut_if.inc),
        .dec(dut_if.dec),
        .sr(dut_if.sr),
        .ir(dut_if.ir),
        .sl(dut_if.sl),
        .il(dut_if.il),
        .out(dut_if.out)
    );

    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    initial begin
        uvm_config_db#(virtual reg_if#(16))::set(null, "*", "reg_vif", dut_if);
        run_test("test");
    end
endmodule