// § drillUnresolvedFallback449v
package p;
  typedef class C;
  function automatic void walk(ref C blks[$]);
    foreach (blks[i]) blks[i] = null;
  endfunction
  class C;
    string blks[C];
  endclass
endpackage
package r;
  import p::*;
  int k;
endpackage
module top;
  import r::*;
endmodule
