// v11u34 v11 — WILDCARD-IMPORTED bare whole-name read in a CONSTANT context
// (a module localparam).  No `q::PA` text anywhere.
package q;
  typedef struct packed { int unsigned e; int unsigned m; } enc_t;
  localparam enc_t [0:2] PA = '{'{4, 3}, '{3, 2}, '{2, 1}};
  localparam logic [1:0][1:0][3:0] PV = '{'{4'h1, 4'h2}, '{4'h3, 4'h4}};
endpackage
module v11 import q::*; (output logic [191:0] o, output logic [15:0] v);
  localparam enc_t [0:2] C = PA;
  localparam logic [1:0][1:0][3:0] D = PV;
  assign o = C;
  assign v = D;
endmodule
