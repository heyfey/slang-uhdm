// § genCallArgInnerBlockOnly317
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top (input logic a, output logic o);
  if (1) begin : g
    logic l;
    assign l = ~a;
    if (1) begin : h
      ifc u (.clk($signed(l) & a));
    end
  end
  assign o = g.h.u.sig[0];
endmodule
