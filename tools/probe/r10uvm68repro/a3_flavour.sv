// r10uvm68 arm a3 — the FLAVOURS of "reached through a name": a typedef CHAIN,
// a PACKAGE typedef written qualified, the same imported unqualified, and a
// `parameter type`.  All at SUBROUTINE scope, where this pass's law lives, so
// the only axis is HOW the name is reached.  The class is NOT nested in the
// module: the nested-parameterized-class shape is arm a4's, and mixing them
// made 9 cells UNMEASURED on our side for a reason that has nothing to do with
// signedness.
package p3;
  typedef int pi_t;
endpackage
typedef int      c1_t;
typedef c1_t     c2_t;   // chain, depth 2
typedef c2_t     c3_t;   // chain, depth 3
import p3::*;

class C3;
  function void f();
    int      x_written;
    c1_t     x_td1;
    c3_t     x_td3;
    p3::pi_t x_pkgq;      // qualified package typedef
    pi_t     x_pkgi;      // imported unqualified
    x_written = x_td1 + x_td3 + x_pkgq + x_pkgi;
  endfunction
  function c1_t r_td1(); r_td1 = 0; endfunction
  function c3_t r_td3(); r_td3 = 0; endfunction
endclass

module m3_mod #(parameter type PT = int);
  function void g();
    PT   y_paramty;      // `parameter type` local
    int  y_written;
    c1_t y_td1;
    y_written = y_paramty + y_td1;
  endfunction
  C3 c3;
  initial begin
    c1_t b_td1 = 1;      // initial-block local through a typedef
    int  b_wr  = 2;
    c3 = new();
    g();
    b_wr = b_td1;
  end
endmodule
