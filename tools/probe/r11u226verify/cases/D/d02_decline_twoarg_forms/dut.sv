// § unsizedInnerSizeDeclines223 § sizeDeclineTsInvalid223v § ndaSizeFoldReach219 — $size(x, 1) of a fixed-dynamic-fixed array and of a fixed-queue array, and $size of a fixed-associative-fixed array for d = 1, net initializers
module top(output logic [7:0] o1, output logic [7:0] o2, output logic [7:0] o3, output logic [7:0] o4);
  logic [3:0] m [2][][3];
  byte q [5][$];
  wire [7:0] w1 = $size(m, 1);
  int ma [2][int][3];
  wire [7:0] w2 = $size(ma, 1);
  wire [7:0] w3 = $size(ma);
  wire [7:0] w4 = $size(q, 1);
  assign o1 = w1; assign o2 = w2; assign o3 = w3; assign o4 = w4;
endmodule
