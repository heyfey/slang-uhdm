// § ifcEventTrigNet466
interface ifc(input logic clk);
  event ev;
  int n;
  always @(posedge clk) n = n + 1;
endinterface
module top(input logic clk);
  ifc u(clk);
endmodule
