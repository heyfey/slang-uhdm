// v87 arm a6 — WHICH typedef wins: multiple typedefs of the SAME parameter,
// typedef-SPELLED declarations that name the NON-winning typedef, and the
// interaction of both.
package p87t;
  class b87; int x; endclass

  // two typedefs of the SAME (only) parameter
  class t1_87 #(type REQ = b87);
    typedef REQ a_t;
    typedef REQ b_t;
    REQ p;
    a_t p_a;
    b_t p_b;
  endclass

  // last parameter has TWO typedefs, first parameter one
  class t2_87 #(type REQ = b87, type RSP = REQ);
    typedef REQ req_t;
    typedef RSP x_t;
    typedef RSP y_t;
    REQ p_req;
    RSP p_rsp;
    req_t p_reqtd;
    x_t   p_xtd;
    y_t   p_ytd;
  endclass

  // declaration written as the NON-winning typedef
  class t3_87 #(type REQ = b87, type RSP = REQ);
    typedef REQ req_t;
    typedef RSP rsp_t;
    req_t p_reqtd;
    rsp_t p_rsptd;
    function void f();
      req_t l_reqtd;
      rsp_t l_rsptd;
      l_reqtd = l_rsptd;
    endfunction
    function req_t g(); return null; endfunction
    function void h(req_t a); endfunction
    req_t q_req[$];
  endclass

  // typedef of a typedef of a parameter
  class t4_87 #(type REQ = b87, type RSP = REQ);
    typedef RSP rsp_t;
    typedef rsp_t rsp2_t;
    rsp2_t p_td2;
    REQ    p_req;
  endclass
endpackage

module m87a6;
  import p87t::*;
  t3_87 #(b87) i0;
  initial begin end
endmodule
