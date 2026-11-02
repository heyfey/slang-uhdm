// § ifcEventTrigNet466
interface ifc(input logic clk);
  event ev;
  int n;
endinterface
module top(input logic clk);
  ifc u(clk);
  always @(posedge clk) ->u.ev;
endmodule
