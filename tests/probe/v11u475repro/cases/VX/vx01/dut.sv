// § caReduceLeavesOpKept475
// literal-only operands as a whole right side
module top(output logic [3:0] y, output logic q, output logic [3:0] z);
  assign y = 4'b1010 ^ 4'b0101;
  assign q = 4'd3 === 4'd3;
  assign z = 4'hc ~^ 4'h3;
endmodule
