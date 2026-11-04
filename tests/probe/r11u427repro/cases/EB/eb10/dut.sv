// § sgnBinUntypedFreshTsUnsigned427
module sub #(parameter S = 3'sb101, parameter T = 8'sb1000_0000)(input a, output o);
  localparam L = 2'sb10;
  assign o = a;
endmodule
module top(input a, output [1:0] o);
  sub u1(.a(a), .o(o[0]));
  sub #(.T(8'd3)) u2(.a(a), .o(o[1]));
endmodule
