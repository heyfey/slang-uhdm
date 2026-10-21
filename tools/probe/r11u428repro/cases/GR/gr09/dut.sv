// § uninstDefGenRegionCaUnlisted428
module m #(parameter W) (input [W-1:0] a, output [W-1:0] o, output [W-1:0] p);
  assign o = a;
  for (genvar i = 0; i < 2; i++) begin: g
    assign p[i] = a[i];
  end
endmodule
module top; endmodule
