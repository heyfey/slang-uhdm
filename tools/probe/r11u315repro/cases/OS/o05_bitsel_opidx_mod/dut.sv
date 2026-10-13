// § ifaceHcOpSelByInst315
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top (input logic [3:0] ck, input logic [1:0] s, input logic a, output logic o);
  ifc u (.clk(a | ck[s+1]));
  assign o = u.sig[0];
endmodule
