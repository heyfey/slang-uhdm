// § caUnsizedRhsClonePerInst193 § ucCloneUnnamesRanges193v
module m #(parameter int K = 3) (input logic c, input logic [7:0] x, output logic [7:0] y [2]);
  assign y[0][K:0] = c ? x[3:0] : '0;
  assign y[0][7:K+1] = x[7:4];
  assign y[1] = x;
endmodule
module top (input logic c, input logic [7:0] x, output logic [7:0] a [2], output logic [7:0] b [2]);
  m u_a (.c(c), .x(x), .y(a));
  m u_b (.c(c), .x(x), .y(b));
endmodule
