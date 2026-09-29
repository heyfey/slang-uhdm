// § ndaAdjSizeFoldSized223
module dut (output logic [7:0] o1, o2, o3);
  bit [3:0][1:0] bp;
  wire [7:0] w1 = $size(bp) + 1;
  wire [7:0] w2;
  assign w2 = $size(bp);
  logic [3:0] v3 = $size(bp);
  assign o1 = w1; assign o2 = w2; assign o3 = v3;
endmodule
