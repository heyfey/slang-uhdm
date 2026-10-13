// § genIfaceInnerLocalKeepsBind317
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top (input logic a, input logic b, output logic o);
  if (1) begin : g
    logic v;
    always_comb v = a ^ b;
    ifc u (.clk(b & v));
  end
  assign o = g.u.sig[0];
endmodule
