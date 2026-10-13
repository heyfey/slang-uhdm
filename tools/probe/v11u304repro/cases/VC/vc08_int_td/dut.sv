// § genCaCastTdAliasScopedName304
module top (input logic [7:0] a, output int y);
  typedef int i_t;
  if (1) begin : g
    assign y = i_t'(a);
  end
endmodule
