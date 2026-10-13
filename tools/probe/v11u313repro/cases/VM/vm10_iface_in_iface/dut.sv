// § ifaceHcSelNamedByInst313
interface ifc (input logic clk);
  logic [7:0] sig;
  modport mp (input sig, input clk);
endinterface
interface outer (input logic [1:0] ck);
  ifc u (.clk(ck[1]));
  logic w;
endinterface
module top (input logic [1:0] ck, output logic o);
  outer ou (.ck(ck));
  assign o = ou.w;
endmodule
