// r10vbuvm22 verifier grid v3 — METHOD KINDS x HOMES the brief names:
// in-body / OUT-OF-BODY (extern) / static / virtual / pure-virtual in an
// interface class / nested class / class in an interface / class in a program.
package p3;
  class base3; int x; endclass
  typedef int ti3_t;
  typedef base3 pq_cls3[$];
  typedef ti3_t pq_tdint3[$];
  typedef int   pq_int3[$];

  class c3;
    typedef base3 q_cls3[$];
    typedef ti3_t q_tdint3[$];
    typedef int   q_int3[$];
    // in-body
    function        q_cls3 ib_cls();  q_cls3 r;  return r; endfunction
    function        q_int3 ib_int();  q_int3 r;  return r; endfunction
    static function q_cls3 sb_cls();  q_cls3 r;  return r; endfunction
    static function q_int3 sb_int();  q_int3 r;  return r; endfunction
    virtual function q_cls3 vb_cls(); q_cls3 r;  return r; endfunction
    virtual function q_int3 vb_int(); q_int3 r;  return r; endfunction
    // OUT-OF-BODY
    extern function q_cls3    ob_cls();
    extern function q_int3    ob_int();
    extern function q_tdint3  ob_tdint();
    extern function pq_cls3   ob_pkcls();
    extern function pq_int3   ob_pkint();
    extern static function q_cls3 os_cls();
    extern virtual function q_int3 ov_int();
  endclass
  function c3::q_cls3   c3::ob_cls();   q_cls3 r;   return r; endfunction
  function c3::q_int3   c3::ob_int();   q_int3 r;   return r; endfunction
  function c3::q_tdint3 c3::ob_tdint(); q_tdint3 r; return r; endfunction
  function pq_cls3      c3::ob_pkcls(); pq_cls3 r;  return r; endfunction
  function pq_int3      c3::ob_pkint(); pq_int3 r;  return r; endfunction
  function c3::q_cls3   c3::os_cls();   q_cls3 r;   return r; endfunction
  function c3::q_int3   c3::ov_int();   q_int3 r;   return r; endfunction

  // derived class overriding a virtual
  class d3 extends c3;
    virtual function q_int3 vb_int(); q_int3 r; return r; endfunction
  endclass

  // interface class with a pure virtual method
  interface class ic3;
    pure virtual function pq_cls3 pv_cls();
    pure virtual function pq_int3 pv_int();
  endclass
  class impl3 implements ic3;
    virtual function pq_cls3 pv_cls(); pq_cls3 r; return r; endfunction
    virtual function pq_int3 pv_int(); pq_int3 r; return r; endfunction
  endclass

  // NESTED class
  class outer3;
    typedef base3 o_q_cls3[$];
    typedef int   o_q_int3[$];
    class inner3;
      typedef base3 i_q_cls3[$];
      typedef int   i_q_int3[$];
      function i_q_cls3 in_cls();   i_q_cls3 r; return r; endfunction
      function i_q_int3 in_int();   i_q_int3 r; return r; endfunction
      function o_q_cls3 in_ocls();  o_q_cls3 r; return r; endfunction
      function o_q_int3 in_oint();  o_q_int3 r; return r; endfunction
    endclass
    function o_q_cls3 out_cls(); o_q_cls3 r; return r; endfunction
  endclass
endpackage

interface if3;
  import p3::*;
  typedef p3::base3 if_q_cls3[$];
  typedef int       if_q_int3[$];
  function automatic if_q_cls3 iff_cls(); if_q_cls3 r; return r; endfunction
  function automatic if_q_int3 iff_int(); if_q_int3 r; return r; endfunction
  class ifc3;
    typedef p3::base3 ifc_q_cls3[$];
    typedef int       ifc_q_int3[$];
    function ifc_q_cls3 ifm_cls(); ifc_q_cls3 r; return r; endfunction
    function ifc_q_int3 ifm_int(); ifc_q_int3 r; return r; endfunction
  endclass
endinterface

program pg3;
  import p3::*;
  typedef p3::base3 pg_q_cls3[$];
  typedef int       pg_q_int3[$];
  function automatic pg_q_cls3 pgf_cls(); pg_q_cls3 r; return r; endfunction
  function automatic pg_q_int3 pgf_int(); pg_q_int3 r; return r; endfunction
  class pgc3;
    typedef p3::base3 pgc_q_cls3[$];
    typedef int       pgc_q_int3[$];
    function pgc_q_cls3 pgm_cls(); pgc_q_cls3 r; return r; endfunction
    function pgc_q_int3 pgm_int(); pgc_q_int3 r; return r; endfunction
  endclass
  initial begin end
endprogram

module top3;
  if3 i0();
  if3 i1();
  if3 i2();
endmodule
