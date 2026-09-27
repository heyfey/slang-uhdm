// § blockSizeDimEndsAtExpr183 (named block in always, typedef element)
module top(input logic c, output logic [3:0] o);
  typedef logic [3:0] w_t;
  always @(c) begin : blk
    w_t q[3];
    q[0] = 4'h1;
    o = q[0];
  end
endmodule
