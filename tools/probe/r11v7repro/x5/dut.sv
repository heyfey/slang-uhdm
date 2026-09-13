// v11u7 arm x5 — THREE members, keys written OUT of declaration order, the
// first DECLARED member an aggregate (so the gate fires), plus a THREE-level
// nest.  Exercises `flatten7`'s reorder and its per-member typespec stamping
// against ExprEval's own `tmp[i]` reorder (templates/ExprEval.cpp:824-871).
package q5;
  typedef struct packed { int unsigned DAT; } bus_t;
  typedef struct packed { bus_t BUS; int unsigned SEQ; } mid_t;
  typedef struct packed { mid_t MID; int unsigned SCA; logic [7:0] TAIL; } cfg_t;
endpackage
interface xif #(parameter q5::cfg_t CFG = '{TAIL: 8'hA5, SCA: 9,
                                            MID: '{SEQ: 3, BUS: '{DAT: 32}}});
  localparam int unsigned W = CFG.MID.BUS.DAT;
  logic [W-1:0] d;
endinterface
module leaf (xif p, output logic o);
  assign o = p.d[0];
endmodule
module top (output logic o);
  xif u ();
  leaf a0 (.p(u), .o(o));
endmodule
