// § ifaceConnLeftmostLeafElab315
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module m (ifc p, input logic a, output logic o);
  ifc u (.clk(a & p.sig[0]));
  assign o = u.sig[0];
endmodule
module top (input logic a, output logic o);
  ifc x (.clk(a));
  m mm (.p(x), .a(a), .o(o));
endmodule
