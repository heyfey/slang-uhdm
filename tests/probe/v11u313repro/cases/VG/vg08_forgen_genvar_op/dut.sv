// § genIfaceHcInnerRefUnbound313
interface ifc (input logic clk);
  logic [7:0] sig;
  modport mp (input sig, input clk);
endinterface
module child (ifc.mp p, output logic o);
  assign o = p.sig[0] ^ p.clk;
endmodule
module top (input logic [2:0] ck, output logic [1:0] o);
  for (genvar i = 0; i < 2; i++) begin : g
    ifc u (.clk(ck[i+1]));
    child c0 (.p(u), .o(o[i]));
  end
endmodule
