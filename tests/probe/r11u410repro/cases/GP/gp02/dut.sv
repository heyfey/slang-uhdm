// § genLpUntypedDefNoTs410
module m #(parameter W = 8);
  localparam A = W * 2;
  for (genvar i = 0; i < 2; i++) begin : g
    localparam S = A / 4;
    logic [S-1:0] x;
  end
endmodule
module top;
  m u();
endmodule
