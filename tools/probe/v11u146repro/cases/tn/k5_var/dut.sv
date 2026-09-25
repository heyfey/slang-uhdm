// § tpDefaultCaLhsUnparented146
module inner #(parameter int W = 8, parameter type data_t = logic [W-1:0])
  (input data_t i, output data_t o);
  data_t t;
  assign t = i;
  assign o = t;
endmodule
module top(input [7:0] a, output [7:0] b);
  inner u(.i(a), .o(b));
endmodule
