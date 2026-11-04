// § namedCallArgFormalTs236 — named calls inside a function body and a localparam initializer (stay bare)
module top(input int a, output int o);
  function automatic int h(int x, int y);
    return x - y;
  endfunction
  function automatic int w(int p);
    return h(.y(p), .x(p));
  endfunction
  localparam int L = h(.y(1), .x(5));
  assign o = w(a) + L;
endmodule
