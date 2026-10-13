// § ifaceConnLeafVarSel317
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top (input logic [1:0][1:0] m, input logic a, input logic s, input logic t, output logic o);
  ifc u (.clk(m[1][s] | a));
  assign o = u.sig[0];
endmodule
