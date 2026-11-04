// § ppOutputCol166
`define A(x) \
  assign x = 1'b0;
`define K 1'b1
module top(output o, p, q);
  `A(o) assign p = `K; assign q = `K;
endmodule
