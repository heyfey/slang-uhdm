// § parseViewSizeExprEval228 — an enum-based and a byte-based variable, and a two-state int unpacked array, asked for dimension 1 and 2
module dut (output logic [7:0] o1, o2, o3, o4);
  typedef enum bit [2:0] {A, B} e_t;
  e_t ev [4];
  byte bv [2][3];
  int iv [6];
  wire [7:0] w1 = $size(ev, 1);
  wire [7:0] w2 = $size(bv, 2);
  wire [7:0] w3 = $size(iv, 2);
  wire [7:0] w4 = $size(bv);
  assign o1 = w1; assign o2 = w2; assign o3 = w3; assign o4 = w4;
endmodule
