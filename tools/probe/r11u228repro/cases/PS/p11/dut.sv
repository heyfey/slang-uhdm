// § parseViewSizeExprEval228 — narrow and signed targets (the mask and the size), a typedef'd net type
module dut (output logic [7:0] o1, o2, o3);
  typedef logic [1:0] n2_t;
  bit [6:0][2:0] bw;
  wire n2_t w1 = $size(bw);
  wire signed [3:0] w2 = $size(bw);
  wire w3 = $size(bw);
  assign o1 = w1; assign o2 = w2; assign o3 = w3;
endmodule
