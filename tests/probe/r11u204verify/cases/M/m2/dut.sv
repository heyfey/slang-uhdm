// § methodArgOpRefChainName198: the known residue faces - a method call and a bit select inside the operation argument (c.f(q.size() + i), c.f(i + j[0]))
class C; int q[$]; function int f(int k); return k; endfunction endclass
class D;
  C c; int q[$];
  function int g(int i, int j[2]);
    int x;
    x = c.f(q.size() + i);
    x = c.f(i + j[0]);
    return x;
  endfunction
endclass
module top; endmodule
