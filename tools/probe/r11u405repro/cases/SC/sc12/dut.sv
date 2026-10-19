// § undefParamCastSizeTs405
module m #(parameter w = $clog2(16)) (input logic [7:0] i, output logic [7:0] o, output logic [7:0] p);
  assign o = w'(i);
  assign p = w'(i+1);
endmodule
module top(input logic [7:0] a, output logic [7:0] b, output logic [7:0] c);
  m #(.w(4)) u(a, b, c);
endmodule
