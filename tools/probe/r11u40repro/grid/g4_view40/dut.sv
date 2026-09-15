// r11u40 g4_view40 — THE VIEW, and WHICH OVERRIDE ACTUALS reach the hop road.
// Every arm instantiates the SAME child (vw40) so the DEFINITION copy of its
// bound is one object and the ELABORATED copies are one per instance.  The
// arms differ only in what the override actual is written as.  Distinct values
// keep the pool multiset attributable:
//   u_def 8(default)  u_hop 32  u_hopx 36  u_gen 28  u_twin 32(×2)
package p40;
  typedef struct packed { int unsigned DAT; } bus_t;
  typedef struct packed { bus_t BUS; } cfg_t;
endpackage

interface tif40 #(parameter p40::cfg_t CFG = '{BUS: '{DAT: 32}});
  logic [CFG.BUS.DAT-1:0] data;            // the INTERFACE's OWN bound
  modport sub (input data);
endinterface

module vw40 #(parameter int unsigned W = 8) (input logic clk);
  logic [W-1:0] v;
  always_ff @(posedge clk) v <= '0;
endmodule

module holder40 #(parameter int unsigned HP = 24) (input logic clk);
  logic unused;
  assign unused = clk;
endmodule

// A — NO override at all: the declaration default (8).
module w_def40 (input logic clk);
  vw40 u_def (.clk(clk));
endmodule

// B — the corpus shape: the modport hop, bare member read (32).
module w_hop40 (input logic clk, tif40.sub s);
  vw40 #(.W(s.CFG.BUS.DAT)) u_hop (.clk(clk));
endmodule

// C — the modport hop inside an EXPRESSION (32+4 = 36).
module w_hopx40 (input logic clk, tif40.sub s);
  vw40 #(.W(s.CFG.BUS.DAT + 4)) u_hopx (.clk(clk));
endmodule

// D — NOT ON THIS GRID.  A hierarchical read of a sibling MODULE INSTANCE's
//     parameter (`#(.W(u_hold.HP))`) is refused by slang outright —
//     "reference to 'HP' by hierarchical name is not allowed in a constant
//     expression" — and an arm whose compile fails teaches error recovery,
//     not golden.  The interface-port hop below is the corpus's own shape.

// E — the modport hop inside a GENERATE loop (28 through tif28).
module w_gen40 (input logic clk, tif40.sub s);
  for (genvar gi = 0; gi < 1; gi++) begin : gl
    vw40 #(.W(s.CFG.BUS.DAT)) u_gen (.clk(clk));
  end
endmodule

// F — the SAME hop twice in one module: two instances, one written actual.
module w_twin40 (input logic clk, tif40.sub s);
  vw40 #(.W(s.CFG.BUS.DAT)) u_tw1 (.clk(clk));
  vw40 #(.W(s.CFG.BUS.DAT)) u_tw2 (.clk(clk));
endmodule

module g4_view40 (input logic clk);
  tif40                             s ();
  tif40 #(.CFG('{BUS: '{DAT: 28}})) s28();
  w_def40  u_a (.clk(clk));
  w_hop40  u_b (.clk(clk), .s(s.sub));
  w_hopx40 u_c (.clk(clk), .s(s.sub));
  w_gen40  u_e (.clk(clk), .s(s28.sub));
  w_twin40 u_f (.clk(clk), .s(s.sub));
endmodule
