// v11u69 v2 — THE ANCESTOR-INSTANCE NAMESAKE.  `bindVariable` recurses PAST
// `module_inst` into `scope->VpiParent()`, so a gen-local whose NAME is declared
// one HIERARCHY level up is found and `tps` is filled from THERE.  The widths
// differ so the source of `tps` is visible in the answer.
package p;
  typedef struct packed { int unsigned n; } cfg_t;
  localparam cfg_t LIT = '{n: 300};
endpackage

module leaf #(parameter p::cfg_t CFG = p::LIT)
  (input logic a_i, output logic [31:0] o_g);
  if (1) begin : gk
    logic [31:0] up_nw;    // name also declared in the PARENT, 8 bits there
    assign up_nw = CFG.n;
    assign o_g = up_nw;
  end
endmodule

module dut (input logic a_i, output logic [31:0] o_g);
  logic [7:0] up_nw;                    // the ANCESTOR-instance namesake
  leaf u_l (.a_i(a_i), .o_g(o_g));
  assign up_nw = 8'd0;
endmodule
