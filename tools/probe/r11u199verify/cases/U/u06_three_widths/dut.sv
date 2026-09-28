// § caUnsizedRhsClonePerInst193 § ucCloneUnnamesRanges193v
module m #(parameter int W = 4) (input logic c, input logic [W-1:0] x, output logic [W-1:0] y [2]);
  assign y[0] = c ? x : '1;
  assign y[1][W-1:0] = c ? '0 : x;
endmodule
module top (input logic c, input logic [7:0] x, output logic [1:0] a [2], output logic [3:0] b [2], output logic [7:0] d [2]);
  m #(.W(2)) u_a (.c(c), .x(x[1:0]), .y(a));
  m #(.W(4)) u_b (.c(c), .x(x[3:0]), .y(b));
  m #(.W(8)) u_c (.c(c), .x(x), .y(d));
endmodule
