// § genIpsOvrParamOwner262 (an if-generate inside a for-generate, a whole-right-side indexed part select)
module sub #(parameter int Width = 4, parameter bit E = 1) (input logic [15:0] a, output logic [3:0] o [2]);
  for (genvar i = 0; i < 2; i++) begin : gf
    if (E) begin : gn
      assign o[i] = a[0 +: Width];
    end
  end
endmodule
module top(input logic [15:0] a, output logic [3:0] o [2]);
  sub #(.Width(4)) u(.a(a), .o(o));
endmodule
