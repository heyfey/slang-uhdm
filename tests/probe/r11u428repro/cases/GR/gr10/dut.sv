// § uninstDefGenRegionCaUnlisted428
module m #(parameter W = 4) (input [W-1:0] a, output [W-1:0] o, output [W-1:0] p);
generate
  genvar i;
  for (i = 0; i < 2; i++) begin: g
    assign p[i] = a[i];
  end
  assign o = a;
endgenerate
endmodule
module top; endmodule
