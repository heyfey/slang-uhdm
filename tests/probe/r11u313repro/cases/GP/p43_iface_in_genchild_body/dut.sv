// § genIfaceConnGenScopeName313
interface ifc (input logic clk);
  logic [7:0] sig;
  modport mp (input sig, input clk);
endinterface
module child (ifc.mp p, output logic o);
  assign o = p.sig[0] ^ p.clk;
endmodule
module mid (input logic clk, output logic o);
  ifc u (.clk(clk));
  child c0 (.p(u), .o(o));
endmodule
module top (input logic clk, output logic o);
  if (1) begin : g
    mid m (.clk(clk), .o(o));
  end
endmodule
