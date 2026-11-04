// § blockSizeDimEndsAtExpr183 (control: the range form keeps the bracket)
module top(output int o);
  always_comb begin
    int q[0:3];
    q[0] = 1;
    o = q[0];
  end
endmodule
