// § fixedOuterAssocInnerReg223 § unsizedInnerSizeDeclines223 § ndaAdjSizeFoldSized223 — $size(x, 1) and $size(x) of a fixed-associative-fixed int array and of a fixed-associative logic-vector array, net initializers
module top(output logic [7:0] o1, output logic [7:0] o2, output logic [7:0] o3);
  int ma [2][int][3];
  logic [5:0] mb [3][string];
  wire [7:0] w1 = $size(ma, 1);
  wire [7:0] w2 = $size(ma);
  wire [7:0] w3 = $size(mb);
  assign o1 = w1; assign o2 = w2; assign o3 = w3;
endmodule
