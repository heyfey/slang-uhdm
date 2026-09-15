// v5_patonly35 — THE SHARPEST BREAK ATTEMPT: a type-parameter anonymous
// aggregate default whose type is used ONLY by an assignment-pattern
// localparam (the copy Surelog's flattenPatternAssignments CLONES and
// REDUCES), beside one used by NOTHING but its own declaration.  If golden's
// ONLY copy at such a cell were the reduced clone, the law would move a
// matching fold to a mismatching operation.
package c5v35;
  localparam int PW = 24;
  typedef struct packed { int XLEN; } cfg_t;
  localparam cfg_t Cfg = '{XLEN: 48};
endpackage

module v5_patonly35 #(parameter int W = 8) (input logic clk, output logic o);
  // used ONLY by the pattern localparam
  localparam type pat_t = struct packed {
    logic [W-1:0]                 pa;
    logic [c5v35::Cfg.XLEN-1:0]   pb;
  };
  localparam pat_t PK = '{pa: '0, pb: '0};

  // used by NOTHING but the declaration itself
  localparam type dead_t = struct packed {
    logic [W-1:0] da;
  };

  always_comb o = PK.pa[0] ^ clk;
endmodule
