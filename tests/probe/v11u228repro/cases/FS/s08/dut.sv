// § parseViewSizeExprEval228 — a net operand (array_net of logic, logic net) beside bit variables, and a 64-bit target
module dut (output logic [7:0] o1, o2, output logic [63:0] o3);
  wire [3:0] an [5][2];
  wire [2:0][3:0] ln;
  bit [9:0][1:0] bv;
  wire [7:0] w1 = $size(an, 2);
  wire [7:0] w2 = $size(ln, 2);
  wire [63:0] w3 = $size(bv);
  assign o1 = w1; assign o2 = w2; assign o3 = w3;
endmodule
