// § modTdRangeClogKeeps434
module child #(parameter W = 8) (input logic clk, input logic [$clog2(W)-1:0] d, output logic [$clog2(W)-1:0] q);
  typedef logic [$clog2(W)-1:0] t;
  t r;
  always_ff @(posedge clk) r <= d;
  assign q = r;
endmodule
module top (input logic clk, input logic [3:0] d, output logic [3:0] q, input logic [1:0] d2, output logic [1:0] q2);
  child #(.W(16)) u1 (.clk(clk), .d(d), .q(q));
  child #(.W(4)) u2 (.clk(clk), .d(d2), .q(q2));
endmodule
