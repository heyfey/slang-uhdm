// (r11u191 N0228) a method call with arguments, a property path and a chained method as the index inside a member path
class C; string nm; C nxt; function string get_name(int k); return nm; endfunction function string get_type_name(); return nm; endfunction endclass
class Q; int queue[$]; endclass
class F;
  Q m[string];
  function void f(C obj);
    int x;
    x = m[obj.get_name(3)].queue.size();
    x = m[obj.nm].queue.size();
    x = m[obj.nxt.get_type_name()].queue.size();
    m[obj.get_type_name()].queue.push_back(1);
  endfunction
endclass
module top; endmodule
