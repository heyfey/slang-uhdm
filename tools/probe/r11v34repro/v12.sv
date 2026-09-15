// v11u34 v12 — THREE-LEVEL nested pattern, package param, NO reader.
package q;
  typedef struct packed { int unsigned e; int unsigned m; } enc_t;
  localparam enc_t [0:1][0:1] P3 = '{'{'{4, 3}, '{3, 2}}, '{'{2, 1}, '{1, 0}}};
  localparam logic [1:0][1:0][1:0][3:0] V3 =
      '{'{'{4'h1, 4'h2}, '{4'h3, 4'h4}}, '{'{4'h5, 4'h6}, '{4'h7, 4'h8}}};
endpackage
module v12 (output logic [31:0] o);
  assign o = 0;
endmodule
