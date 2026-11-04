// § genIfaceHcCallArgUnbound315
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top (input logic [1:0] a, output logic o);
  if (1) begin : g
    ifc u (.clk($isunknown(a)));
  end
  assign o = g.u.sig[0];
endmodule
