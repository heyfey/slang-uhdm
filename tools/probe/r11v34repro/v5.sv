// v11u34 v5 — the only `q::PA` read lives in ANOTHER PACKAGE's localparam.
package q;
  typedef struct packed { int unsigned e; int unsigned m; } enc_t;
  localparam enc_t [0:2] PA = '{'{4, 3}, '{3, 2}, '{2, 1}};
  localparam logic [1:0][1:0][3:0] PV = '{'{4'h1, 4'h2}, '{4'h3, 4'h4}};
endpackage
package r;
  localparam q::enc_t [0:2] RA = q::PA;
  localparam logic [1:0][1:0][3:0] RV = q::PV;
endpackage
module v5 (output logic [191:0] o, output logic [15:0] v);
  assign o = r::RA;
  assign v = r::RV;
endmodule
