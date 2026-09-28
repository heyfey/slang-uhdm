// § idxCallPathAtDots191 — fresh: a method call index in a continued select used as a call argument and in a return
class C; function int id(); return 1; endfunction endclass
class Q; int v; function int get(); return v; endfunction endclass
class F;
  Q m[int];
  function void p(int a); endfunction
  function int f(C obj);
    p(m[obj.id()].v);
    p(m[obj.id() + 1].get());
    return m[obj.id() - 1].v;
  endfunction
endclass
module top; endmodule
