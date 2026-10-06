// § genIpsOvrParamOwner262 (an if-generate, a macro-born indexed part select)
`define SEL(x, w) x[0 +: w]
module sub #(parameter int Width = 4, parameter bit E = 1) (input logic [15:0] a, output logic [3:0] o);
  if (E) begin : gn
    assign o = `SEL(a, Width);
  end
endmodule
module top(input logic [15:0] a, output logic [3:0] o);
  sub #(.Width(4)) u(.a(a), .o(o));
endmodule
