// § namedCallArgFormalTs236 — a named call with an omitted defaulted formal, and a nested named call as an argument
module top(input int a, input int b, output int o, output int o2);
  function automatic int h(int x, int y = 3, int z = 4);
    return x - y + z;
  endfunction
  assign o = h(.x(a), .z(b));
  assign o2 = h(.y(h(.x(b), .y(a))), .x(a));
endmodule
