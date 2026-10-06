// § genIpsOvrParamOwner262 (untyped overridden parameter, width)
module m #(parameter Width = 32, parameter bit E = 0) (input logic [7:0] a, output logic [2:0] q);
  if (!E) begin : gn
    assign q = a[0+:Width];
  end
endmodule
module top(input logic [7:0] a, output logic [2:0] q);
  m #(.Width(3)) u (.*);
endmodule
