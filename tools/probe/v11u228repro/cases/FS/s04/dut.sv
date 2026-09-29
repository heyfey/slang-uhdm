// § parseViewSizeExprEval228 — the dimension argument a parameter, and two declarators in one declaration
module dut #(parameter int D = 2) (output logic [7:0] o1, o2);
  bit [3:0][1:0][4:0] bp;
  wire [7:0] w1 = $size(bp, D), w2 = $size(bp, 3);
  assign o1 = w1; assign o2 = w2;
endmodule
