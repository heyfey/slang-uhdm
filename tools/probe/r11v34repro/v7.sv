// v11u34 v7 — the only `q::` reads are a GENERATE-IF condition and an
// always_comb body (constant context / procedural, neither a param decl).
package q;
  typedef struct packed { int unsigned e; int unsigned m; } enc_t;
  localparam enc_t [0:2] PA = '{'{4, 3}, '{3, 2}, '{2, 1}};
  localparam logic [1:0][1:0][3:0] PV = '{'{4'h1, 4'h2}, '{4'h3, 4'h4}};
endpackage
module v7 (output logic [191:0] o, output logic [15:0] v);
  if (q::PV != 0) begin : gA
    assign o = q::PA;
  end else begin : gB
    assign o = 0;
  end
  always_comb v = q::PV;
endmodule
