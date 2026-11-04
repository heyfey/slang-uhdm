// § cloneCtorEatenLocalNoBind449
package p;
  class H; function new(string s); endfunction endclass
  class R;
    extern function new(int n);
  endclass
  function R::new(int n);
    H rh;
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
