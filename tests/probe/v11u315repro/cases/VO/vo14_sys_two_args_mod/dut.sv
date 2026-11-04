// § ifaceHcCallArgByInst315
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top (input logic [3:0] v, input logic a, output logic o);
  ifc u (.clk($countones(v) == 2 && a));
  assign o = u.sig[0];
endmodule
