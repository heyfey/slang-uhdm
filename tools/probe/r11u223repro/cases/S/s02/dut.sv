// § unsizedInnerSizeDeclines223 — $size of a dynamic and a queue inner dimension (the base segfaulted in the elaborated view; Surelog fails)
module dut (output logic [7:0] o1, o2);
  int md [4][];
  int mq [2][$];
  wire [7:0] w1 = $size(md);
  wire [7:0] w2 = $size(mq);
  assign o1 = w1; assign o2 = w2;
endmodule
