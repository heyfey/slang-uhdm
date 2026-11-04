// § genIfaceInnerLocalKeepsBind317
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top (input logic [1:0] ck, input logic s, output logic o);
  if (1) begin : g
    logic [1:0] lv;
    assign lv = ck;
    ifc u (.clk(lv[s] ^ lv[0]));
  end
  assign o = g.u.sig[0];
endmodule
