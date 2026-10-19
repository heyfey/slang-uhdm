// § propLocalVarListed412
interface ifc(input logic clk);
  logic b; int a;
  property pi;
    int x;
    @(posedge clk) (b, x = a) |=> (x == a);
  endproperty
  assert property (pi);
endinterface
module top(input logic clk);
  ifc i(clk);
endmodule
