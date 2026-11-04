module top(input logic clk, input logic [63:0] a, input logic [63:0] b, output logic [63:0] o);
  logic [63:0] p;
  always_ff @(posedge clk) begin : blk
    p      <= a;
    p[3:0] <= b[3:0];
    o      <= p;
  end
endmodule
