// § ifaceHcOpSelByInst315
`define SEL(x, i) x[i]
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top (input logic [1:0] ck, input logic s, output logic o);
  ifc u (.clk(`SEL(ck, s) & ck[0]));
  assign o = u.sig[0];
endmodule
