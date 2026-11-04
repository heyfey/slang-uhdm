// § caUnsizedRhsClonePerInst193
module m #(parameter int P = 1) (input logic c, output logic [3:0] y);
  assign y[P] = c | 'h0;
endmodule
module top (input logic c, output logic [3:0] y1, output logic [3:0] y2);
  m #(.P(1)) u_a (.c(c), .y(y1));
  m #(.P(2)) u_b (.c(c), .y(y2));
endmodule
