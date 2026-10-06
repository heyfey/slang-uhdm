// § genIpsOvrParamOwner262 (gen-local LHS, width, whole right side)
module m #(parameter int Width = 32, parameter bit E = 0) (input logic [7:0] a, output logic [2:0] q);
  if (!E) begin : gn
    logic [2:0] t;
    assign t = a[0+:Width];
    assign q = t;
  end
endmodule
module top(input logic [7:0] a, output logic [2:0] q);
  m #(.Width(3)) u (.*);
endmodule
