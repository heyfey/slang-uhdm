// § ndaSizeFoldReach219 — the two-argument form over every dimension kind: an unpacked then packed dimension, a plain vector, an int, a sized literal dimension, a dimension past the last
module dut (output logic [7:0] o1, o2, o3, o4, o5, o6);
  logic [3:0] m [2][3];
  logic [9:0] v;
  int         i;
  wire [7:0] w1 = $size(m, 2);
  wire [7:0] w2 = $size(m, 3);
  wire [7:0] w3 = $size(v, 1);
  wire [7:0] w4 = $size(i, 1);
  wire [7:0] w5 = $size(m, 2'd1);
  assign o1 = w1; assign o2 = w2; assign o3 = w3;
  assign o4 = w4; assign o5 = w5; assign o6 = 8'd0;
endmodule
