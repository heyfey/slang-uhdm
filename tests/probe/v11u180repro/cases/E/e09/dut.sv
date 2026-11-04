// § enumImportParentLastWriter180 (verifier: an importer module that is never instantiated beside the top importer)
package p;
  typedef enum logic [1:0] {A, B, C} e_t;
endpackage
module top(input logic [1:0] x, output logic o);
  import p::*;
  e_t s;
  assign s = e_t'(x);
  assign o = (s == B);
endmodule
module unused_mod(input logic [1:0] x, output logic o);
  import p::*;
  e_t s;
  assign s = e_t'(x);
  assign o = (s == A);
endmodule
