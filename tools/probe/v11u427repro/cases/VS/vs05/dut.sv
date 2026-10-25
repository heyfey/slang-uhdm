// § sgnBinUntypedFreshTsUnsigned427
module top(output [15:0] o);
  parameter D = 4'SB1010;
  wire signed [7:0] w = D;
  assign o = D;
endmodule
