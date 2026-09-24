module top(input clk, input [63:0] a, input [63:0] b, output reg [63:0] o, output [63:0] o2);
  always @(posedge clk) begin : blk
    o      = a;
    o[3:0] = b[3:0];
  end
  assign o2 = o;
endmodule
