// § cloneCtorEatenLocalNoBind449
package p;
  class H; function new(string s); endfunction endclass
  class B; function new(string n); endfunction endclass
  class R extends B;
    extern function new();
  endclass
  function R::new();
    H rh;
    super.new("top");
    rh = new("reporter");
  endfunction
endpackage
package r;
  import p::*;
  class R2 extends R;
    function new(); super.new(); endfunction
  endclass
endpackage
module top;
  import r::*;
endmodule
