// § ifcEventTrigNet466
interface ifc(input logic clk);
  event ev;
  int n;
  task kick();
    ->ev;
  endtask
  always begin
    @ev;
    n = n + 1;
  end
endinterface
module top(input logic clk);
  ifc u1(clk);
  ifc u2(clk);
endmodule
