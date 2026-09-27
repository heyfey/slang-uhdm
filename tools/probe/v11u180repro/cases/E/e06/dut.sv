// § enumImportParentLastWriter180 (verifier: an interface ziface and a module amod import; the interface name is last)
package p;
  typedef enum logic [1:0] {A, B, C} e_t;
endpackage
interface ziface;
  import p::*;
  e_t s;
endinterface
module amod(input logic [1:0] x, output logic o);
  import p::*;
  e_t s;
  assign s = e_t'(x);
  assign o = (s == B);
endmodule
module top(input logic [1:0] x, output logic y);
  ziface zi();
  amod ua(.x(x), .o(y));
endmodule
