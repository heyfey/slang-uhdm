// § parseViewSizeExprEval228 — unpacked arrays of unpacked structs, one and two dimensions
module dut (output logic [7:0] o1, o2, o3);
  typedef struct { logic [3:0] a; int b; } us_t;
  us_t ua [3];
  us_t ub [2][5];
  wire [7:0] w1 = $size(ua);
  wire [7:0] w2 = $size(ub, 2);
  wire [7:0] w3 = $size(ub);
  assign o1 = w1; assign o2 = w2; assign o3 = w3;
endmodule
