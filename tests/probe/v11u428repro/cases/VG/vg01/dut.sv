// § uninstDefGenRegionCaUnlisted428
module m(input [3:0] a, output [3:0] o, output [3:0] p);
  generate
    if (1) begin: g
      assign p = a;
    end
    assign o = ~a;
  endgenerate
endmodule
module top; endmodule
