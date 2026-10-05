// § cloneArrTsHomeRefOwn247
package p;
  class c;
    function int f();
      int a[];
      a = new[3];
      foreach (a[i]) f += a[i];
      foreach (a[j]) f -= a[j];
    endfunction
  endclass
  function int pf();
    int b[];
    b = new[3];
    foreach (b[i]) pf += b[i];
  endfunction
endpackage
package q;
  import p::*;
  class u;
    function void g();
      int x;
      x = 0;
    endfunction
  endclass
endpackage
module top;
  import p::*;
  import q::*;
  u w;
  c z;
  int r;
  initial r = pf();
endmodule
