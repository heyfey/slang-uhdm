// § implicitPortParamListedFirst419
package pk;
  parameter Q = 9;
endpackage
module m import pk::*; #(parameter A = 4, int B = 2) (input [A-1:0] x);
  localparam L = A * Q;
endmodule
module top;
  logic [3:0] x;
  m #(.B(3)) u(x);
endmodule
