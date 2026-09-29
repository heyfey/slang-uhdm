// § parseViewSizeExprEval228 — a dynamic array and an associative array (dynamic dimensions)
module dut (output logic [7:0] o1, o2);
  bit [3:0] da [];
  bit [3:0] aa [int];
  wire [7:0] w1 = $size(da);
  wire [7:0] w2 = $size(aa);
  assign o1 = w1; assign o2 = w2;
endmodule
