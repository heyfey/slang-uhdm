// § enumAliasClone161 — an alias that adds an unpacked dimension to a module enum (not a plain alias: the law must abstain)
module top(output logic [1:0] o);
  typedef enum logic [1:0] { A, B, C } e_t;
  typedef e_t f_t [2];
  f_t v;
  assign v[0] = B;
  assign v[1] = C;
  assign o = v[1];
endmodule
