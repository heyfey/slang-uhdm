// § fixedOuterAssocInnerReg223 § unsizedInnerSizeDeclines223
module dut (output logic [7:0] o1, o2, o3);
  int ma [4][int];
  logic [7:0] ms [2][string];
  bit [3:0] mb [3][int];
  wire [7:0] w1 = $size(ma, 1);
  wire [7:0] w2 = $size(ms);
  wire [7:0] w3 = $size(mb);
  assign o1 = w1; assign o2 = w2; assign o3 = w3;
endmodule
