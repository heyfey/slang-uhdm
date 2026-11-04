// § genIpsOvrParamOwner262 (a for-generate, a typed overridden parameter as the whole-right-side indexed part-select width)
module sub #(parameter int Width = 4) (input logic [15:0] a, output logic [3:0] o [2]);
  for (genvar i = 0; i < 2; i++) begin : gf
    assign o[i] = a[0 +: Width];
  end
endmodule
module top(input logic [15:0] a, output logic [3:0] o [2]);
  sub #(.Width(4)) u(.a(a), .o(o));
endmodule
