// § cloneArrTsHomeRefOwn247
package p;
  class c;
    extern function int f();
  endclass
  function int c::f();
    int n;
    begin
      int a[];
      a = new[2];
      foreach (a[i]) n += a[i];
    end
    begin
      int a[$];
      a.push_back(1);
      foreach (a[i]) n += a[i];
    end
    return n;
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
endmodule
