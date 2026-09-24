// § paramAliasBoundRefUnstored144
package p;
  localparam int W = 4;
  typedef logic [W-1:0] t;
  parameter t Y = 3;
endpackage
module top(output int o);
  assign o = int'(p::Y);
endmodule
