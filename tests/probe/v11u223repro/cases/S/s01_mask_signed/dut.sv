// § ndaAdjSizeFoldSized223
module dut (output logic [7:0] o1, o2, o3, o4);
  bit   [3:0][1:0] bp;
  logic [5:0][2:0] lp;
  wire [1:0] w1 = $size(bp);
  wire signed [7:0] w2 = $size(lp);
  wire [0:7] w3 = $size(bp);
  wire signed [2:0] w4 = $size(lp);
  assign o1 = w1; assign o2 = w2; assign o3 = w3; assign o4 = w4;
endmodule
