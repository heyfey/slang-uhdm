// § enumImportParentLastWriter180 (verifier: explicit body import of the enum in zmod, wildcard in amod, enum used in a struct in the package)
package p;
  typedef enum logic [1:0] {A, B, C} e_t;
  typedef struct packed { e_t k; logic v; } s_t;
endpackage
module zmod(input logic [2:0] x, output logic o);
  import p::e_t;
  e_t s;
  assign s = e_t'(x[1:0]);
  assign o = (s == p::B);
endmodule
module amod(input logic [2:0] x, output logic o);
  import p::*;
  s_t s;
  assign s = s_t'(x);
  assign o = (s.k == C);
endmodule
module top(input logic [2:0] x, output logic y1, y2);
  zmod uz(.x(x), .o(y1));
  amod ua(.x(x), .o(y2));
endmodule
