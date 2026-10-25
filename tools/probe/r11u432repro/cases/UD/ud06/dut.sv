// § unitParamSizeDimWide432
localparam D = 16;
module m(input clk);
  logic [7:0] q[D];
  if (1) begin : g
    logic [3:0] r[D];
  end
endmodule
