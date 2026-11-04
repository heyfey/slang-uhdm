// § cloneViaProviderTopClone476
package u;
  class B;
    int v[4];
    function int sum();
      int s;
      s = 0;
      foreach (v[i]) s += v[i];
      return s;
    endfunction
  endclass
  function automatic int f(B b);
    int y;
    y = b.sum();
    y += b.v[0];
    return y;
  endfunction
endpackage
package a;
  import u::*;
  class AC;
    function int g();
      return f(null);
    endfunction
  endclass
endpackage
package t;
  import a::*;
  class TC; AC h; endclass
endpackage
module top; import t::*; TC o; endmodule
