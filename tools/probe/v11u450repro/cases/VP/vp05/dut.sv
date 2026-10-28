// § ifcAnsiLogicPortNet450
interface bfm (input logic clk, output var logic v, output logic w);
initial begin
  v = 0;
  w = 0;
end
endinterface
module top;
  logic clk, vv, ww;
  bfm u (.clk(clk), .v(vv), .w(ww));
endmodule
