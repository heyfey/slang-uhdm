// § genIfaceConnGenScopeName313
interface ifc (input logic clk);
  logic [7:0] sig;
  modport mp (input sig, input clk);
endinterface
module kid (ifc.mp p [2], output logic [1:0] o);
  assign o[0] = p[0].sig[0];
  assign o[1] = p[1].sig[0];
endmodule
module top (input logic clk, output logic [1:0] o);
  if (1) begin : g
    ifc farr [2] (.clk(clk));
    kid k (.p(farr), .o(o));
  end
endmodule
