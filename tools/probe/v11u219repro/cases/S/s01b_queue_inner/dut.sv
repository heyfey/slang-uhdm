// § sizeReachFollowsWalker219v § ndaSizeFoldReach219 — $size of a variable whose first dimension is fixed and whose inner dimension is a queue
module dut (output logic [7:0] o2);
  int mq [3][$];
  wire [7:0] w2 = $size(mq);
  assign o2 = w2;
endmodule
