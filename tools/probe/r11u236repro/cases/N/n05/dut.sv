// § namedCallArgFormalTs236 — named-argument call, int formals, actual names equal the formals (EvalFuncNamed's shape)
module top(input int x, input int y, output int o);
  function automatic int h(int x, int y);
    return x - y;
  endfunction
  assign o = h(.y(y), .x(x));
endmodule
