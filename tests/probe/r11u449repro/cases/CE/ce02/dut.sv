// § cloneCtorEatenLocalNoBind449
package p;
  class R;
    int w;
    extern function new();
  endclass
  function R::new();
    int s1;
    s1 = 3;
    w = s1;
  endfunction
endpackage
package r;
  import p::*;
  int k;
endpackage
module top;
  import r::*;
endmodule
