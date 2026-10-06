// § genIpsOvrParamOwner262 (constant slots in an if-generate: replication count, cast width, part-select bound beside the indexed width)
module m #(parameter int Width = 32, parameter bit E = 0) (input logic [7:0] a, output logic [2:0] q, output logic [2:0] r);
  if (!E) begin : gn
    assign q = a[0+:Width] & {Width{a[7]}};
    assign r = Width'(a[Width-1:0]);
  end
endmodule
module top(input logic [7:0] a, output logic [2:0] q, output logic [2:0] r);
  m #(.Width(3)) u (.*);
endmodule
