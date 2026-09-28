// § idxCallPathAtDots191 — v11u195 fresh: a call index in a continued select on a class member queue and an associative array, in a function return and a foreach
class Item;
  int v;
  function string nm(); return "a"; endfunction
endclass
class C;
  Item it;
  Item q[$];
  Item m[string];
  function new(); it = new; endfunction
  function int get();
    int r;
    r = q[it.v].v;
    foreach (q[i]) r += m[q[i].nm()].v;
    return m[it.nm()].v;
  endfunction
endclass
module top;
  initial begin C c = new; void'(c.get()); end
endmodule
