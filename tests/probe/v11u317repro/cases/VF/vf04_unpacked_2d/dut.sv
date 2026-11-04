// § ifaceHcVarSelByInst317
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top (input logic arr [2][2], input logic s, input logic a, output logic o);
  ifc u (.clk(arr[s][0] & a));
  assign o = u.sig[0];
endmodule
