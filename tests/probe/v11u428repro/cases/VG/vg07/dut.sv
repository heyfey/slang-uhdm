// § uninstDefGenRegionCaUnlisted428
module m(input [3:0] a, output [3:0] o);
  generate
    if (1) begin: g end
    assign o = a;
  endgenerate
endmodule
module m2(input [3:0] a, output [3:0] o);
  m u(.a(a), .o(o));
endmodule
module top(input [3:0] a, output [3:0] o);
  assign o = a;
endmodule
