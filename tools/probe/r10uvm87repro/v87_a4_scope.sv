// v87 arm a4 — classes in $unit / module / interface / program, nested classes,
// inheritance, specializations overriding one or both parameters.
class u87b; int x; endclass
class u87 #(type REQ = u87b, type RSP = REQ);
  typedef RSP rsp_t;
  REQ p; RSP q[$];
  function void f(); REQ l; l = p; endfunction
endclass

interface iface87;
  class ib87; int x; endclass
  class icx87 #(type REQ = ib87, type RSP = REQ);
    typedef RSP rsp_t;
    REQ p;
    function void f(); REQ l; l = p; endfunction
  endclass
endinterface

package p87z;
  class pb87; int x; endclass
  class pother87; int y; endclass
  class pbase87 #(type REQ = pb87, type RSP = REQ);
    typedef RSP rsp_t;
    REQ p_base;
  endclass
  class pderiv87 extends pbase87 #(pb87);
    REQ p_inherited;
  endclass
  class pderiv2_87 #(type REQ = pb87, type RSP = REQ) extends pbase87 #(REQ, RSP);
    typedef RSP rsp2_t;
    REQ p_own;
  endclass
endpackage

module m87;
  import p87z::*;
  class mb87; int x; endclass
  class mc87 #(type REQ = mb87, type RSP = REQ);
    typedef RSP rsp_t;
    REQ p;
    function void f(); REQ l; l = p; endfunction
  endclass
  mc87 #(mb87) s1;
  mc87 #(mb87, mb87) s2;
  u87 #(u87b) s3;
  pbase87 #(pb87, pb87) s4;
  pbase87 #(pother87) s5;
  pderiv87 s6;
  initial begin end
endmodule

program prog87;
  class gb87; int x; endclass
  class gc87 #(type REQ = gb87, type RSP = REQ);
    typedef RSP rsp_t;
    REQ p;
  endclass
  initial begin end
endprogram
