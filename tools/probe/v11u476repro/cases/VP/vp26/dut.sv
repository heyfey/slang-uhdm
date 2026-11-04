// § cloneViaProviderTopClone476
package u;
  function automatic int f(int x);
    int y;
    y = x + 1;
    for (int k = 0; k < x; k++) y += k;
    return y;
  endfunction
endpackage
package x;
  function automatic int h(int v); return v; endfunction
endpackage
package a;
  import u::*;
  class AC;
    function int g();
      return f(1);
    endfunction
  endclass
endpackage
package t;
  import x::*;
  import a::*;
  class TC; AC h; endclass
endpackage
module top; import t::*; TC o; endmodule
