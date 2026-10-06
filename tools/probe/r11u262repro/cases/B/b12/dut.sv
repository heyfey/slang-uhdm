// § genIpsOvrParamOwner262 (two instances with different overrides)
module m #(parameter int Width = 32, parameter bit E = 0) (input logic [7:0] a, output logic [2:0] q);
  if (!E) begin : gn
    assign q = a[0+:Width];
  end
endmodule
module top(input logic [7:0] a, output logic [2:0] q, output logic [2:0] r);
  m #(.Width(3)) u (.a(a), .q(q));
  m #(.Width(2)) v (.a(a), .q(r));
endmodule
