// § genIfaceHcInnerRefUnbound313
interface ifc (input logic clk);
  logic [7:0] sig;
  modport mp (input sig, input clk);
endinterface
module child (ifc.mp p, output logic o);
  assign o = p.sig[0] ^ p.clk;
endmodule
module top (input logic [3:0] ck, input logic [1:0] s, output logic [1:0] o);
  if (1) begin : g
    ifc farr [2] (.clk(ck[s]));
    child c0 (.p(farr[0]), .o(o[0]));
    child c1 (.p(farr[1]), .o(o[1]));
  end
endmodule
