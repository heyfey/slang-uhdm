// r10uvm105 arm a3 — MEASUREMENT ONLY.  THE DISCRIMINATORS.  Every cell here
// asks a question whose answer could REFUTE the simple predicate "the written
// identifier names a type parameter of the enclosing class".
//
//  s105  a package that ALSO declares a typedef with the SAME NAME as the
//        class's type parameter.  Surelog compiles the out-of-body body in the
//        PACKAGE's scope, so the PACKAGE's `T` is what its lexical chain
//        answers with -- and ElaborationStep::bindTypedefs_ repairs a
//        placeholder whose name matches a typedef.  If this cell RESOLVES, the
//        predicate must not be "names a type parameter" alone.
//  t105  the same, with the colliding typedef in ANOTHER package that this one
//        does NOT import  (the placeholder must survive)
//  u105c an out-of-body local with UNPACKED / QUEUE / DYNAMIC dimensions
//  v105  the SCOPED spellings: `c::T`, `pkg::T`
//  w105  two out-of-body methods of the SAME class, each declaring the same
//        parameter -- one object each, or one shared?
//  x105  an out-of-body local declared with an INITIALISER
package s105;
  class ds105; int sx; endclass
  typedef int T105COLLIDE;              // <- the SAME NAME as cs105's parameter
  class cs105 #(type T105COLLIDE = ds105);
    extern function void sf();
  endclass
  function void cs105::sf();
    T105COLLIDE  so_c;                  // package typedef vs class type parameter
  endfunction
endpackage

package t105other;
  typedef int T105FAR;
endpackage

package t105;
  class dt105; int tx; endclass
  class ct105 #(type T105FAR = dt105);
    extern function void tf();
  endclass
  function void ct105::tf();
    T105FAR  to_c;                      // the colliding typedef is NOT visible here
  endfunction
endpackage

package u105c;
  class du105c; int ux; endclass
  class cu105 #(type UT = du105c);
    extern function void ufix();
    extern function void uq();
    extern function void ud();
  endclass
  function void cu105::ufix();
    UT  uo_fix[4];                      // FIXED unpacked
  endfunction
  function void cu105::uq();
    UT  uo_q[$];                        // QUEUE
  endfunction
  function void cu105::ud();
    UT  uo_dyn[];                       // DYNAMIC
  endfunction
endpackage

package v105;
  class dv105; int vx; endclass
  typedef dv105 v105_td;
  class cv105 #(type VT = dv105);
    extern function void vf();
  endclass
  function void cv105::vf();
    cv105::VT  vo_scoped;               // the CLASS-SCOPED spelling
    v105::v105_td vo_pkgtd;             // a PACKAGE-SCOPED typedef, the control
  endfunction
endpackage

package w105;
  class dw105; int wx; endclass
  class cw105 #(type WT = dw105);
    extern function void wf1();
    extern function void wf2();
  endclass
  function void cw105::wf1();
    WT wo_1;
  endfunction
  function void cw105::wf2();
    WT wo_2;
  endfunction
endpackage

package x105;
  class dx105; int xx; endclass
  class cx105 #(type XT = dx105);
    extern function void xf();
  endclass
  function void cx105::xf();
    XT xo_init = null;                  // an out-of-body local WITH an initialiser
  endfunction
endpackage

module top105b;
  import s105::*; import t105::*; import u105c::*;
  import v105::*; import w105::*; import x105::*;
  cs105 h_s; ct105 h_t; cu105 h_u; cv105 h_v; cw105 h_w; cx105 h_x;
  initial begin
    h_s = new(); h_t = new(); h_u = new(); h_v = new(); h_w = new(); h_x = new();
  end
endmodule
