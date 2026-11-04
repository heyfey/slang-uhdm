// § idxCallPathAtDots191 — fresh: a two-level receiver path and a spaced continuation, inside an if and a foreach
class C; function string get_name(); return "x"; endfunction endclass
class D; C c; endclass
class Q; int v; endclass
class F;
  Q m[string];
  D d;
  function int f(D arr[$]);
    int s = 0;
    if (m[d.c.get_name()].v > 0) s = 1;
    foreach (arr[i]) s += m[arr[i].c.get_name()].v;
    return s + m[d.c.get_name()] . v;
  endfunction
endclass
module top; endmodule
