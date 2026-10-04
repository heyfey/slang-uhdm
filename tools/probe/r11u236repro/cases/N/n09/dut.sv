// § namedCallArgFormalTs236 — named calls in a generate block, a child instance and a process (no stamp in a process)
module sub(input int a, output int o);
  function automatic int h(int x, int y);
    return x * y;
  endfunction
  assign o = h(.y(a), .x(2));
endmodule
module top(input int a, output int o, output int o2, output int o3);
  function automatic int g(int x, int y);
    return x + y;
  endfunction
  if (1) begin : gb
    assign o = g(.y(a), .x(a));
  end
  sub u_s (.a(a), .o(o2));
  always_comb o3 = g(.x(a), .y(a));
endmodule
