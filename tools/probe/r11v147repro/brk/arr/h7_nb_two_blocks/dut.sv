// § nonblockingSelLhsBindsWholeRef151
module top(input logic clk, input logic a, output logic [3:0] y, output logic [3:0] z);
  logic [3:0] v;
  always_ff @(posedge clk) begin
    v[2] <= a;
  end
  always_ff @(posedge clk) begin
    y <= v;
    z <= ~v;
  end
endmodule
