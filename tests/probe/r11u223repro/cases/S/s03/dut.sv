// § ndaAdjSizeFoldSized223 — $size of packed two-dimensional bit and logic variables: the generic-handler value, sized to the net and location-less
module dut (output logic [7:0] o1, o2);
  bit   [3:0][1:0] bp;
  logic [5:0][2:0] lp;
  wire [7:0] w1 = $size(bp);
  wire [3:0] w2 = $size(lp);
  assign o1 = w1; assign o2 = w2;
endmodule
