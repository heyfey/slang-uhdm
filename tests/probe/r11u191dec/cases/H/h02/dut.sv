// (r11u191 N0228) a method-call hier_path as a plain select index, as a method argument, as an exists() argument
class C; function string get_type_name(); return "x"; endfunction endclass
class Q; int queue[$]; endclass
class F;
  Q m[string];
  function void f(C obj);
    Q q;
    q = m[obj.get_type_name()];
    if (m.exists(obj.get_type_name())) q = null;
    m.delete(obj.get_type_name());
  endfunction
endclass
module top; endmodule
