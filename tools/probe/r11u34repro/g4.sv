// r11u34 grid g4 — SCOPED WHOLE-NAME read (`q::PA`), no select.
package q;
  typedef struct packed { int unsigned e; int unsigned m; } enc_t;
  localparam enc_t [0:2] PA = '{'{4, 3}, '{3, 2}, '{2, 1}};
  localparam logic [1:0][1:0][3:0] PV = '{'{4'h1, 4'h2}, '{4'h3, 4'h4}};
endpackage
module g4 (output logic [191:0] o, output logic [15:0] v);
  assign o = q::PA;
  assign v = q::PV;
endmodule
