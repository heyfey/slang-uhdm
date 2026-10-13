// § genSysArgInnerUnbound317
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top (input logic a, input logic b, input logic c, output logic o);
  if (1) begin : g
    ifc u (.clk($signed(a ? b : c)));
  end
  assign o = g.u.sig[0];
endmodule
