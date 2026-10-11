// § withCallParenSyntax286 — with-call written inside a macro and inside parentheses
`define SUMQ(Q) (Q.sum() with ( item ))
package p;
  class c;
    int q[$];
    function int f();
      int r;
      r = 1 + `SUMQ(q);
      r = 1 + (`SUMQ(q));
      return r;
    endfunction
  endclass
endpackage
module top; import p::*; endmodule
