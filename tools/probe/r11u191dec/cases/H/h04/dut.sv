// (r11u191 N0228) the same shapes inside a module task (a non-class scope) and in a class-typed local
class C; function string get_type_name(); return "x"; endfunction endclass
class Q; int queue[$]; endclass
module top;
  Q m[string];
  int y;
  task t(C obj);
    y = m[obj.get_type_name()].queue[0];
  endtask
endmodule
