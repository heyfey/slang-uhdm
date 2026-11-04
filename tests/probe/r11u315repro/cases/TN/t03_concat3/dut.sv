// § ifaceConnLeftmostLeafElab315
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top (input logic a, input logic b, input logic c, output logic [2:0] o);
  ifc u (.clk({a, b, c}));
  assign o = u.sig[2:0];
endmodule
