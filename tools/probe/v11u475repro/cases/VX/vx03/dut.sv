// § caReduceLeavesOpKept475
// unary plus over a parameter and over a literal
module top(output logic [3:0] y, output logic [3:0] z);
  parameter logic [3:0] P = 4'd6;
  assign y = +P;
  assign z = +4'd3;
endmodule
