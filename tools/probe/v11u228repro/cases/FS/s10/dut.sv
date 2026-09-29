// § parseViewSizeExprEval228 — the last dimension of fixed shapes and dynamic dimensions under fixed ones
module dut (output logic [7:0] o1, o2, o3, o4);
  typedef enum logic [2:0] {A, B} e_t;
  e_t ev [4];
  bit [3:0] qa [$][2];
  bit [3:0] fd [3][];
  logic [1:0] l2 [2][3];
  wire [7:0] w1 = $size(ev, 2);
  wire [7:0] w2 = $size(qa, 2);
  wire [7:0] w3 = $size(fd);
  wire [7:0] w4 = $size(l2, 3);
  assign o1 = w1; assign o2 = w2; assign o3 = w3; assign o4 = w4;
endmodule
