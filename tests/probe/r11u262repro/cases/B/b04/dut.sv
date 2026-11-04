// § genIpsOvrParamOwner262 (nested if-generate two levels, width, whole right side)
module m #(parameter int Width = 32, parameter bit E = 0) (input logic [7:0] a, output logic [2:0] q);
  if (!E) begin : gn
    if (Width > 1) begin : gi
      assign q = a[0+:Width];
    end
  end
endmodule
module top(input logic [7:0] a, output logic [2:0] q);
  m #(.Width(3)) u (.*);
endmodule
