// § tpDefaultCaLhsUnparented146
module inner #(parameter int W = 4, parameter type T = logic [W-1:0]) (input T i, output T o);
  assign o = i;
endmodule
module top(input [3:0] a [2], output [3:0] b [2]);
  inner u[1:0] (.i(a), .o(b));
endmodule
