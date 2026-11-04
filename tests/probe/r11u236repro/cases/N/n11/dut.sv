// § namedCallArgFormalTs236 — a class method named call and a static named call (class context)
module top(input int a, output int o);
  class c;
    static function int h(int x, int y);
      return x - y;
    endfunction
    function int m(int u);
      return h(.y(u), .x(1));
    endfunction
  endclass
  assign o = c::h(.y(a), .x(a));
endmodule
