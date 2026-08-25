// r10v128 arm C — the OPERATOR and the OPERAND POSITION.  first / second /
// both operands a cross-buffer hier_path; a bare call statement; if / while
// conditions; a return expression; a ternary; a nested arithmetic tree.
`include "v128_defs.svh"
package pkg_v128c;
  class cls_v128c;
    string q[$];
    string abstractions[$];
    int rcv;
    cls_v128c ob_v;
    cls_v128c oc_v;
    function void f_both();
      `V3_BOTH(q)
      `V3_BOTH(abstractions)
    endfunction
    function void f_first();
      `V3_FIRST(q)
      `V3_FIRST(abstractions)
    endfunction
    function void f_or();
      `V3_OR(q)
      `V3_OR(abstractions)
    endfunction
    function void f_tern();
      `V3_TERN(q)
      `V3_TERN(abstractions)
    endfunction
    function int f_return();
      `V3_RETURN(abstractions)
    endfunction
    function void f_bare();
      `V3_BARE(q)
      `V3_BARE(abstractions)
    endfunction
    function void f_while();
      `V3_WHILECOND(q)
      `V3_WHILECOND(abstractions)
    endfunction
    function void f_nested();
      `V3_NESTED(q)
      `V3_NESTED(abstractions)
    endfunction
  endclass
endpackage
module top_v128c;
  import pkg_v128c::*;
  cls_v128c c;
  initial c = new();
endmodule
