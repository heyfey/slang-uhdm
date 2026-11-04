// § cloneCtorEatenLocalNoBind449
package p;
  class H; function new(string s); endfunction endclass
  class B; function new(string n, B p); endfunction endclass
  class R extends B;
    extern function new();
    function void set_h(H h); endfunction
  endclass
  function R::new();
    H rh;
    super.new("top", null);
    rh = new("reporter");
    set_h(rh);
  endfunction
endpackage
package r;
  import p::*;
  int k;
endpackage
module top;
  import r::*;
  import p::*;
  R x;
  initial x = new();
endmodule
