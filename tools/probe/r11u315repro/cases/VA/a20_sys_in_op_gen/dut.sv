// § genIfaceHcCallArgUnbound315
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top (input logic a, input logic b, output logic o);
  if (1) begin : g
    ifc u (.clk(b & $signed(a)));
    assign o = u.sig[0];
  end
endmodule
