// § caUnsizedRhsClonePerInst193
module m #(parameter logic [7:0] F = '1) (input logic c, input logic [7:0] x, output logic [7:0] y [2]);
  localparam logic [7:0] G = 'x;
  assign y[0] = c ? x : F;
  assign y[1] = c ? G : x;
endmodule
module top (input logic c, input logic [7:0] x, output logic [7:0] a [2], output logic [7:0] b [2]);
  m u_a (.c(c), .x(x), .y(a));
  m u_b (.c(c), .x(x), .y(b));
endmodule
