// § genIfaceInnerLocalKeepsBind317
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top (input logic [3:0] ck, input logic [1:0] s, output logic o);
  if (1) begin : g
    logic [1:0] ls;
    assign ls = s;
    ifc u (.clk(|ck[ls +: 2]));
  end
  assign o = g.u.sig[0];
endmodule
