// § ifaceConnLeftmostLeafElab315
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top (input logic a, input logic b, output logic o, output logic p);
  ifc u (.clk(a & b));
  if (1) begin : g
    ifc w (.clk(b & a));
  end
  assign o = u.sig[0];
  assign p = g.w.sig[0];
endmodule
