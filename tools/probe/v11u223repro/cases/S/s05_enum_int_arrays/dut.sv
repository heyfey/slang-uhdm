// § ndaAdjSizeFoldSized223
module dut (output logic [7:0] o1, o2, o3, o4);
  typedef enum logic [2:0] {E0, E1, E2} e_t;
  e_t ea [5];
  int ia [6];
  e_t eb [2][3];
  wire [2:0] w1 = $size(ea, 2);
  wire [7:0] w2 = $size(ia, 2);
  wire [3:0] w3 = $size(eb, 3);
  wire signed [5:0] w4 = $size(ia, 2);
  assign o1 = w1; assign o2 = w2; assign o3 = w3; assign o4 = w4;
endmodule
