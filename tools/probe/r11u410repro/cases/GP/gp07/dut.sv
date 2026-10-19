// § genLpUntypedDefNoTs410
module m #(parameter W = 8);
  for (genvar i = 0; i < 2; i++) begin : g
    localparam [31:0] S = W / 4;
    localparam signed T = W - 9;
    localparam U = W + 1;
    logic [S-1:0] x;
  end
endmodule
module top;
endmodule
