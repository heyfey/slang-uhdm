// § ifaceHcOpSelByInst315
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top (input logic [3:0] ck, input logic a, input logic b, output logic o);
  ifc u (.clk(ck[2] ? a : b));
  assign o = u.sig[0];
endmodule
