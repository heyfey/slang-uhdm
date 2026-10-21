// § uninstDefGenRegionCaUnlisted428
module top(input [3:0] a, output [3:0] o, output [3:0] p);
  assign p = a;
generate
  assign o = a;
endgenerate
endmodule
