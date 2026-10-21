// § uninstDefGenRegionCaUnlisted428
module m(input [3:0] a, output [3:0] o, output [3:0] p);
  generate
    assign o = ~a;
    assign p = a;
  endgenerate
endmodule
module top; endmodule
