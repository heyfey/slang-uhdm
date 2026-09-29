// § ndaAdjSizeFoldSized223
module dut (output logic [7:0] o1, o2, o3);
  typedef logic [5:0] w6_t;
  bit   [3:0][1:0] bp;
  logic [5:0][2:0] lp;
  wire w6_t w1 = $size(bp);
  wire [1:0][3:0] w2 = $size(lp);
  wire [69:0] w3 = $size(lp);
  assign o1 = w1; assign o2 = w2; assign o3 = w3[7:0];
endmodule
