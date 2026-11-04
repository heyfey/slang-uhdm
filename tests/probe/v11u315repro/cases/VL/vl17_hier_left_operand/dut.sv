// § ifaceConnLeftmostLeafElab315
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top (input logic a, output logic o);
  ifc v (.clk(a));
  ifc u (.clk(v.sig[0] & a));
  assign o = u.sig[0];
endmodule
