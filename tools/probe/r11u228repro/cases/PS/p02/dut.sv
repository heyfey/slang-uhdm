// § parseViewSizeExprEval228 — the two-argument form on unpacked arrays of enums, structs and bit vectors
module dut (output logic [7:0] o1, o2, o3, o4);
  typedef enum logic [1:0] {A, B} e_t;
  typedef struct packed { logic [2:0] a; } s_t;
  e_t ea [4][2];
  s_t sa [3];
  bit [2:0] ba [5];
  wire [7:0] w1 = $size(ea, 2);
  wire [7:0] w2 = $size(sa, 1);
  wire [7:0] w3 = $size(ba, 2);
  wire [7:0] w4 = $size(ea, 3);
  assign o1 = w1; assign o2 = w2; assign o3 = w3; assign o4 = w4;
endmodule
