// § unitParamSizeDimWide432
localparam D = 16;
module m(input clk);
  logic [7:0] nRam[0:D-1];
  logic [7:0] q[D];
endmodule
