// § ifaceHcVarSelWholeByInst319
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
`define SEL(x) m[x][1]
module top (input logic [1:0][1:0] m, input logic [3:0] ck, input logic [1:0] s, input logic [1:0] t, input logic a, output logic o);
  ifc u (.clk(`SEL(s)));
  assign o = u.sig[0];
endmodule
