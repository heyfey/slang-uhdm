// § genIpsOvrParamOwner262 (an if-generate, the indexed part select in a concatenation inside an operation)
module sub #(parameter int Width = 4, parameter bit E = 1) (input logic [15:0] a, output logic [7:0] o);
  if (E) begin : gn
    assign o = {a[0 +: Width], a[8 +: Width]} ^ 8'hff;
  end
endmodule
module top(input logic [15:0] a, output logic [7:0] o);
  sub #(.Width(4)) u(.a(a), .o(o));
endmodule
