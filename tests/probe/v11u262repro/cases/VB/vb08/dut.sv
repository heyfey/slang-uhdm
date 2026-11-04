// § genIpsOvrParamOwner262 (an if-generate in an interface, whole right side)
interface ifc #(parameter int Width = 4, parameter bit E = 1) ();
  logic [15:0] a;
  logic [3:0] o;
  if (E) begin : gn
    assign o = a[0 +: Width];
  end
endinterface
module top(output logic [3:0] o);
  ifc #(.Width(4)) i();
  assign o = i.o;
endmodule
