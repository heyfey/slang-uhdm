// § ifaceHcVarSelByInst317
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top (input logic [1:0][1:0] m, input logic s, input logic a, output logic o);
  if (1) begin : g
    ifc u (.clk(m[s][0] & a));
  end
  assign o = g.u.sig[0];
endmodule
