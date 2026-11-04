// § caOpArgIntFormalTs236 — named-argument call, int formals, an actual in the order written, one an operation
module top(input int a, input int b, output int o);
  function automatic int h(int x, int y);
    return x - y;
  endfunction
  assign o = h(.x(a), .y(b + 1));
endmodule
