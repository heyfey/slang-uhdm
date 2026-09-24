// v11u34 v13 — NAMED-KEY (structured) nested pattern, package param, NO reader.
package q;
  typedef struct packed { int unsigned e; int unsigned m; } enc_t;
  typedef struct packed { enc_t a; enc_t b; } pair_t;
  localparam pair_t S = '{a: '{4, 3}, b: '{2, 1}};
endpackage
module v13 (output logic [31:0] o);
  assign o = 0;
endmodule
