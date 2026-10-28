// § ifcAnsiLogicPortNet450
interface bfm (input logic clk, output logic [3:0] arr [2], output logic one);
initial begin
  arr[0] = 0;
  one = 0;
end
endinterface
module top;
  logic clk; logic [3:0] a [2]; logic o;
  bfm u (.clk(clk), .arr(a), .one(o));
endmodule
