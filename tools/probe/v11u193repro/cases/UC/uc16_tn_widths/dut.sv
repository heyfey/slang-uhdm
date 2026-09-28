// § ucCloneUnnamesRanges193v
module m #(parameter bit P = 1, parameter int W = 4) (input logic [7:0] x, output logic [7:0] y);
  assign y[W-1:0] = (P) ? x[W-1:0] : '1;
endmodule
module top (input logic [7:0] x, output logic [7:0] y1, output logic [7:0] y2);
  m #(.P(0), .W(4)) u_a (.x(x), .y(y1));
  m #(.P(0), .W(8)) u_b (.x(x), .y(y2));
endmodule
