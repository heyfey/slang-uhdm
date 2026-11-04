// § cloneCtorEatenLocalNoBind449
package p;
  class H; function new(string s); endfunction endclass
  class R;
    extern function new();
  endclass
  function R::new();
    H rh;
    int cnt;
    cnt = 1;
    rh = new("reporter");
  endfunction
endpackage
package r;
  import p::*;
  int k;
endpackage
module top;
  import r::*;
endmodule
