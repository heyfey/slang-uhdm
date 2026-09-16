// r11u55 ROAD E arm — MULTI-INSTANCE and OVERRIDDEN PARAMETER.
// `writeCont_assign` runs per ELABORATED INSTANCE over `netlist->cont_assigns()`
// and `clone_tree`s the assign per instance, so two instances of the same
// definition with DIFFERENT parameter values must carry DIFFERENT folded
// constants — and the DEFINITION listing must keep the written hier_path once.
// This is the cell that proves the fold is per-instance substitution of a clone
// and not a shared object.
package p;
  typedef struct packed { int unsigned n; logic [63:0] base; } cfg_t;
  localparam cfg_t LIT  = '{n: 3,  base: 64'h1000};
  localparam cfg_t LIT2 = '{n: 21, base: 64'h2000};
endpackage
module leaf #(parameter p::cfg_t CFG = p::LIT)
            (output logic [31:0] o_n, output logic [63:0] o_b);
  assign o_n = CFG.n;
  assign o_b = CFG.base;
endmodule
module dut (output logic [31:0] a_n, output logic [63:0] a_b,
            output logic [31:0] b_n, output logic [63:0] b_b,
            output logic [31:0] c_n, output logic [63:0] c_b);
  leaf u_def                       (.o_n(a_n), .o_b(a_b));   // default LIT
  leaf #(.CFG(p::LIT2)) u_ovr      (.o_n(b_n), .o_b(b_b));   // overridden
  leaf #(.CFG('{n: 7, base: 64'h3000})) u_lit (.o_n(c_n), .o_b(c_b)); // inline pattern
endmodule
