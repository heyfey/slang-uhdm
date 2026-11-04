// § ifcEventShadowSkip466v
interface ifc(input logic clk);
  event ev;
  int n;
  task t();
    event ev;
    ->ev;
  endtask
  always begin
    @ev;
    n = n + 1;
  end
endinterface
module top(input logic clk);
  ifc u(clk);
endmodule
