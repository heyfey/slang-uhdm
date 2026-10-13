// § ifaceHcSelNamedByInst313
interface ifc (input logic clk);
  logic [7:0] sig;
  modport mp (input sig, input clk);
endinterface
module child (ifc.mp p, output logic o);
  assign o = p.sig[0] ^ p.clk;
endmodule
module mid (ifc pi, output logic o);
  ifc u (.clk(pi.clk));
  child c0 (.p(u), .o(o));
endmodule
module top (input logic a, output logic o);
  ifc x (.clk(a));
  mid m (.pi(x), .o(o));
endmodule
