// § caUnsizedRhsClonePerInst193
module m #(parameter bit P = 1) (input logic [7:0] x, output logic [7:0] y);
  assign y[3:0] = (P) ? '1 : x[3:0];
endmodule
module top (input logic [7:0] x, output logic [7:0] y1, output logic [7:0] y2, output logic [7:0] y3);
  m #(.P(1)) u_a (.x(x), .y(y1));
  m #(.P(0)) u_b (.x(x), .y(y2));
  m #(.P(1)) u_c (.x(x), .y(y3));
endmodule
