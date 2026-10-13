// § ifaceHcSelNamedByInst313
interface ifc (input logic clk);
  logic [7:0] sig;
  modport mp (input sig, input clk);
endinterface
module child (ifc.mp p, output logic o);
  assign o = p.sig[0] ^ p.clk;
endmodule
module top #(parameter P = 1) (input logic [1:0] ck, output logic o);
  ifc u (.clk(ck[P]));
  child c0 (.p(u), .o(o));
endmodule
