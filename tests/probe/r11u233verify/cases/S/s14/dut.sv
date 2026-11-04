// § parseViewSizeExprEval228 § pvSizeNoElemDeclines228v — a signed narrow target that the count overflows, and an unsigned one
module dut (output logic [2:0] o1, o2);
  logic [1:0][4:0] x;
  wire signed [2:0] w1 = $size(x, 2);
  wire [2:0] w2 = $size(x, 2);
  assign o1 = w1; assign o2 = w2;
endmodule
