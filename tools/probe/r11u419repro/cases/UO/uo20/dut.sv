// § implicitPortPaLastIface419
package pk;
  parameter Q = 9;
endpackage
module m import pk::*; #(int A = 4) (input [A-1:0] x);
  localparam L = A * Q;
endmodule
module top;
  logic [3:0] x;
  m u(x);
endmodule
