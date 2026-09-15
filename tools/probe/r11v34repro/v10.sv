// v11u34 v10 — an IN-PACKAGE BARE WHOLE-NAME constant read of the pattern
// param (getValue's component->getParam_assigns arm, CompileExpression ~1090).
package q;
  typedef struct packed { int unsigned e; int unsigned m; } enc_t;
  localparam enc_t [0:2] PA = '{'{4, 3}, '{3, 2}, '{2, 1}};
  localparam logic [1:0][1:0][3:0] PV = '{'{4'h1, 4'h2}, '{4'h3, 4'h4}};
  localparam enc_t [0:2] ZA = PA;
  localparam logic [1:0][1:0][3:0] ZV = PV;
endpackage
module v10 (output logic [191:0] o, output logic [15:0] v);
  assign o = q::ZA;
  assign v = q::ZV;
endmodule
