// § ifaceHcSelNamedByInst313
interface ifc (input logic clk);
  logic [7:0] sig;
  modport mp (input sig, input clk);
endinterface
module child (ifc.mp p, output logic o);
  assign o = p.sig[0] ^ p.clk;
endmodule
module top (input logic clk, output logic [1:0] o);
  ifc farr [2] (.clk(clk));
  child c0 (.p(farr[0]), .o(o[0]));
  child c1 (.p(farr[1]), .o(o[1]));
endmodule
