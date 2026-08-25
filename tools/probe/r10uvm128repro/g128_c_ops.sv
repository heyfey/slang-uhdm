// r10uvm128 arm C — WHERE the two-buffer receiver sits: each comparison
// operator, a bare assignment rvalue, a direct `if` condition, a `while`
// condition, a call ARGUMENT and a ternary operand.  The law must reach the
// receiver identically in all of them, and the ones with NO comparison at all
// prove the operand restoration is not tied to the binary operator.
`include "g128_defs.svh"
package pkg_c128;
function automatic int f128(int x); return x; endfunction
class cls_c128;
  string que128[$];
  string abstractions[$];
  int rc128;
  cls_c128 ob128;
  function void f_ops();
    `C128_EQ(que128)
    `C128_NE(que128)
    `C128_LT(que128)
    `C128_AND(que128)
  endfunction
  function void f_pos();
    `C128_BARE(abstractions)
    `C128_IF(abstractions)
    `C128_WHILE(abstractions)
    `C128_ARG(abstractions)
    `C128_TERN(abstractions)
  endfunction
endclass
endpackage
module top_c128;
  import pkg_c128::*;
  cls_c128 c;
  initial c = new();
endmodule
