// § ifcEventTrigNet466
interface ifc #(parameter int W = 1) (input logic clk);
  event ev;
  logic [W-1:0] n;
  always @(posedge clk) ->ev;
  always begin
    @ev;
    n = n + 1;
  end
endinterface
module top(input logic clk);
  ifc #(.W(2)) u1(clk);
  ifc #(.W(4)) u2(clk);
endmodule
