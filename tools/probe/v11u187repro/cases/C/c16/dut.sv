// § blockSizeDimEndsAtExpr183 (initial begin block, not a subroutine)
module top(output int o);
  initial begin
    int q[4];
    q[1] = 3;
    o = q[1];
  end
endmodule
