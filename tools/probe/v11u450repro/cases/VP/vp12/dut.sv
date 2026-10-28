// § ifcAnsiLogicPortNet450
interface bfm (input logic clk, output logic f, output logic [3:0] d);
initial begin
  f = 0;
  d = 0;
end
endinterface
module top (input logic clk, output logic f, output logic [3:0] d);
  bfm u (.clk(clk), .f(f), .d(d));
endmodule
