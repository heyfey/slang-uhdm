// § genIfaceHcInnerRefUnbound313
interface ifc (input logic clk);
  logic [7:0] sig;
  modport mp (input sig, input clk);
endinterface
module child (ifc.mp p, output logic o);
  assign o = p.sig[0] ^ p.clk;
endmodule
module top (input logic [1:0] ck, input logic a, output logic [1:0] o);
  if (1) begin : g
    for (genvar i = 0; i < 2; i++) begin : h
      ifc u (.clk(ck[i] ^ a));
      child c0 (.p(u), .o(o[i]));
    end
  end
endmodule
