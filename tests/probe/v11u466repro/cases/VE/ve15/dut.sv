// § ifcEventShadowSkip466v
interface ifc(input logic clk);
  int s;
  event k;
  always @(posedge clk) for (int k = 0; k < 4; k++) s = s + k;
  always begin
    @k;
    s = 0;
  end
endinterface
module top(input logic clk);
  ifc u(clk);
endmodule
