// § ifaceHcVarSelByInst317
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top (input logic [1:0][1:0] m, input logic [2:0] k, input logic s, input logic a, output logic o);
  ifc u (.clk(m[k[s+1]][0] & a));
  assign o = u.sig[0];
endmodule
