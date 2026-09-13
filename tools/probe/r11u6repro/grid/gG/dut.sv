// gG — a $bits(TYPE) query argument in the same position (the query-call
// family's other member): a TYPE name binds to no NamedValue, so neither the
// substitution nor the sparing rule may touch it.
package p;
  typedef logic [7:0] byte_t;
  typedef logic [$bits(byte_t)-1:0] vec_t;
  parameter vec_t V = 8'hAB;
endpackage
module top;
  import p::*;
  logic [7:0] x;
  assign x = V;
endmodule
