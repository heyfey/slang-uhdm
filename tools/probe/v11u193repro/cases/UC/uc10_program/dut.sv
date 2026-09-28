// § caUnsizedRhsClonePerInst193
program p (input logic c, output logic [3:0] y);
  assign y[1:0] = c ? 2'b1 : '0;
endprogram
module top (input logic c, output logic [3:0] y);
  p u_p (.c(c), .y(y));
endmodule
