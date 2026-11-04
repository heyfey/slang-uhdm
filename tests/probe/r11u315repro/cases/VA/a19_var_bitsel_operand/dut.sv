// § ifaceConnLeftmostLeafElab315
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top (input logic a, output logic o);
  logic [1:0] v;
  assign v = {a, a};
  ifc u (.clk(a & v[1]));
  assign o = u.sig[0];
endmodule
