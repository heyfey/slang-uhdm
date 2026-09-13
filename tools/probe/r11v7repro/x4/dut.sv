// v11u7 arm x4 — an UNSIZED literal member AFTER the leading aggregate one.
// ExprEval resizes a tagged_pattern's constant whose VpiSize is -1 to the
// member width and rewrites its value/decompile (templates/ExprEval.cpp:
// 887-906); `flatten7` leaves it exactly as the def view built it.  The gate
// fires (member 0 is a nested pattern), so this is the applier's own face.
package q4;
  typedef struct packed { int unsigned DAT; } bus_t;
  typedef struct packed { bus_t BUS; logic [7:0] M; logic [3:0] Z; } cfg_t;
endpackage
interface xif #(parameter q4::cfg_t CFG = '{BUS: '{DAT: 32}, M: '1, Z: '0});
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
