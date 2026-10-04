// § cloneRetNoMintBindsHome232
// the return name read in a call argument and an index; two importing packages and a direct import
package p1;
  class c;
    function int g(int x); return x; endfunction
    extern function int f(int a);
  endclass
  function int c::f(int a);
    int arr[4];
    f = a;
    arr[f] = g(f);
    f = arr[g(f)] + f;
  endfunction
endpackage
package p2;
  import p1::*;
endpackage
package p3;
  import p1::*;
endpackage
module top(output int o);
  import p2::*;
  import p3::*;
  import p1::*;
  assign o = 1;
endmodule
