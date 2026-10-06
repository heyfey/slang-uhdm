// § genIpsOvrParamOwner262 (width select as a ternary branch)
module m #(parameter int Width = 32, parameter bit E = 0) (input logic [7:0] a, input logic s, output logic [2:0] q);
  if (!E) begin : gn
    assign q = s ? a[0+:Width] : a[4+:Width];
  end
endmodule
module top(input logic [7:0] a, input logic s, output logic [2:0] q);
  m #(.Width(3)) u (.*);
endmodule
