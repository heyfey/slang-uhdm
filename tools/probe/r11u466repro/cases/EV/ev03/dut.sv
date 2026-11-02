// § ifcEventTrigNet466
module sub(input logic clk);
  event ev;
  int n;
  task kick();
    ->ev;
  endtask
  always begin
    @ev;
    n = n + 1;
  end
endmodule
module top(input logic clk);
  sub u(clk);
endmodule
