// § enumImpDefOwner180v (verifier: header wildcard importers without casts; the winner nested two levels down)
package p;
  typedef enum logic [1:0] {A, B, C} e_t;
endpackage
module zleaf import p::*; (input logic [1:0] x, output logic o);
  e_t s;
  assign o = x[0];
endmodule
module mid import p::*; (input logic [1:0] x, output logic o);
  e_t s;
  zleaf l(.x(x), .o(o));
endmodule
module top(input logic [1:0] x, output logic o);
  mid m(.x(x), .o(o));
endmodule
