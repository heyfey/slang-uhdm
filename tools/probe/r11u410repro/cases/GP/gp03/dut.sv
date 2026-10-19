// § genLpUntypedDefNoTs410
module m #(parameter W = 8);
  if (W > 4) begin : g
    localparam S = W >> 1;
    localparam T = 3;
    logic [S-1:0] x;
  end
endmodule
module top;
  m u();
endmodule
