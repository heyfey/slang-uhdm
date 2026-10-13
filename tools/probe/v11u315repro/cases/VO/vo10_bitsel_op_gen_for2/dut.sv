// § ifaceHcOpSelByInst315
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top (input logic [3:0] ck, output logic o);
  for (genvar i = 0; i < 2; i++) begin : g
    ifc u (.clk(ck[i] & ck[i+2]));
  end
  assign o = g[0].u.sig[0];
endmodule
