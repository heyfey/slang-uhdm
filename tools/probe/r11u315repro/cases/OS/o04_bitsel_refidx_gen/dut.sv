// § ifaceHcOpSelByInst315
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top (input logic [1:0] ck, input logic s, input logic a, output logic o);
  if (1) begin : g
    ifc u (.clk(ck[s] & a));
    assign o = u.sig[0];
  end
endmodule
