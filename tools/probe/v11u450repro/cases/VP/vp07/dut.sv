// § ifcAnsiLogicPortNet450
interface bfm (input logic clk, output logic f, output logic [3:0] d);
assign f = clk;
assign d = {4{clk}};
endinterface
module top;
  logic clk, ff; logic [3:0] dd;
  bfm u (.clk(clk), .f(ff), .d(dd));
endmodule
