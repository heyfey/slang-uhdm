// § genIpsOvrParamOwner262 (width select as a system-call argument)
module m #(parameter int Width = 32, parameter bit E = 0) (input logic [7:0] a, output logic [2:0] q);
  if (!E) begin : gn
    assign q = $countones(a[0+:Width]);
  end
endmodule
module top(input logic [7:0] a, output logic [2:0] q);
  m #(.Width(3)) u (.*);
endmodule
