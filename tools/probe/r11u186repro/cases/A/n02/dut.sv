// § assocPromotedBoundAtBracket183
package p;
class k; endclass
endpackage
module top;
  import p::*;
  function automatic int f();
    int m[k];
    return m.num();
  endfunction
endmodule
