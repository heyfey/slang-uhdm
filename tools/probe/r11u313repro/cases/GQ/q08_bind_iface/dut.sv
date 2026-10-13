// § genIfaceConnGenScopeName313
interface ifc (input logic clk);
  logic [7:0] sig;
  modport mp (input sig, input clk);
endinterface
module tgt (input logic clk, output logic o);
  assign o = clk;
endmodule
module top (input logic clk, output logic o);
  tgt t (.clk(clk), .o(o));
endmodule
bind tgt ifc bi (.clk(clk));
