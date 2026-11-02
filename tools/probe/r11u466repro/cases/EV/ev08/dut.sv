// § ifcEventTrigNet466
interface ifc(input logic clk);
  event ev, ew;
  int n;
  always begin
    @(ew or ev);
    n = n + 1;
  end
  always @(posedge clk) begin
    ->ew;
    ->ev;
  end
endinterface
module top(input logic clk);
  ifc u(clk);
endmodule
