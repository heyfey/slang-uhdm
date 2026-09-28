// (r11u191 N0228) the continued-select index call on the LEFT of an assignment and with a two-dimensional member
class C; function string get_type_name(); return "x"; endfunction endclass
class Q; int queue[$]; int v; endclass
class F;
  Q m[string];
  function void f(C obj);
    m[obj.get_type_name()].v = 3;
    m[obj.get_type_name()].queue[0] = 4;
  endfunction
endclass
module top; endmodule
