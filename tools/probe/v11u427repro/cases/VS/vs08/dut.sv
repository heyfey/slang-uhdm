// § sgnBinUntypedFreshTsUnsigned427
module top(output [7:0] o);
  parameter D = 4'sb1010;
  parameter E = D + 1;
  assign o = E;
endmodule
