// § genIfaceHcInnerRefUnbound313
interface ifc (input logic clk);
  logic [7:0] sig;
  modport mp (input sig, input clk);
endinterface
module child (ifc.mp p, output logic o);
  assign o = p.sig[0] ^ p.clk;
endmodule
module top (input logic [1:0] ck, input logic [1:0] ix, output logic o);
  if (1) begin : g
    ifc u (.clk(ck[ix[0]]));
    child c0 (.p(u), .o(o));
  end
endmodule
