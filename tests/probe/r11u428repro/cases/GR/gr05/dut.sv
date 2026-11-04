// § uninstDefGenRegionCaUnlisted428
module top(input [3:0] a, output [3:0] o, output [3:0] p);
generate
  for (genvar i = 0; i < 2; i++) begin: g
    assign p[i] = a[i];
  end
  assign o = a;
endgenerate
endmodule
