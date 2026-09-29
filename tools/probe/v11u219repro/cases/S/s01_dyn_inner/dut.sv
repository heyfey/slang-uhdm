// § sizeReachFollowsWalker219v § ndaSizeFoldReach219 — $size of a variable whose first dimension is fixed and whose inner dimension is dynamic
module dut (output logic [7:0] o1);
  logic [1:0] md [2][];
  wire [7:0] w1 = $size(md);
  assign o1 = w1;
endmodule
