// § ifaceConnLeftmostLeafElab315
package pk;
  parameter logic Q = 1'b1;
endpackage
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top (input logic a, input logic b, output logic o);
  ifc u (.clk(a & pk::Q & b));
  assign o = u.sig[0];
endmodule
