// r10vbuvm22 verifier grid v4 — THE ADVERSARIAL CELLS: every shape where the
// PRISTINE binary could already be RIGHT and the law could make it WRONG.
// The dangerous family is the FIXED-SIZE unpacked typedef (pristine
// makeReturnVar already answers `array_var` for it) crossed with a NAMED base
// and with the package DEF listing, which the shipped grid g22.sv does not
// contain.
package p4;
  class base4; int x; endclass
  typedef int    ti4_t;
  typedef struct packed { int a; } sp4_t;
  typedef enum { E4A, E4B } en4_t;
  typedef logic [7:0] tl4_t;

  // FIXED-SIZE, NAMED NON-CLASS base, PACKAGE scope  <-- the danger cell
  typedef ti4_t  pf_tdint4[4];
  typedef sp4_t  pf_tdsp4[4];
  typedef en4_t  pf_tden4[4];
  typedef tl4_t  pf_tdlogic4[4];
  // FIXED-SIZE, NAMED CLASS base, PACKAGE scope
  typedef base4  pf_cls4[4];
  // 2-D FIXED, named bases
  typedef ti4_t  p2d_tdint4[2][3];
  typedef base4  p2d_cls4[2][3];
  // SCOPED named base
  typedef p4::base4 psc_cls4[$];
  typedef p4::ti4_t psc_tdint4[$];
  typedef p4::ti4_t psc_f_tdint4[4];
  // dynamic / assoc with named non-class base, fixed too
  typedef ti4_t  pd_tdint4[];
  typedef ti4_t  pa_tdint4[string];

  function automatic pf_tdint4    f_pf_tdint();    pf_tdint4 r;    return r; endfunction
  function automatic pf_tdsp4     f_pf_tdsp();     pf_tdsp4 r;     return r; endfunction
  function automatic pf_tden4     f_pf_tden();     pf_tden4 r;     return r; endfunction
  function automatic pf_tdlogic4  f_pf_tdlogic();  pf_tdlogic4 r;  return r; endfunction
  function automatic pf_cls4      f_pf_cls();      pf_cls4 r;      return r; endfunction
  function automatic p2d_tdint4   f_p2d_tdint();   p2d_tdint4 r;   return r; endfunction
  function automatic p2d_cls4     f_p2d_cls();     p2d_cls4 r;     return r; endfunction
  function automatic psc_cls4     f_psc_cls();     psc_cls4 r;     return r; endfunction
  function automatic psc_tdint4   f_psc_tdint();   psc_tdint4 r;   return r; endfunction
  function automatic psc_f_tdint4 f_psc_f_tdint(); psc_f_tdint4 r; return r; endfunction
  function automatic pd_tdint4    f_pd_tdint();    pd_tdint4 r;    return r; endfunction
  function automatic pa_tdint4    f_pa_tdint();    pa_tdint4 r;    return r; endfunction

  class c4;
    // FIXED-SIZE, NAMED bases, CLASS scope (pristine array_var -> law ref_var)
    typedef ti4_t cf_tdint4[4];
    typedef sp4_t cf_tdsp4[4];
    typedef en4_t cf_tden4[4];
    typedef base4 cf_cls4[4];
    typedef ti4_t c2d_tdint4[2][3];
    typedef int   cf_int4[4];
    function cf_tdint4  f_cf_tdint();  cf_tdint4 r;  return r; endfunction
    function cf_tdsp4   f_cf_tdsp();   cf_tdsp4 r;   return r; endfunction
    function cf_tden4   f_cf_tden();   cf_tden4 r;   return r; endfunction
    function cf_cls4    f_cf_cls();    cf_cls4 r;    return r; endfunction
    function c2d_tdint4 f_c2d_tdint(); c2d_tdint4 r; return r; endfunction
    function cf_int4    f_cf_int();    cf_int4 r;    return r; endfunction
    // the PACKAGE fixed-size named typedefs named from a class method
    function pf_tdint4  f_pkf_tdint();  pf_tdint4 r;  return r; endfunction
    function pf_cls4    f_pkf_cls();    pf_cls4 r;    return r; endfunction
  endclass

  // INHERITANCE: a derived class returning the BASE class's typedef
  class cb4;
    typedef int   b_q_int4[$];
    typedef ti4_t b_q_tdint4[$];
    typedef base4 b_q_cls4[$];
    typedef int   b_f_int4[4];
    function b_q_int4   bi_int();   b_q_int4 r;   return r; endfunction
    function b_q_tdint4 bi_tdint(); b_q_tdint4 r; return r; endfunction
    function b_q_cls4   bi_cls();   b_q_cls4 r;   return r; endfunction
    function b_f_int4   bi_fint();  b_f_int4 r;   return r; endfunction
  endclass
  class cd4 extends cb4;
    function b_q_int4   di_int();   b_q_int4 r;   return r; endfunction
    function b_q_tdint4 di_tdint(); b_q_tdint4 r; return r; endfunction
    function b_q_cls4   di_cls();   b_q_cls4 r;   return r; endfunction
    function b_f_int4   di_fint();  b_f_int4 r;   return r; endfunction
  endclass
endpackage

module top4;
  import p4::*;
  // MODULE-scope fixed-size named typedefs
  typedef p4::ti4_t  mf_tdint4[4];
  typedef p4::base4  mf_cls4[4];
  typedef int        mf_int4[4];
  function automatic mf_tdint4 f_mf_tdint(); mf_tdint4 r; return r; endfunction
  function automatic mf_cls4   f_mf_cls();   mf_cls4 r;   return r; endfunction
  function automatic mf_int4   f_mf_int();   mf_int4 r;   return r; endfunction
  p4::c4  h4;
  p4::cd4 d4;
  initial begin h4 = new(); d4 = new(); end
endmodule
