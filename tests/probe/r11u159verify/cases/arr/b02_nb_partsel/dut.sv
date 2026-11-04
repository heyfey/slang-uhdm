// § nonblockingSelLhsBindsWholeRef151
module top(input logic clk, input logic [1:0] a, output logic [3:0] y);
  logic [3:0] v;
  always_ff @(posedge clk) begin
    v[3:2] <= a;
    y <= v;
  end
endmodule
