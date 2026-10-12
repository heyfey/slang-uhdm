// § clsScopedChainIdxDirect292
package q;
  typedef struct packed { logic [1:0] a; } s_t;
  s_t qs;
  class h; int hval; endclass
  h qh = new();
endpackage
package p;
  class r;
    int arr [0:3];
    function void f1(); arr[q::qh.hval] = 1; endfunction
    function void f2(); arr[q::qs.a] = 2; endfunction
    function int f3(); return arr[q::qh.hval]; endfunction
  endclass
endpackage
module top;
  int arr [0:3];
  int y;
  always_comb y = arr[q::qs.a];
  p::r o = new();
endmodule
