// § ndaAdjSizeFoldSized223 § unsizedInnerSizeDeclines223
module dut (output logic [7:0] o1, o2);
  bit [3:0][1:0] bp;
  int md [3][];
  for (genvar i = 0; i < 2; i++) begin : g
    wire [2:0] w = $size(bp);
  end
  wire [7:0] wd = $size(md, 1);
  assign o1 = g[0].w; assign o2 = wd;
endmodule
