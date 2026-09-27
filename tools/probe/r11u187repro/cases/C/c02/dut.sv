// § blockSizeDimEndsAtExpr183
module top(input logic clk, output logic [3:0] o);
  always @(posedge clk) begin : blk
    logic [3:0] q[2*2];
    q[1] = 4'h3;
    o <= q[1];
  end
endmodule
