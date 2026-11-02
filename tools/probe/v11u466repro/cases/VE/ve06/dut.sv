// § ifcEventTrigNet466
interface ifc(input logic clk);
  event e1;
  event e2 = e1;
  int n;
  always begin
    @e2;
    n = n + 1;
  end
endinterface
module top(input logic clk);
  ifc u(clk);
endmodule
