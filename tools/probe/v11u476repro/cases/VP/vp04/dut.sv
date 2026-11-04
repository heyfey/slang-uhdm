// § cloneViaProviderTopClone476
package u;
  function automatic int f(int x);
    int y;
    y = x + 1;
    for (int k = 0; k < x; k++) y += k;
    return y;
  endfunction
endpackage
package a;
  import u::*;
  class AC;
    function int g();
      return f(1);
    endfunction
  endclass
endpackage
package b;
  import u::*;
  class BC;
    function int g();
      return f(1);
    endfunction
  endclass
endpackage
package t;
  import a::*;
  import b::*;
  class TC; AC h; BC k; endclass
endpackage
module top; import t::*; TC o; endmodule
