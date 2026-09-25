// § enumAliasClone161 — a module alias of an enum with a signed 2-state base and explicit values
module top(output logic signed [3:0] o);
  typedef enum bit signed [3:0] {N = -2, P = 3} e_t;
  typedef e_t f_t;
  f_t v;
  assign v = N;
  assign o = v;
endmodule
