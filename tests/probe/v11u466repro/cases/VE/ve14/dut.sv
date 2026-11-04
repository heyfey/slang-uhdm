// § ifcEventShadowSkip466v
interface ifc(input logic clk);
  logic [3:0] sig;
  int s;
  event i;
  always @(posedge clk) foreach (sig[i]) s = s + i;
  always begin
    @i;
    s = 0;
  end
endinterface
module top(input logic clk);
  ifc u(clk);
endmodule
