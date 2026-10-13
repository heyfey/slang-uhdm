// § ifaceHcSelNamedByInst313
interface ifc (input logic clk);
  logic [7:0] sig;
  modport mp (input sig, input clk);
endinterface
module child (ifc.mp p, output logic o);
  assign o = p.sig[0] ^ p.clk;
endmodule
module top (input logic [3:0] ck, output logic o);
  ifc u (.clk(ck[1:1]));
  child c0 (.p(u), .o(o));
endmodule
