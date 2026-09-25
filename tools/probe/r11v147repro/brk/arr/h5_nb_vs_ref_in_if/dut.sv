// § nonblockingSelLhsBindsWholeRef151
module top(input logic clk, input logic c, input logic a, output logic [1:0][1:0] y);
  logic [1:0][1:0] v;
  always_ff @(posedge clk) begin
    v[0][0] <= a;
    if (c) y <= v;
  end
endmodule
