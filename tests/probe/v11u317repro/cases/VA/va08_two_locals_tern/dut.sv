// § genIfaceInnerLocalKeepsBind317
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top (input logic a, input logic s, output logic o);
  if (1) begin : g
    logic l, m;
    assign l = a;
    assign m = ~a;
    ifc u (.clk(s ? l : m));
  end
  assign o = g.u.sig[0];
endmodule
