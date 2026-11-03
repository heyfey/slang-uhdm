// § caReduceLeavesOpKept475
// control: a signal operand, nothing constant
module top(input logic [3:0] a, output logic [3:0] y);
  parameter logic [3:0] P = 4'd6;
  assign y = a ^ P;
endmodule
