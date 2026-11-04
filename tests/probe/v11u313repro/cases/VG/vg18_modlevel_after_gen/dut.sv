// § ifaceHcSelNamedByInst313
interface ifc (input logic clk);
  logic [7:0] sig;
  modport mp (input sig, input clk);
endinterface
module child (ifc.mp p, output logic o);
  assign o = p.sig[0] ^ p.clk;
endmodule
module m2 (input logic a, output logic o);
  assign o = a;
endmodule
module top (input logic a, input logic b, output logic o, output logic o2);
  if (1) begin : g
    m2 x (.a(a), .o(o2));
  end
  ifc u (.clk(a & b));
  child c0 (.p(u), .o(o));
endmodule
