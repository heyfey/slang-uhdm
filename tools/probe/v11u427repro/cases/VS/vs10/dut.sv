// § sgnBinUntypedFreshTsUnsigned427
module sub #(parameter D = 4'sb1010) (output [7:0] o);
  assign o = D;
endmodule
module top(output [7:0] o);
  sub #(.D(3)) u(o);
endmodule
