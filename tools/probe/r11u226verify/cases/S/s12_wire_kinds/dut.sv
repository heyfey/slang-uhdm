// § ndaSizeFoldReach219 § ndaAdjSizeFoldSized223 — folded $size into wand, uwire, a signed 3-bit net (masked), and a $size inside an expression (not a whole initializer)
module top(output logic [7:0] o0, output logic [7:0] o1, output logic signed [2:0] o2, output logic [7:0] o3);
  logic [1:0] m [3][7];
  wand [7:0] w0 = $size(m, 2);
  uwire [7:0] w1 = $size(m);
  wire signed [2:0] w2 = $size(m, 2);
  wire [7:0] w3 = $size(m, 2) + 1;
  assign o0 = w0; assign o1 = w1; assign o2 = w2; assign o3 = w3;
endmodule
