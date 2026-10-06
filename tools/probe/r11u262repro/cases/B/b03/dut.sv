// § genIpsOvrParamOwner262 (if-generate, overridden parameter as the indexed part-select BASE, whole right side)
module m #(parameter int Width = 32, parameter bit E = 0) (input logic [7:0] a, output logic [2:0] q);
  if (!E) begin : gn
    assign q = a[Width+:3];
  end
endmodule
module top(input logic [7:0] a, output logic [2:0] q);
  m #(.Width(3)) u (.*);
endmodule
