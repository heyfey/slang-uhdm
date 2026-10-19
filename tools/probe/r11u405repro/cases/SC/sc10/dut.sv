// § undefParamCastSizeTs405
module m #(parameter w) (input logic [7:0] i, output logic [7:0] o);
  assign o = w'(i);
endmodule
module top(input logic [7:0] a, output logic [7:0] b);
  m #(.w(4)) u(a, b);
endmodule
