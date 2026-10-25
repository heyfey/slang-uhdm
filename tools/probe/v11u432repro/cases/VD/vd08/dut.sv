// § unitParamSizeDimWide432
parameter D = 5;
module sub #(parameter D = 2)(input clk);
  logic [3:0] a [D];
endmodule
module m(input clk);
  logic [3:0] b [D];
  sub #(.D(7)) u(.clk(clk));
endmodule
