// § cloneCtorEatenLocalNoBind449
package p;
  class R;
    int w;
    extern function new();
  endclass
  function R::new();
    int s1;
    int s2;
    s1 = 3;
    s2 = s1;
    w = s2;
  endfunction
endpackage
package r;
  import p::*;
  int k;
endpackage
module top;
  import r::*;
endmodule
