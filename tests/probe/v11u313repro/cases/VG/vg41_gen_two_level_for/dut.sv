// § genIfaceHcInnerRefUnbound313
interface ifc (input logic clk);
  logic [7:0] sig;
  modport mp (input sig, input clk);
endinterface
module child (ifc.mp p, output logic o);
  assign o = p.sig[0] ^ p.clk;
endmodule
module top (input logic [3:0] ck, input logic [1:0] s, output logic [3:0] o);
  for (genvar i = 0; i < 2; i++) begin : g
    for (genvar j = 0; j < 2; j++) begin : h
      ifc u (.clk(ck[s] ^ ck[i*2+j]));
      child c0 (.p(u), .o(o[i*2+j]));
    end
  end
endmodule
