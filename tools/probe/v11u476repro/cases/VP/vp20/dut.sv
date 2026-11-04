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
  import a::*;
  class BC;
    function int g();
      return 1;
    endfunction
  endclass
endpackage
package c;
  import b::*;
  class CC;
    function int g();
      return 2;
    endfunction
  endclass
endpackage
package t;
  import c::*;
  class TC; CC h; endclass
endpackage
module top; import t::*; TC o; endmodule
