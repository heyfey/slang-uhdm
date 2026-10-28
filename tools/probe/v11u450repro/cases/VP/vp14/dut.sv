// § ifcAnsiLogicPortNet450
interface bfm (input logic clk, output logic f, output logic [3:0] d);
initial begin
  f = 0;
  d = 0;
end
endinterface
module top;
  logic clk; logic [1:0] ff; logic [7:0] dd;
  bfm u [1:0] (.clk(clk), .f(ff), .d(dd));
endmodule
