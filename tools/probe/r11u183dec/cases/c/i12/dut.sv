module top(output int o);
  always_comb begin
    int q[4];
    q[0] = 1;
    o = q[0];
  end
endmodule
