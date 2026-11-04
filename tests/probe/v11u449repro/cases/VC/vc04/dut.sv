// § cloneCtorEatenLocalNoBind449
package p;
  class H; function new(string s); endfunction endclass
  class R;
    function new();
      H rh;
      rh = new("reporter");
      if (rh == null) rh = new("x");
    endfunction
  endclass
endpackage
package r;
  import p::*;
  int k;
endpackage
module top;
  import r::*;
endmodule
