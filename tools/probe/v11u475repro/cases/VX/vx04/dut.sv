// § caReduceLeavesOpKept475
// case equality against x and z digits
module top(output logic q, output logic r);
  parameter logic [3:0] P = 4'b10x1;
  assign q = P === 4'b10x1;
  assign r = P !== 4'b1z01;
endmodule
