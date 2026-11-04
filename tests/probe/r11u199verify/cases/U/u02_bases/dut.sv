// § caUnsizedRhsClonePerInst193
module m (input logic c, input logic [7:0] x, output logic [7:0] y [5]);
  assign y[0] = c ? x : 'hF;
  assign y[1] = c ? x : 'o7;
  assign y[2] = c ? 'b1 : x;
  assign y[3] = c ? x : 'd3;
  assign y[4] = c ? x : 'z;
endmodule
module top (input logic c, input logic [7:0] x, output logic [7:0] a [5], output logic [7:0] b [5]);
  m u_a (.c(c), .x(x), .y(a));
  m u_b (.c(c), .x(x), .y(b));
endmodule
