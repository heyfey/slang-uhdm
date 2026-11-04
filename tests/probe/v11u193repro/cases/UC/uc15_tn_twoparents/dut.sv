// § caUnsizedRhsClonePerInst193
module m #(parameter bit P = 1) (input logic [7:0] x, output logic [7:0] y [2]);
  assign y[0] = (P) ? x : '0;
  assign y[1] = x;
endmodule
module pa (input logic [7:0] x, output logic [7:0] y [2]);
  m #(.P(0)) u (.x(x), .y(y));
endmodule
module pb (input logic [7:0] x, output logic [7:0] y [2]);
  m #(.P(0)) u (.x(x), .y(y));
endmodule
module top (input logic [7:0] x, output logic [7:0] y [2], output logic [7:0] z [2]);
  pa a (.x(x), .y(y));
  pb b (.x(x), .y(z));
endmodule
