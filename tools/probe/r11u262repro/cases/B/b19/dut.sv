// § genIpsOvrParamOwner262 (width select on an outside-net member path and in an interface instance)
interface ifc #(parameter int Width = 32, parameter bit E = 0) (input logic [7:0] a);
  logic [2:0] q;
  if (!E) begin : gn
    assign q = a[0+:Width];
  end
endinterface
module top(input logic [7:0] a, output logic [2:0] q);
  ifc #(.Width(3)) i (.a(a));
  assign q = i.q;
endmodule
