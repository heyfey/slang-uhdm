// § uninstDefGenRegionCaUnlisted428
module m(input [3:0] a, output [3:0] o);
  wire [3:0] w;
  generate
    genvar i;
    for (i = 0; i < 4; i++) begin: g
      assign w[i] = a[i];
    end
    assign o = w;
  endgenerate
endmodule
module top(input [3:0] a, output [3:0] o);
  m u(.a(a), .o(o));
endmodule
