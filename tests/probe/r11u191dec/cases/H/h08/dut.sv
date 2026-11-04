// (r11u191 N0228) controls: a plain (not continued) select index call, a call as a call argument, a literal index
class C; function string get_type_name(); return "x"; endfunction endclass
class Q; int v; endclass
class F;
  Q m[string];
  function void f(C obj);
    Q q;
    int k;
    q = m[obj.get_type_name()];
    k = m["a"].v;
    m.delete(obj.get_type_name());
  endfunction
endclass
module top; endmodule
