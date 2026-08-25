// r10uvm128 arm B — the PROPERTY KIND crossed with the BUILT-IN METHOD.  Every
// cell writes `<prop>.<m>() != <handle>.<prop>.<m>()` through a macro defined
// in `g128_defs.svh`, so the receiver of the RIGHT-HAND call is spelled across
// two buffers and the left-hand one is not — the corpus head's own pairing.
`include "g128_defs.svh"
package pkg_b128;
class cls_b128;
  int    aa128[string];      // associative
  int    dyn128[];           // dynamic
  string que128[$];          // queue
  int    fix128[4];          // fixed unpacked (no size(); see f_fixed)
  string str128;             // a scalar string
  int    rc128;
  cls_b128 ob128;
  function void f_size();
    `B128_SIZE(aa128)
    `B128_SIZE(dyn128)
    `B128_SIZE(que128)
  endfunction
  function void f_num();
    `B128_NUM(aa128)
  endfunction
  function void f_exists();
    `B128_EXISTS(aa128)
  endfunction
  function void f_len();
    `B128_LEN(str128)
  endfunction
endclass
endpackage
module top_b128;
  import pkg_b128::*;
  cls_b128 c;
  initial c = new();
endmodule
