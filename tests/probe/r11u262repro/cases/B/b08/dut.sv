// § genIpsOvrParamOwner262 (width select as an operand of an operation: nested)
module m #(parameter int Width = 32, parameter bit E = 0) (input logic [7:0] a, input logic [2:0] b, output logic [2:0] q);
  if (!E) begin : gn
    assign q = a[0+:Width] ^ b;
  end
endmodule
module top(input logic [7:0] a, input logic [2:0] b, output logic [2:0] q);
  m #(.Width(3)) u (.*);
endmodule
