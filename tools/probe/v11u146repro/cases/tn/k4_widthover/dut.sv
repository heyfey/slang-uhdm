// § tpDefaultCaLhsUnparented146
module inner #(parameter int W = 8, parameter type data_t = logic [W-1:0])
  (input data_t i, output data_t o);
  assign o = i;
endmodule
module top(input [3:0] a, output [3:0] b);
  inner #(.W(4)) u(.i(a), .o(b));
endmodule
