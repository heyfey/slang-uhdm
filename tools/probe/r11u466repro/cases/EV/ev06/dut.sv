// § ifcEventTrigNet466
interface ifc(input logic clk);
  event ev;
  int n;
  task waitit();
    @ev;
    n = n + 1;
  endtask
  always @(posedge clk) ->ev;
endinterface
module top(input logic clk);
  ifc u(clk);
endmodule
