// § genIpsOvrParamOwner262 (an if-generate, the select on the left side and a generate-local net on the right)
module sub #(parameter int Width = 4, parameter bit E = 1) (input logic [15:0] a, output logic [15:0] o);
  if (E) begin : gn
    logic [15:0] t;
    assign t = a;
    assign o[0 +: Width] = t[4 +: Width];
  end
endmodule
module top(input logic [15:0] a, output logic [15:0] o);
  sub #(.Width(4)) u(.a(a), .o(o));
endmodule
