// § uninstDefGenRegionCaUnlisted428
module m #(parameter W) (input [W-1:0] a, output [W-1:0] o);
  generate
    if (W > 1) begin: g end
    assign o = a;
  endgenerate
endmodule
module top(input [3:0] a, output [3:0] o);
  m #(4) u(.a(a), .o(o));
endmodule
