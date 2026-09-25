// ARR: a nonblocking var_select Lhs in an always_ff begin.
module top(input logic clk, input logic a, output logic o);
  logic pa [1:0][1:0];
  logic pb [1:0][1:0];
  always_ff @(posedge clk) begin
    pa[0][0] <= a;
    pb <= pa;
  end
  assign o = pb[0][0];
endmodule
