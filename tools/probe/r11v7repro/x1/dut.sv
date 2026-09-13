// v11u7 arm x1 — THE STOLEN (C) BRANCH.  A port-view interface parameter whose
// DEF-view Rhs is an assignment pattern CARRYING A TAGGED MEMBER but whose Lhs
// typespec is NOT a struct (a packed vector / packed array).  Pristine falls
// through to face (C) ("an operation default reduces to a bare typespec-less
// constant") and STRIPS the constant's typespec; the r11u7 arm steals that
// else-if, queues the cell, and the applier then DECLINES it (no struct
// typespec), so the strip never runs.
package q1;
  typedef struct packed { int unsigned DAT; } bus_t;
  typedef struct packed { bus_t BUS; } cfg_t;
endpackage
interface xif #(
    parameter q1::cfg_t     CFG = '{BUS: '{DAT: 32}},
    parameter logic [7:0]   MSK = '{default: 1'b1},
    parameter logic [1:0][3:0] PA  = '{4'h1, 4'h2},
    parameter int unsigned  SCA = 7
);
  localparam int unsigned W = CFG.BUS.DAT;
  logic [W-1:0] d;
endinterface
module leaf (xif p, output logic o);
  assign o = p.d[0];
endmodule
module top (output logic o);
  xif u ();
  leaf a0 (.p(u), .o(o));
endmodule
