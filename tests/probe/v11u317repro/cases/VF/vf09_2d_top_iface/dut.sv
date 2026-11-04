// § ifaceHcVarSelByInst317
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top (input logic [1:0][1:0] m, input logic s, output logic o);
  ifc u (.clk(m[s][1]));
  assign o = u.sig[0];
endmodule
