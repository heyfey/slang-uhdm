// v11u34 v1 — the package's OWN CONSTANT context reads the pattern param
// UNQUALIFIED (no `q::PA` anywhere).  Surelog's getValue third arm
// (CompileExpression.cpp ~1090) matches a BARE name against the COMPONENT's
// own param_assigns, and for an expression compiled inside the package the
// component IS the package.
package q;
  typedef struct packed { int unsigned e; int unsigned m; } enc_t;
  localparam enc_t [0:2] PA = '{'{4, 3}, '{3, 2}, '{2, 1}};
  localparam logic [1:0][1:0][3:0] PV = '{'{4'h1, 4'h2}, '{4'h3, 4'h4}};
  localparam int unsigned Z = PA[0].e + PV[0][0];
endpackage
module v1 (output logic [31:0] o);
  assign o = q::Z;
endmodule
