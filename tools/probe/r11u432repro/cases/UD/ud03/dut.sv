// § unitParamSizeDimWide432
localparam D = 336;
module m(input clk);
  reg [7:0] nRam[D];
endmodule
module top(input clk);
  m u(.clk(clk));
endmodule
