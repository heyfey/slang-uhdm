// § cloneViaProviderTopClone476
package u;
  function automatic int f(int x);
    static int cnt = 0;
    int y = x;
    cnt++;
    if (x > 0) y += f(x - 1);
    return y + cnt;
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
