// § ifcEventTrigNet466
interface ifc(input logic clk);
  event ev;
  int n;
  always @(posedge clk) ->ev;
endinterface
module m(ifc b);
  int k;
  always begin
    @(b.ev);
    k = b.n;
  end
endmodule
module top(input logic clk);
  ifc u(clk);
  m mm(u);
endmodule
