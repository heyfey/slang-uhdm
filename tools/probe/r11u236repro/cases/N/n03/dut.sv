// § namedCallArgFormalTs236 — named-argument call, int formals, actual names differ from the formals
module top(input int a, input int b, output int o);
  function automatic int h(int x, int y);
    return x - y;
  endfunction
  assign o = h(.y(b), .x(a));
endmodule
