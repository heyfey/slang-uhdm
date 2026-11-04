// § genIfaceHcInnerRefUnbound313
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top (input logic a, output logic o);
  if (1) begin : g
    logic l;
    assign l = ~a;
    ifc u (.clk(l & a));
  end
  assign o = g.u.sig[0];
endmodule
