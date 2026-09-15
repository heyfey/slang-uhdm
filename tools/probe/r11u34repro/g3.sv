// r11u34 grid g3 — WILDCARD-IMPORTED UNQUALIFIED read of the same params.
package q;
  typedef struct packed { int unsigned e; int unsigned m; } enc_t;
  localparam enc_t [0:2] PA = '{'{4, 3}, '{3, 2}, '{2, 1}};
  localparam logic [1:0][1:0][3:0] PV = '{'{4'h1, 4'h2}, '{4'h3, 4'h4}};
endpackage
module g3 import q::*; (output logic [31:0] o);
  assign o = PA[0].e + PV[0][0];
endmodule
