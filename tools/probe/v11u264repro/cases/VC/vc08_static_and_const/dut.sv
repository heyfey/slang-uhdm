// § ctorBidLhsCloneCopy264
package bp;
  class c;
    int r;
    extern function new(int k = 1);
  endclass
  function c::new(int k = 1);
    static int cnt;
    const int lim = 4;
    automatic int t;
    t = k;
    cnt++;
    r = t + lim;
  endfunction
endpackage
package up;
  import bp::*;
  class d extends c;
    function new(); super.new(); endfunction
  endclass
endpackage
module top;
  import up::*;
  initial begin d o = new(); end
endmodule
