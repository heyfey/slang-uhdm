// r10uvm128 arm E — INSTANCE COUNT, spelling, CASE and ORDER.  One, two and
// three invocations of the same macro in one scope; two names passed in BOTH
// orders through a two-formal macro (so the same written text appears at two
// different argument positions); and names differing only in CASE, so a cell
// cannot agree by matching the wrong symbol.
`include "g128_defs.svh"
package pkg_e128;
class cls_e128;
  string qA[$];
  string qa[$];
  string Qa128[$];
  int rc128;
  cls_e128 ob128;
  function void f_one();
    `E128_ONE(qA)
  endfunction
  function void f_two();
    `E128_ONE(qA)
    `E128_ONE(qa)
  endfunction
  function void f_three();
    `E128_ONE(qA)
    `E128_ONE(qa)
    `E128_ONE(Qa128)
  endfunction
  function void f_order();
    `E128_TWO(qA, Qa128)
    `E128_TWO(Qa128, qA)
  endfunction
endclass
endpackage
module top_e128;
  import pkg_e128::*;
  cls_e128 c;
  initial c = new();
endmodule
