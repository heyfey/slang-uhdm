// § genIpsOvrParamOwner262 (an if-generate, the indexed part select inside a ternary)
module sub #(parameter int Width = 4, parameter bit E = 1) (input logic [15:0] a, input logic s, output logic [3:0] o);
  if (E) begin : gn
    assign o = s ? a[0 +: Width] : a[4 +: Width];
  end
endmodule
module top(input logic [15:0] a, input logic s, output logic [3:0] o);
  sub #(.Width(4)) u(.a(a), .s(s), .o(o));
endmodule
