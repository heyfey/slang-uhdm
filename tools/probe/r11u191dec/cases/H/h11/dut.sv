// (r11u191 N0224) controls: the call as an indexed range's BASE (an expression), inside another call's argument in the index
class C; function int k(); return 1; endfunction endclass
class F;
  int q[$];
  C c;
  function int g(int x); return x; endfunction
  function int f();
    int r[$];
    r = q[c.k()+:2];
    return q[g(c.k())];
  endfunction
endclass
module top; endmodule
