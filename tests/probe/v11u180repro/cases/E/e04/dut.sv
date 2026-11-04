// § enumImportParentLastWriter180 (verifier: a package q re-exports p by import; zmod imports q, amod imports p)
package p;
  typedef enum logic [1:0] {A, B, C} e_t;
endpackage
package q;
  import p::*;
  localparam e_t QD = C;
endpackage
module zmod(input logic [1:0] x, output logic o);
  import q::*;
  assign o = (x == QD);
endmodule
module amod(input logic [1:0] x, output logic o);
  import p::*;
  e_t s;
  assign s = e_t'(x);
  assign o = (s == B);
endmodule
module top(input logic [1:0] x, output logic y1, y2);
  zmod uz(.x(x), .o(y1));
  amod ua(.x(x), .o(y2));
endmodule
