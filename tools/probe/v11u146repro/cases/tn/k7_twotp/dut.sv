// § tpDefaultCaLhsUnparented146
module inner #(parameter int W = 4, parameter type a_t = logic [W-1:0], parameter type b_t = logic [2*W-1:0])
  (input a_t i, output a_t o, input b_t j, output b_t p);
  assign o = i;
  always_comb p = j;
endmodule
module top(input [3:0] a, output [3:0] b, input [7:0] c, output [7:0] d);
  inner u(.i(a), .o(b), .j(c), .p(d));
endmodule
