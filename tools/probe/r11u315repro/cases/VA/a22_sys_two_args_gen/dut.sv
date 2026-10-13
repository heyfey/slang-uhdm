// § genIfaceHcCallArgUnbound315
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top (input logic [3:0] a, input logic b, output logic o);
  if (1) begin : g
    ifc u (.clk($countones(a) == 1 ^ b));
    assign o = u.sig[0];
  end
endmodule
