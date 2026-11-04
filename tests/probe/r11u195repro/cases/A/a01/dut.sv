// § idxCallPathAtDots191 — fresh: a call index with a name argument (composition with trailIdxCallArgNamesByPath187), lvalue and rvalue
class C; function string nm(int i); return "x"; endfunction endclass
class Q; int queue[$]; int k; endclass
class F;
  Q m[string];
  function void f(C obj, int i);
    m[obj.nm(i)].k = 1;
    m[obj.nm(i + 1)].queue.push_back(m[obj.nm(i)].k);
  endfunction
endclass
module top; endmodule
