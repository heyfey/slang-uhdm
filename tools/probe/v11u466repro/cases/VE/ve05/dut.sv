// § ifcEventTrigNet466
interface ifc(input logic clk);
  event ea [2];
  event ev;
  int n;
  always @(posedge clk) begin
    n = n;
    ->ev;
  end
  always begin
    @ev;
    n = n + 1;
  end
endinterface
module top(input logic clk);
  ifc u(clk);
endmodule
