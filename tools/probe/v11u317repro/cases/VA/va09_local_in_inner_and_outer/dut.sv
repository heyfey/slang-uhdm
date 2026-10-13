// § genIfaceInnerLocalKeepsBind317
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top (input logic a, output logic o);
  if (1) begin : g
    logic l;
    assign l = a;
    if (1) begin : h
      logic l;
      assign l = ~a;
      ifc u (.clk(l & g.l));
    end
  end
  assign o = g.h.u.sig[0];
endmodule
