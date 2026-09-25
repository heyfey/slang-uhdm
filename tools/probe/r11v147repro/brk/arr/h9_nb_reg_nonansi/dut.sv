// § nonblockingSelLhsBindsWholeRef151
module top(clk, a, y);
  input clk; input a; output [3:0] y;
  reg [3:0] v;
  reg [3:0] y;
  always @(posedge clk) begin
    v[3] <= a;
    y <= v;
  end
endmodule
