// § tpDefaultCaLhsUnparented146
module inner #(parameter int W = 4, parameter type data_t = logic [W-1:0])
  (input data_t i, output data_t o);
  generate if (W > 2) begin : g
    assign o = i;
  end endgenerate
endmodule
module top(input [3:0] a, output [3:0] b);
  inner u(.i(a), .o(b));
endmodule
