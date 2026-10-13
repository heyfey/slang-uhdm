// § ifaceConnLeafVarSel317
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top (input logic [1:0][1:0] m, input logic s, input logic a, output logic o);
  ifc u (.clk(a & m[s][0]));
  assign o = u.sig[0];
endmodule
