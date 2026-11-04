// § caUnsizedRhsClonePerInst193
module m #(parameter bit P = 1) (input logic [7:0] x, output logic [7:0] y);
  assign y[3:0] = (P) ? x[3:0] : '0;
  assign y[7:4] = (P) ? x[7:4] : '0;
endmodule
module top (input logic [7:0] x, output logic [7:0] y1, output logic [7:0] y2);
  m #(.P(0)) u_a (.x(x), .y(y1));
  m #(.P(0)) u_b (.x(x), .y(y2));
endmodule
