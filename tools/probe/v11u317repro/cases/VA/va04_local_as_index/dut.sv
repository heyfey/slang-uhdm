// § genIfaceInnerLocalKeepsBind317
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top (input logic [1:0] ck, input logic a, output logic o);
  if (1) begin : g
    logic l;
    assign l = a;
    ifc u (.clk(ck[l] & a));
  end
  assign o = g.u.sig[0];
endmodule
