// § parseViewSizeExprEval228 § pvSizeNoElemDeclines228v — the operand dimension from a package parameter and a forward-declared typedef
package p;
  localparam int W = 6;
  typedef logic [W-1:0][1:0] t_t;
endpackage
module dut (output logic [7:0] o1, o2);
  p::t_t a;
  bit [p::W-1:0][2:0] b;
  wire [7:0] w1 = $size(a);
  wire [7:0] w2 = $size(b);
  assign o1 = w1; assign o2 = w2;
endmodule
