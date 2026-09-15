// v11u34 v9 — the only reads are PROCEDURAL (always_comb), top level.
package q;
  typedef struct packed { int unsigned e; int unsigned m; } enc_t;
  localparam enc_t [0:2] PA = '{'{4, 3}, '{3, 2}, '{2, 1}};
  localparam logic [1:0][1:0][3:0] PV = '{'{4'h1, 4'h2}, '{4'h3, 4'h4}};
endpackage
module v9 (output logic [191:0] o, output logic [15:0] v);
  always_comb o = q::PA;
  always_comb v = q::PV;
endmodule
