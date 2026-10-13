// § ifaceHcVarSelByInst317
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top (input logic [1:0][1:0][1:0] m3, input logic s, input logic a, output logic o);
  ifc u (.clk(m3[1][0][s] & a));
  assign o = u.sig[0];
endmodule
