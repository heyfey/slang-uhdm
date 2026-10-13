// § ifaceConnLeftmostLeafElab315
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
interface ifw (input logic [1:0] clk);
  logic [7:0] sig;
endinterface
module top (input logic a, output logic o);
  ifw u (.clk({2{a}}));
  assign o = u.sig[0];
endmodule
