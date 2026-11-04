// § drillUnresolvedFallback449v
package p;
  class C;
    string blks[int];
  endclass
  class D;
    function void walk(ref C blks[$]);
      foreach (blks[i]) blks[i] = null;
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
