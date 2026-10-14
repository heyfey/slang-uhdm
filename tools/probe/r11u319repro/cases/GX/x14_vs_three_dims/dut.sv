// § ifaceHcVarSelWholeByInst319
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top (input logic [1:0][1:0][1:0] m3, input logic [1:0] s, input logic [1:0] t, output logic o);
  ifc u (.clk(m3[s][t][1]));
  assign o = u.sig[0];
endmodule
