// § parseViewSizeExprEval228 — a string array, a real array and a queue of bits (the walker and the generic handler at their edges)
module dut (output logic [7:0] o1, o2);
  string sa [3];
  bit [3:0] q [$];
  wire [7:0] w1 = $size(sa);
  wire [7:0] w2 = $size(q);
  assign o1 = w1; assign o2 = w2;
endmodule
