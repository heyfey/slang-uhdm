// § sizeReachFollowsWalker219v § ndaSizeFoldReach219 — $size of a variable whose first dimension is fixed and whose inner dimension is associative
module dut (output logic [7:0] o3);
  int ma [4][int];
  wire [7:0] w3 = $size(ma);
  assign o3 = w3;
endmodule
