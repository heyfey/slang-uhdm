// § nonblockingSelLhsBindsWholeRef151
module top(input logic clk, input logic rst, input logic a, output logic [3:0] y);
  logic [3:0] v;
  always_ff @(posedge clk) begin
    if (rst) begin
      v[1] <= 1'b0;
      y <= v;
    end else begin
      y <= '0;
    end
  end
endmodule
