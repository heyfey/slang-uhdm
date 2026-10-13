// § ifaceHcSelNamedByInst313
interface ifc (input logic clk);
  logic [7:0] sig;
  modport mp (input sig, input clk);
endinterface
module child (ifc.mp p, output logic o);
  assign o = p.sig[0] ^ p.clk;
endmodule
module top (input logic a, output logic o);
  ifc a0 (.clk(a));
  ifc u (.clk(a0.clk));
  child c0 (.p(u), .o(o));
endmodule
