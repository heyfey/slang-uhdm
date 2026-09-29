// § parseViewSizeExprEval228 — controls the law leaves: a parameter operand, a variable initializer, an assign statement, a select operand
module dut (output logic [7:0] o1, o2, o3, o4);
  parameter bit [3:0][1:0] P = '0;
  bit [3:0][1:0] bp;
  wire [7:0] w1 = $size(P);
  logic [7:0] v2 = $size(bp);
  wire [7:0] w3;
  assign w3 = $size(bp);
  wire [7:0] w4 = $size(bp[1]);
  assign o1 = w1; assign o2 = v2; assign o3 = w3; assign o4 = w4;
endmodule
