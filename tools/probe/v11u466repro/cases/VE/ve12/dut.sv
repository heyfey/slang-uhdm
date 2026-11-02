// § ifcEventTrigNet466
interface ifc(input logic clk);
  event ev, ew;
  int n;
  always @(posedge clk) ->ew;
  always begin
    @ev;
    n = n + 1;
  end
  always begin
    @ew;
    n = n - 1;
  end
endinterface
module top(input logic clk);
  ifc u(clk);
endmodule
