// § paramAliasBoundRefUnstored144
package p;
  localparam int W = 4;
  typedef logic [W-1:0] t;
  parameter t Y = 3;
endpackage
module top(output int o);
  p::t Y;
  assign Y = p::Y;
  assign o = int'(Y);
endmodule
