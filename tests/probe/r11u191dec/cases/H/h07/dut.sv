// (r11u191 N0228) the index call in an if condition, a $sformatf argument and a method call continuing the path
class C; function string get_name(); return "x"; endfunction endclass
class Q; int v; function int get_v(); return v; endfunction endclass
class F;
  Q m[string];
  function void f(C obj);
    string s;
    if (m[obj.get_name()].v > 2) s = "a";
    s = $sformatf("%0d", m[obj.get_name()].get_v());
    if (m.exists(obj.get_name()) && m[obj.get_name()].get_v() == 0) s = "b";
  endfunction
endclass
module top; endmodule
