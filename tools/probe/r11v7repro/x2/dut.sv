// v11u7 arm x2 — the `default:` key BESIDE a named key, with the FIRST declared
// member an explicit nested pattern.  r11u7's residue R4 claims "the gate
// excludes the shape in practice (member 0 must be an explicit nested
// pattern)" — here member 0 IS an explicit nested pattern and member 1 is
// covered only by `default:`, so the gate fires and `memberValue7`'s POSITIONAL
// fallback hands member 1 the tagged_pattern's own Pattern object, where
// ExprEval clone_trees the default operand (templates/ExprEval.cpp:880-884).
package q2;
  typedef struct packed { int unsigned DAT; } bus_t;
  typedef struct packed { bus_t BUS; int unsigned SCA; } cfg_t;
endpackage
interface xif #(parameter q2::cfg_t CFG = '{BUS: '{DAT: 32}, default: 0});
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
