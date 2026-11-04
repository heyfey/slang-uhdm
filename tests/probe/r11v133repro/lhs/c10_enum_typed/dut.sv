// § impPaLhsDisjointClone133
package p;
  typedef enum logic [1:0] {A, B, C} e_t;
  parameter e_t E = B;
  parameter int X = 2;
endpackage
module m import p::*; #(parameter int Q = X) (output e_t o);
  assign o = E;
endmodule
module top(output p::e_t o); m u(.o(o)); endmodule
