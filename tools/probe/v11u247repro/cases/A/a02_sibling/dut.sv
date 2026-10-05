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
module top;
  import p::*;
  c z;
endmodule
