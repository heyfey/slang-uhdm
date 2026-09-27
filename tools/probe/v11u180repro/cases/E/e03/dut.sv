// § enumImportParentLastWriter180 (verifier: module names differing in case: Zmod and amod)
package p;
  typedef enum logic [1:0] {A, B, C} e_t;
endpackage
module amod(input logic [1:0] x, output logic o);
  import p::*;
  e_t s;
  assign s = e_t'(x);
  assign o = (s == B);
endmodule
module Zmod(input logic [1:0] x, output logic o);
  import p::*;
  e_t s;
  assign s = e_t'(x);
  assign o = (s == C);
endmodule
module top(input logic [1:0] x, output logic y1, y2);
  Zmod uz(.x(x), .o(y1));
  amod ua(.x(x), .o(y2));
endmodule
