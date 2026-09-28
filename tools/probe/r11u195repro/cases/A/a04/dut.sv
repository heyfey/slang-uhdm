// § idxCallPathAtDots191 — fresh controls: a plain select, a call inside a call argument, this. and a method call on a select
class C; function int id(); return 1; endfunction endclass
class Q; int v; endclass
class F;
  Q m[int];
  C c;
  C cs[4];
  function int f(C obj);
    int x = m[obj.id()] == null;
    x += m[$clog2(obj.id())].v;
    x += m[this.c.id()].v;
    x += m[cs[1].id()].v;
    return x;
  endfunction
endclass
module top; endmodule
