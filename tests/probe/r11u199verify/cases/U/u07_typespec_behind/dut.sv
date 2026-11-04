// § caUnsizedRhsClonePerInst193
module m (input logic c, input logic [7:0] x, output logic [7:0] y [2]);
  logic [7:0] k;
  assign k = '1;
  assign y[0] = c ? x : k;
  assign y[1] = c ? x : 8'($unsigned('1));
endmodule
module top (input logic c, input logic [7:0] x, output logic [7:0] a [2], output logic [7:0] b [2]);
  m u_a (.c(c), .x(x), .y(a));
  m u_b (.c(c), .x(x), .y(b));
endmodule
