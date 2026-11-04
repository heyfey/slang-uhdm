// § cloneViaProviderTopClone476
package u;
  function automatic int f(int x);
    int y;
    y = x;
    return y;
  endfunction
  function automatic int g2(int x);
    int y;
    y = f(x) + x;
    return y;
  endfunction
endpackage
package a;
  import u::*;
  class AC;
    function int g();
      return g2(1);
    endfunction
  endclass
endpackage
package t;
  import a::*;
  class TC; AC h; endclass
endpackage
module top; import t::*; TC o; endmodule
