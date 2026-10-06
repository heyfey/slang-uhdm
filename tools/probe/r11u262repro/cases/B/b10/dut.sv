// § genIpsOvrParamOwner262 (select LHS, width on the right side)
module m #(parameter int Width = 32, parameter bit E = 0) (input logic [7:0] a, output logic [3:0] q);
  if (!E) begin : gn
    assign q[2:0] = a[0+:Width];
    assign q[3] = 1'b0;
  end
endmodule
module top(input logic [7:0] a, output logic [3:0] q);
  m #(.Width(3)) u (.*);
endmodule
