// § drillUnresolvedFallback449v
package p;
  class C;
    int unsigned blks[C];
  endclass
  function automatic void walk(ref C blks[$]);
    foreach (blks[i]) blks[i] = null;
  endfunction
endpackage
package r;
  import p::*;
  int k;
endpackage
module top;
  import r::*;
endmodule
