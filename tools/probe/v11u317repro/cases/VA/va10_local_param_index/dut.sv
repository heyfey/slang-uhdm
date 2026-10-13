// § genIfaceInnerLocalKeepsBind317
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top (input logic [3:0] ck, input logic a, output logic o);
  if (1) begin : g
    localparam int L = 2;
    ifc u (.clk(ck[L] & a));
  end
  assign o = g.u.sig[0];
endmodule
