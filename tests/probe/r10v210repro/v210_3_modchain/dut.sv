// verifier arm 3 — a MODULE's own def-view parameter chain (no import).
module v3sub;
  parameter M_LIT   = 5;
  parameter M_REF   = M_LIT;
  parameter M_EXPR  = M_LIT + 1;
  parameter M_REFREF= M_REF;
  localparam M_LOC  = M_REF;
endmodule
module v3mod;
  v3sub u();
endmodule
