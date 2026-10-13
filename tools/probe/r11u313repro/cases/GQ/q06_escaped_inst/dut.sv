// § genIfaceConnGenScopeName313
interface ifc (input logic clk);
  logic [7:0] sig;
  modport mp (input sig, input clk);
endinterface
module child (ifc.mp p, output logic o);
  assign o = p.sig[0] ^ p.clk;
endmodule
module top (input logic clk, output logic o);
  if (1) begin : g
    ifc \u$x  (.clk(clk));
    child c0 (.p(\u$x ), .o(o));
  end
endmodule
