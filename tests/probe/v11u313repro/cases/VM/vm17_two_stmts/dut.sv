// § ifaceHcSelNamedByInst313
interface ifc (input logic clk);
  logic [7:0] sig;
  modport mp (input sig, input clk);
endinterface
module child (ifc.mp p, output logic o);
  assign o = p.sig[0] ^ p.clk;
endmodule
module top (input logic [1:0] ck, input logic s, output logic [1:0] o);
  ifc u0 (.clk(ck[0]));
  ifc u1 (.clk(ck[s]));
  child c0 (.p(u0), .o(o[0]));
  child c1 (.p(u1), .o(o[1]));
endmodule
