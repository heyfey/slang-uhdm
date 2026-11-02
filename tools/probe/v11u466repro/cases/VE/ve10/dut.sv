// § ifcEventTrigNet466
interface ifc(input logic clk);
  event ev;
  int n;
  always @(posedge clk) ->ev;
  always begin
    @ev;
    n = n + 1;
  end
endinterface
module top(input logic clk);
  for (genvar i = 0; i < 2; i++) begin : g
    ifc u(clk);
  end
endmodule
