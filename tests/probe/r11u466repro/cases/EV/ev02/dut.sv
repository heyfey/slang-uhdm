// § ifcEventTrigNet466
interface ifc(input logic clk);
  event ev;
  int n;
  always begin
    @ev;
    n = n + 1;
  end
endinterface
module top(input logic clk);
  ifc u(clk);
endmodule
