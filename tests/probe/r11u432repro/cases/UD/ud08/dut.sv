// § unitParamSizeDimWide432
localparam D = 8;
module m(input clk);
  logic [7:0] q[D][2];
  logic [D-1:0] v;
endmodule
