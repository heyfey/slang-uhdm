// § genIpsOvrParamOwner262 (if-generate, the module's own overridden header parameter as the indexed part-select width, whole right side: Earlgrey #464077 / #446024, from r11u256repro G/g23)
module m #(parameter int Width = 32, parameter bit E = 0) (input logic [7:0] a, output logic [2:0] q);
  if (E) begin : gs
    assign q = '0;
  end else begin : gn
    assign q = a[0+:Width];
  end
endmodule
module top(input logic [7:0] a, output logic [2:0] q);
  m #(.Width(3)) u (.*);
endmodule
