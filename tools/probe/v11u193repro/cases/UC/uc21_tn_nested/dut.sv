// § caUnsizedRhsClonePerInst193
module m #(parameter bit P = 1, parameter bit Q = 1) (input logic [7:0] x, output logic [7:0] y);
  assign y[3:0] = (P) ? ((Q) ? '0 : x[3:0]) : x[7:4];
endmodule
module top (input logic [7:0] x, output logic [7:0] y1, output logic [7:0] y2);
  m #(.P(1), .Q(1)) u_a (.x(x), .y(y1));
  m #(.P(1), .Q(0)) u_b (.x(x), .y(y2));
endmodule
