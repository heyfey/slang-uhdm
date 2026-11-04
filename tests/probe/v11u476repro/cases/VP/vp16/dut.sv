// § cloneViaProviderTopClone476
package u;
  function automatic int f(int x);
    int y;
    y = x;
    begin : b1
      int t;
      t = y;
      y = t;
    end
    begin : b2
      int t;
      t = y + 1;
      y = t;
    end
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
package t;
  import a::*;
  class TC; AC h; endclass
endpackage
module top; import t::*; TC o; endmodule
