package p1;
  typedef class later_c;
  class base;
    extern function void f(int a);
  endclass
  function void base::f(int a);
    later_c h;
    later_c q[$];
    int x;
    x = a;
    h = null;
  endfunction
  class later_c;
    int v;
  endclass
endpackage
package p2;
  import p1::*;
  int k;
endpackage
module top;
  import p2::*;
  initial k = 1;
endmodule
