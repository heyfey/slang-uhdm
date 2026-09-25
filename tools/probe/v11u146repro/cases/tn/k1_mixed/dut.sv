// § tpDefaultCaLhsUnparented146
module inner #(parameter int DataWidth = 8, parameter type data_t = logic [DataWidth-1:0])
  (input data_t i, output data_t o);
  assign o = i;
endmodule
module top(input [7:0] a, output [7:0] b, input [3:0] c, output [3:0] d);
  inner u1(.i(a), .o(b));
  inner #(.data_t(logic [3:0])) u2(.i(c), .o(d));
endmodule
