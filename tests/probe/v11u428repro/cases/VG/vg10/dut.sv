// § uninstDefGenRegionCaUnlisted428
module m(input [3:0] a, output [3:0] o, output [3:0] q);
  generate
    if (1) begin: g
      assign q = a;
    end
    assign o = a;
  endgenerate
  generate
    case (1)
      1: begin: c end
    endcase
    assign q2 = a[0];
  endgenerate
endmodule
module top; endmodule
