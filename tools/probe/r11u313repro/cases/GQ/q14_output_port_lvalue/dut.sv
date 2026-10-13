// § genIfaceConnGenScopeName313
interface ifc (input logic clk);
  logic [7:0] sig;
  modport mp (input sig, input clk);
endinterface
interface oifc (input logic clk, output logic q);
  assign q = clk;
endinterface
module top (input logic clk, output logic [1:0] o);
  if (1) begin : g
    oifc u (.clk(clk), .q(o[1]));
  end
  assign o[0] = 1'b0;
endmodule
