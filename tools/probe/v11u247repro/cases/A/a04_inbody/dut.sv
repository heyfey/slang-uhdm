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
module top;
  import p::*;
  c z;
  int r;
  initial r = pf();
endmodule
