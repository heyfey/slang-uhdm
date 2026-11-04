// (r11u191 N0228) whitespace around the dot of the index call
class C; function string get_type_name(); return "x"; endfunction endclass
class Q; int v; endclass
class F;
  Q m[string];
  function int f(C obj);
    return m[obj . get_type_name()].v;
  endfunction
endclass
module top; endmodule
