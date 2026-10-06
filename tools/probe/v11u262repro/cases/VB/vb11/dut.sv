// § genIpsOvrParamOwner262 (an if-generate, a localparam derived from the typed parameter as the width, two instances)
module sub #(parameter int Width = 4, parameter bit E = 1) (input logic [15:0] a, output logic [3:0] o);
  localparam int W2 = Width;
  if (E) begin : gn
    assign o = a[0 +: W2];
  end
endmodule
module top(input logic [15:0] a, output logic [3:0] o, output logic [3:0] p);
  sub #(.Width(4)) u(.a(a), .o(o));
  sub v(.a(a), .o(p));
endmodule
