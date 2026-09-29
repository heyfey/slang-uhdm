// § sizeDeclineTsInvalid223v — $size of a fixed-then-dynamic and a fixed-then-queue array (the base segfaulted in the elaborated view; r11u223's placeholder made the adjuster write an invented UINT:0; the call now stays; Surelog fails on these)
module dut (output logic [7:0] o1, o2, o3, o4);
  int md [4][];
  logic [3:0] mq [2][$];
  int m7 [2][][int];
  wire [7:0] w1 = $size(md);
  wire [7:0] w2 = $size(mq, 1);
  wire [7:0] w3 = $size(m7);
  if (1) begin : g
    wire [7:0] w4 = $size(md);
    assign o4 = w4;
  end
  assign o1 = w1; assign o2 = w2; assign o3 = w3;
endmodule
