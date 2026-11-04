// § blockSizeDimEndsAtExpr183 with § rootLvalueSpanAtRoot184
module top(output int o);
  int v;
  always_comb begin
    int q[4];
    q[1] = 7;
    $root.top.v = q[1];
  end
  assign o = v;
endmodule
