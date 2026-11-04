// § ifaceConnLeftmostLeafElab315
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
interface ifc2 (input logic clk, input logic rst);
  logic [7:0] sig;
endinterface
module top (input logic a, input logic b, input logic c, input logic d, output logic o);
  ifc2 u (.clk(a & b), .rst(c & d));
  assign o = u.sig[0];
endmodule
