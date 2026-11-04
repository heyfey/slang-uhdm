// § cloneForInitHomeVar476
package u;
  function automatic int f(int x);
    int y;
    y = 0;
    for (int k = 0, j = 1; k < x; k++, j++) y += k + j;
    for (int k = 0; k < x; k++) y -= k;
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
