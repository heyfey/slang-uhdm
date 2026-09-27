// § enumImpDefOwner180v (verifier: two instantiated importers, the alphabetically last one instantiated twice)
package p;
  typedef enum logic [1:0] {A, B, C} e_t;
endpackage
module zmod(input logic [1:0] x, output logic o);
  import p::*;
  e_t s;
  always_comb s = e_t'(x);
  assign o = (s == B);
endmodule
module amod(input logic [1:0] x, output logic o);
  import p::*;
  e_t t;
  always_comb t = e_t'(x);
  assign o = (t == C);
endmodule
module top(input logic [1:0] x, output logic y1, y2, y3);
  zmod uz0(.x(x), .o(y1));
  zmod uz1(.x(x), .o(y3));
  amod ua(.x(x), .o(y2));
endmodule
