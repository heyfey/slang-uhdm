// ARR: in one nonblocking begin a whole write, a select write, and a whole
// read: every whole reference in the block binds the select lvalue.
module top(input logic clk, input logic a, output logic [3:0] y);
  logic [3:0] v;
  always @(posedge clk) begin
    v <= 4'h0;
    v[1] <= a;
    y <= v;
  end
endmodule
