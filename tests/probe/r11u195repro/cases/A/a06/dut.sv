// § idxCallPathAtDots191 — fresh: the call index in a module-level class handle's continued select, in an initial block
class C; function int id(); return 1; endfunction endclass
class Q; int v; endclass
module top;
  Q m[int];
  C obj;
  int x;
  initial begin
    obj = new;
    x = m[obj.id()].v;
    m[obj.id()].v = x;
  end
endmodule
