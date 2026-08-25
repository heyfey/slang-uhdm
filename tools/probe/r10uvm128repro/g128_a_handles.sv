// r10uvm128 arm A — WHICH RECEIVER HEAD, with the macro bodies in their own
// file (`g128_defs.svh`) so the receiver really is spelled across two buffers.
// Cells: a local declared IN THE MACRO BODY (the corpus head's own shape), a
// hand-written class property, a FORMAL of the enclosing function, a
// `this.`-rooted path, and two NEGATIVE CONTROLS (a receiver written wholly in
// the body, and one written wholly as the argument — the corpus head's FIRST
// operand, which never lost its text).
`include "g128_defs.svh"
package pkg_a128;
class cls_a128;
  string q[$];
  string field[$];
  string abstractions[$];
  string a_very_long_field_nm[$];
  string q128[$];
  int rc128;
  cls_a128 hand128;
  function void f_local(cls_a128 peer128);
    `A128_LOCAL(q)
    `A128_LOCAL(field)
    `A128_LOCAL(abstractions)
    `A128_LOCAL(a_very_long_field_nm)
  endfunction
  function void f_hand(cls_a128 peer128);
    `A128_HANDWRITTEN(q)
    `A128_HANDWRITTEN(field)
    `A128_HANDWRITTEN(abstractions)
    `A128_HANDWRITTEN(a_very_long_field_nm)
  endfunction
  function void f_formal(cls_a128 peer128);
    `A128_FORMAL(q)
    `A128_FORMAL(field)
    `A128_FORMAL(abstractions)
    `A128_FORMAL(a_very_long_field_nm)
  endfunction
  function void f_this(cls_a128 peer128);
    `A128_THIS(q)
    `A128_THIS(abstractions)
  endfunction
  function void f_neg(cls_a128 peer128);
    `A128_ALLBODY(q)
    `A128_ALLARG(q)
    `A128_ALLARG(abstractions)
  endfunction
endclass
endpackage
module top_a128;
  import pkg_a128::*;
  cls_a128 c;
  initial c = new();
endmodule
