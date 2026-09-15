// v11u34 v3 — the only `q::PA` read is inside a MODULE-BODY localparam
// declaration (ParameterDeclaration syntax, which the landed scan excludes).
// Whole-name reads only: Surelog rejects `q::PA[0].e` in a constant context.
package q;
  typedef struct packed { int unsigned e; int unsigned m; } enc_t;
  localparam enc_t [0:2] PA = '{'{4, 3}, '{3, 2}, '{2, 1}};
  localparam logic [1:0][1:0][3:0] PV = '{'{4'h1, 4'h2}, '{4'h3, 4'h4}};
endpackage
module v3 (output logic [191:0] o, output logic [15:0] v);
  localparam q::enc_t [0:2] CP = q::PA;
  localparam logic [1:0][1:0][3:0] CV = q::PV;
  assign o = CP;
  assign v = CV;
endmodule
