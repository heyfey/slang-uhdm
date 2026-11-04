// § ifaceHcCallArgByInst315
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top (input logic [1:0] ck, input logic s, output logic o);
  if (1) begin : g
    ifc u (.clk($signed(ck[s])));
  end
  assign o = g.u.sig[0];
endmodule
