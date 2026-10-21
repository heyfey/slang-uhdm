// § uninstDefGenRegionCaUnlisted428
module m #(parameter W) (input [W-1:0] a, output [W-1:0] o, output [W-1:0] p);
  assign p = a;
generate
  genvar i;
  for (i = 0; i < 2; i++) begin: g
  end
  assign o = a;
endgenerate
endmodule
module top; endmodule
