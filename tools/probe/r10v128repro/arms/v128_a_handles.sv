// r10v128 arm A — WHICH HANDLE heads the second (dropped) operand.
// Every cell's receiver is written HALF IN THE MACRO BODY and HALF AS THE
// MACRO ARGUMENT, which is the law's two-buffer gate.
`include "v128_defs.svh"
package pkg_v128;
  class cls_v128;
    string q[$];
    string field[$];
    string abstractions[$];
    string a_very_long_field_nm[$];
    int    rcv;
    static cls_v128 stat_v;
    cls_v128 h1_v;
    cls_v128 h2_v;
    cls_v128 h3_v;
    cls_v128 harr_v[4];
    cls_v128 \esc$h ;
    function cls_v128 get_h();
      return h1_v;
    endfunction
    function void f_this();
      `V1_THIS(q)
      `V1_THIS(abstractions)
      `V1_THIS(a_very_long_field_nm)
    endfunction
    function void f_static();
      `V1_STATIC(q)
      `V1_STATIC(abstractions)
    endfunction
    function void f_clsscope();
      `V1_CLSSCOPE(q)
      `V1_CLSSCOPE(abstractions)
    endfunction
    function void f_two();
      `V1_TWOHANDLE(q)
      `V1_TWOHANDLE(abstractions)
    endfunction
    function void f_three();
      `V1_THREELINK(q)
      `V1_THREELINK(abstractions)
    endfunction
    function void f_thischain();
      `V1_THISCHAIN(q)
      `V1_THISCHAIN(abstractions)
    endfunction
    function void f_indexed();
      `V1_INDEXED(q)
      `V1_INDEXED(abstractions)
    endfunction
    function void f_twice();
      `V1_SAMEARGTWICE(h1_v)
    endfunction
  endclass

  class base_v128;
    string q[$];
    string abstractions[$];
    int    rcv;
  endclass
  class deriv_v128 extends base_v128;
    function void f_super();
      `V1_SUPER(q)
      `V1_SUPER(abstractions)
    endfunction
  endclass

  cls_v128 gh;
  class user_pkgscope;
    string q[$];
    string abstractions[$];
    int    rcv;
    function void f_pkg();
      `V1_PKGSCOPE(q)
      `V1_PKGSCOPE(abstractions)
    endfunction
  endclass
endpackage
module top_v128a;
  import pkg_v128::*;
  cls_v128 c;
  initial c = new();
endmodule
