// § ifcAnsiLogicPortNet450
interface bfm (clk, f, d);
input logic clk;
output logic f;
output logic [3:0] d;
initial begin
  f = 0;
  d = 0;
end
endinterface
module top;
  logic clk, ff; logic [3:0] dd;
  bfm u (.clk(clk), .f(ff), .d(dd));
endmodule
