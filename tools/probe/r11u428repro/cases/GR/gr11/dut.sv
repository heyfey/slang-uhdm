// § uninstDefGenRegionCaUnlisted428
module m (input [3:0] a, output [3:0] o, output [3:0] p);
  logic [3:0] q;
generate
  assign q = a;
  assign o = q;
endgenerate
  assign p = a;
endmodule
module top; endmodule
