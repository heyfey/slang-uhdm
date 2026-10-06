// § genIpsOvrParamOwner262 (an if-generate, the select a bit-select index and a part-select base: abstain shapes)
module sub #(parameter int Width = 4, parameter bit E = 1) (input logic [15:0] a, input logic [15:0] b, output logic o, output logic [3:0] p);
  if (E) begin : gn
    assign o = a[b[0 +: Width]];
    assign p = a[b[1 +: 2] +: Width];
  end
endmodule
module top(input logic [15:0] a, input logic [15:0] b, output logic o, output logic [3:0] p);
  sub #(.Width(4)) u(.a(a), .b(b), .o(o), .p(p));
endmodule
