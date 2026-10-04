// § namedCallArgFormalTs236 — a positional and a named call in a generate block (the positional is the control)
module top(input int a, input int b, output int o, output int o2);
  function automatic int g(int x, int y);
    return x + y;
  endfunction
  if (1) begin : gb
    assign o = g(.y(a), .x(b));
    assign o2 = g(b, a);
  end
endmodule
