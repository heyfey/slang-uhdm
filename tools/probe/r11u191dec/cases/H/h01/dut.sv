// (r11u191 N0228) a method-call hier_path as the index of a select inside an rvalue member path (uvm_factory.svh 911)
class C; function string get_type_name(); return "x"; endfunction endclass
class Q; int queue[$]; endclass
class F;
  Q m[string];
  Q n[C];
  function void f(C obj);
    n[obj].queue = m[obj.get_type_name()].queue;
  endfunction
endclass
module top; endmodule
