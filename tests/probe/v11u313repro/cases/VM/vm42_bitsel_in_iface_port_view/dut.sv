// § ifaceHcSelNamedByInst313
interface ifc (input logic clk);
  logic [7:0] sig;
  modport mp (input sig, input clk);
endinterface
interface outer (ifc n);
  logic w;
  assign w = n.clk;
endinterface
module top (input logic [1:0] ck, output logic o);
  ifc u (.clk(ck[1]));
  outer ou (.n(u));
  assign o = ou.w;
endmodule
