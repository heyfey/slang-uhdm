// § caUnsizedRhsClonePerInst193
module m (input logic c, input logic [3:0] x, output logic [3:0] y);
  assign y[3:0] = $unsigned(c ? x : '0);
endmodule
module top (input logic c, input logic [3:0] x, output logic [3:0] y1);
  m u_a (.c(c), .x(x), .y(y1));
endmodule
