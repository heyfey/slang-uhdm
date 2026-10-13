// § ifaceConnLeftmostLeafElab315
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top (input logic a, input logic b, input logic c, input logic d, output logic o);
  ifc u (.clk(a & b));
  ifc v (.clk(c | d));
  assign o = u.sig[0] ^ v.sig[0];
endmodule
