// § caUnsizedRhsClonePerInst193 § ucCloneUnnamesRanges193v
module m #(parameter int W = 4) (input logic c, input logic [7:0] x, output logic [7:0] y, output logic [7:0] z);
  assign {y[W-1:0], z[7:W]} = c ? x : '0;
  assign y[7:W] = c ? x[W-1:0] : 'h3;
  assign z[W-1:0] = c ? x[7:W] : '1;
endmodule
module top (input logic c, input logic [7:0] x, output logic [7:0] a, output logic [7:0] b, output logic [7:0] d, output logic [7:0] e);
  m #(.W(4)) u_a (.c(c), .x(x), .y(a), .z(b));
  m #(.W(4)) u_b (.c(c), .x(x), .y(d), .z(e));
endmodule
