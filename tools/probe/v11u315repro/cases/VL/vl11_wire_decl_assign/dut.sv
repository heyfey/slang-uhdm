// § ifaceConnLeftmostLeafElab315
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top (input logic a, output logic o);
  wire w1 = a;
  wire w2 = ~a;
  ifc u (.clk(w1 ^ w2));
  assign o = u.sig[0];
endmodule
