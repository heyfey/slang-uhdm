module top(output int o);
  localparam int N = 3;
  always_comb begin
    int q[N];
    int r[N-1];
    q[0] = 1;
    r[0] = 2;
    o = q[0] + r[0];
  end
endmodule
