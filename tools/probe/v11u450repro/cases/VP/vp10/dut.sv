// § ifcAnsiLogicPortNet450
interface bfm (input logic clk, output logic f, output logic [3:0] d);
modport mp (input clk, output f, output d);
task drive();
  f <= 1;
  d <= 4'h3;
endtask
endinterface
module drv (bfm.mp b);
endmodule
module top;
  logic clk, ff; logic [3:0] dd;
  bfm u (.clk(clk), .f(ff), .d(dd));
  drv dr (.b(u));
endmodule
