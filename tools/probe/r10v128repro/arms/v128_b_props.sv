// r10v128 arm B — the PROPERTY KIND x the BUILT-IN METHOD, every receiver
// spelled half in the macro BODY and half as the macro ARGUMENT.
`include "v128_defs.svh"
package pkg_v128b;
  class inner_v128;
    function int user_m(); return 7; endfunction
  endclass
  class cls_v128b;
    string  q[$];              // queue
    string  dyn[];             // dynamic
    string  fx[4];             // fixed
    int     aa_s[string];      // assoc keyed by STRING
    int     aa_c[inner_v128];  // assoc keyed by CLASS
    string  str_v;             // a string (len)
    int     sc;                // a scalar, no method
    inner_v128 h_v;            // a handle carrying a USER method
    int     rcv;
    string  ky_v;
    cls_v128b ob_v;
    function void f_size();
      `V2_SIZE(q)
      `V2_SIZE(dyn)
      `V2_SIZE(aa_s)
    endfunction
    function void f_num();
      `V2_NUM(aa_s)
      `V2_NUM(aa_c)
    endfunction
    function void f_exists();
      `V2_EXISTS(aa_s)
    endfunction
    function void f_delete();
      `V2_DELETE(q)
      `V2_DELETE(aa_s)
      `V2_DELETE(dyn)
    endfunction
    function void f_first();
      `V2_FIRST(aa_s)
    endfunction
    function void f_user();
      `V2_USER(h_v)
    endfunction
    function void f_scalar();
      `V2_SCALARFLD(sc)
    endfunction
  endclass
endpackage
module top_v128b;
  import pkg_v128b::*;
  cls_v128b c;
  initial c = new();
endmodule
