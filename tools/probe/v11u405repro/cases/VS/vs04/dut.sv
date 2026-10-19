// § undefParamCastSizeTs405
module top; endmodule
module s (input logic [7:0] a, output logic [7:0] b); assign b = a; endmodule
module m #(parameter w) (input logic [7:0] i, output logic [7:0] o);
  s u (.a(w'(i)), .b(o));
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
