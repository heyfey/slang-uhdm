// § ifcAnsiLogicPortNet450
interface bfm (input logic clk, output time t, output logic f);
initial begin
  t = 0;
  f = 0;
end
endinterface
module top;
  logic clk; time tt; logic ff;
  bfm u (.clk(clk), .t(tt), .f(ff));
endmodule
