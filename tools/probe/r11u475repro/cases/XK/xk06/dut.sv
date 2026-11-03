// § caReduceLeavesOpKept475
// XNOR, case equality and wildcard equality as a whole right side, and XOR nested under +
module top(output logic [3:0] y, output logic q, output logic r, output logic [3:0] z);
  parameter logic [3:0] A = 4'd3;
  parameter logic [3:0] B = 4'd5;
  assign y = A ^~ B;
  assign q = A !== B;
  assign r = A ==? B;
  assign z = (A ^ B) + 4'd1;
endmodule
