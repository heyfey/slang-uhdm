// § ifaceHcCallArgByInst315
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top (input logic a, output logic o);
  if (1) begin : g
    ifc u (.clk($signed(a)));
    assign o = u.sig[0];
  end
endmodule
