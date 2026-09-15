// v11u34 v2 — PER-PARAMETER granularity: only `q::PB` is read scoped; `q::PA`
// is never written anywhere.  Does golden stamp PA too (per-PACKAGE) or only
// PB (per-PARAMETER)?
package q;
  typedef struct packed { int unsigned e; int unsigned m; } enc_t;
  localparam enc_t [0:2] PA = '{'{4, 3}, '{3, 2}, '{2, 1}};
  localparam enc_t [0:2] PB = '{'{9, 8}, '{7, 6}, '{5, 4}};
  localparam logic [1:0][1:0][3:0] PV = '{'{4'h1, 4'h2}, '{4'h3, 4'h4}};
endpackage
module v2 (output logic [31:0] o);
  assign o = q::PB[0].e;
endmodule
