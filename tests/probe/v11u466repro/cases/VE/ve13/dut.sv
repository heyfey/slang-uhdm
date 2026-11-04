// § ifcEventShadowSkip466v
interface ifc(input logic clk);
  event ev;
  int n;
  function automatic int f(int ev);
    return ev + 1;
  endfunction
  always @(posedge clk) begin
    n = f(n);
    ->ev;
  end
endinterface
module top(input logic clk);
  ifc u(clk);
endmodule
