// § ifaceHcCallArgByInst315
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top #(parameter int W = 4) (input logic a, output logic o);
  ifc u (.clk(a & ($clog2(W) == 2)));
  assign o = u.sig[0];
endmodule
