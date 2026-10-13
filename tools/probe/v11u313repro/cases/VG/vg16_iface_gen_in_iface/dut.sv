// § genIfaceConnGenScopeName313
interface ifc (input logic clk);
  logic [7:0] sig;
  modport mp (input sig, input clk);
endinterface
interface outer (input logic [1:0] ck, input logic a);
  if (1) begin : g
    ifc u (.clk(ck[1] | a));
  end
  logic w;
endinterface
module top (input logic [1:0] ck, input logic a, output logic o);
  outer ou (.ck(ck), .a(a));
  assign o = ou.w;
endmodule
