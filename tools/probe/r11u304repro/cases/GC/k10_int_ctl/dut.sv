// § genCaCastTdAliasScopedName304
module top (input logic a, output int y);
  if (1) begin : g
    assign y = int'(a);
  end
endmodule
