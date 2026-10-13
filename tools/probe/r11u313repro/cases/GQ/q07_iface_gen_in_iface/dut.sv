// § genIfaceConnGenScopeName313
interface ifc (input logic clk);
  logic [7:0] sig;
  modport mp (input sig, input clk);
endinterface
interface outer (input logic clk);
  if (1) begin : gi
    ifc u (.clk(clk));
  end
endinterface
module top (input logic clk, output logic o);
  outer w (.clk(clk));
  assign o = 1'b0;
endmodule
