// § enumImportParentLastWriter180 (verifier: a parameterized importer instantiated twice, beside a smaller-named importer)
package p;
  typedef enum logic [1:0] {A, B, C} e_t;
endpackage
module mmod #(parameter int W = 1) (input logic [1:0] x, output logic [W-1:0] o);
  import p::*;
  e_t s;
  assign s = e_t'(x);
  assign o = {W{s == B}};
endmodule
module bmod(input logic [1:0] x, output logic o);
  import p::*;
  e_t s;
  assign s = e_t'(x);
  assign o = (s == A);
endmodule
module top(input logic [1:0] x, output logic y0, output logic [1:0] y1, output logic y2);
  mmod #(1) u0(.x(x), .o(y0));
  mmod #(2) u1(.x(x), .o(y1));
  bmod u2(.x(x), .o(y2));
endmodule
