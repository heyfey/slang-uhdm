// § parseViewSizeExprEval228 — bit, byte, int and enum vectors and a packed struct, whole-initializer $size of each
module dut (output logic [7:0] o1, o2, o3, o4, o5);
  typedef enum logic [3:0] {A, B} e_t;
  typedef struct packed { logic [2:0] a; logic b; } s_t;
  bit [5:0][2:0] b2;
  byte y;
  int i;
  e_t e;
  s_t s;
  wire [7:0] w1 = $size(b2);
  wire [7:0] w2 = $size(y);
  wire [7:0] w3 = $size(i);
  wire [7:0] w4 = $size(e);
  wire [7:0] w5 = $size(s);
  assign o1 = w1; assign o2 = w2; assign o3 = w3; assign o4 = w4; assign o5 = w5;
endmodule
