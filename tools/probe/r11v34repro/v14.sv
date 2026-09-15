// v11u34 v14 — MIXED operands: a nested pattern beside a plain constant, in a
// package param with NO reader, and the same read scoped in v14b.
package q;
  typedef struct packed { int unsigned e; int unsigned m; } enc_t;
  localparam enc_t [0:2] PM = '{'{4, 3}, 64'd7, '{2, 1}};
  localparam logic [2:0][1:0][3:0] VM = '{'{4'h1, 4'h2}, 8'h34, '{4'h5, 4'h6}};
endpackage
module v14 (output logic [31:0] o);
  assign o = 0;
endmodule
