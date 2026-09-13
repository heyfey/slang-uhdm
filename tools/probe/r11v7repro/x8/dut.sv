// v11u7 arm x8 — the `default:` key written FIRST, a named key SECOND.
// `memberValue7` matches member 0 (BUS) BY NAME to operand 1, then falls back
// POSITIONALLY for member 1 (SCA) and lands on operand 1 AGAIN — the same
// nested aggregate — where ExprEval clone_trees the `default:` operand for
// every uncovered member (templates/ExprEval.cpp:876-884).  The gate fires
// because member 0's value IS a nested pattern.
package q8;
  typedef struct packed { int unsigned DAT; } bus_t;
  typedef struct packed { bus_t BUS; int unsigned SCA; } cfg_t;
endpackage
interface xif #(parameter q8::cfg_t CFG = '{default: 0, BUS: '{DAT: 32}});
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
