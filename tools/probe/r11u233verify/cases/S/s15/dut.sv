// § parseViewSizeExprEval228 § pvSizeNoElemDeclines228v — controls the law leaves: a variable initializer and an assign statement (bytes must not move) beside a net declaration
module dut (output logic [7:0] o1, o2, o3);
  bit [3:0][1:0] b;
  logic [7:0] v = $size(b);
  wire [7:0] w2;
  assign w2 = $size(b);
  wire [7:0] w3 = $size(b);
  assign o1 = v; assign o2 = w2; assign o3 = w3;
endmodule
