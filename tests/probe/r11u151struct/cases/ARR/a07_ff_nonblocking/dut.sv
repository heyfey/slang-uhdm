// ARR: nonblocking assignments in an always_ff begin.
module top(input logic clk, input logic a, output logic [3:0] y);
  logic [3:0] v;
  always_ff @(posedge clk) begin
    v[0] <= a;
    y <= v;
  end
endmodule
