// § idxCallPathAtDots191 — v11u195 fresh: two call indices on one continued select, a three-component receiver, a call index as a part-select bound in an lvalue
class C;
  int k;
  function int f(); return 1; endfunction
endclass
class H;
  C c;
  function new(); c = new; endfunction
endclass
class B;
  H h;
  C c;
  int m [4][4];
  struct packed { logic [3:0] x; } s [4][4];
  logic [7:0] q;
  function new(); h = new; c = new; endfunction
  function void run();
    int r;
    r = s[c.f()][h.c.f()].x;
    s[h.c.f()][0].x = 4'd1;
    q[c.f()+:2] = 2'b1;
    r = m[c.f()][h.c.f()];
  endfunction
endclass
module top;
  initial begin B b = new; b.run(); end
endmodule
