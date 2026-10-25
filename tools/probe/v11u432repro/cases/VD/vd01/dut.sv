// § unitParamSizeDimWide432
parameter D = 5;
module m(input clk, input [7:0] d [D], output [7:0] q);
  assign q = d[0];
endmodule
