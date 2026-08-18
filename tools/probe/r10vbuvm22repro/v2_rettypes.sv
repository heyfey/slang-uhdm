// r10vbuvm22 verifier grid v2 — THE RETURN-TYPE AXIS (every kind the brief
// names) inside ONE package class + one package free function, so the law's
// "Unchanged" arm is exercised on every shape it must NOT touch.
package p2;
  class base2;
    int x;
  endclass
  class parm2 #(type T = int);
    T v;
  endclass
  typedef struct packed { int a; bit b; } sp2_t;
  typedef struct { int a; string s; } su2_t;
  typedef union packed { int a; bit [31:0] b; } up2_t;
  typedef enum { E2A, E2B } en2_t;
  typedef int ti2_t;
  typedef ti2_t tt2_t;              // typedef of typedef, NO dims
  typedef logic [7:0] tl2_t;
  typedef base2 tc2_t;              // class alias, NO dims
  typedef parm2#(int) tp2_t;        // parameterized class alias, NO dims

  typedef int    q_int2[$];         // dims WRITTEN
  typedef ti2_t  q_tdint2[$];
  typedef tt2_t  q_ttint2[$];       // base is a typedef-of-typedef
  typedef q_int2 alias_q2;          // typedef OF an array typedef, NO OWN dims
  typedef sp2_t  q_tdsp2[$];
  typedef su2_t  q_tdsu2[$];
  typedef up2_t  q_tdup2[$];
  typedef en2_t  q_tden2[$];
  typedef base2  q_cls2[$];
  typedef parm2#(int) q_parm2[$];
  typedef tl2_t  q_tdlogic2[$];
  typedef int    f2_int2[2][3];     // 2-D fixed
  typedef sp2_t  f2_sp2[2];
  typedef en2_t  f2_en2[2];
  typedef base2  f2_cls2[2];

  class c2;
    // ---- shapes the law MUST NOT touch (no written dims / not a typedef) ----
    function int            r_int();      int r;            return r; endfunction
    function byte           r_byte();     byte r;           return r; endfunction
    function string         r_string();   string r;         return r; endfunction
    function real           r_real();     real r;           return r; endfunction
    function bit [7:0]      r_packed();   bit [7:0] r;      return r; endfunction
    function ti2_t          r_tdint();    ti2_t r;          return r; endfunction
    function tt2_t          r_ttint();    tt2_t r;          return r; endfunction
    function tl2_t          r_tdlogic();  tl2_t r;          return r; endfunction
    function sp2_t          r_sp();       sp2_t r;          return r; endfunction
    function su2_t          r_su();       su2_t r;          return r; endfunction
    function up2_t          r_up();       up2_t r;          return r; endfunction
    function en2_t          r_en();       en2_t r;          return r; endfunction
    function base2          r_cls();      base2 r;          return r; endfunction
    function tc2_t          r_tdcls();    tc2_t r;          return r; endfunction
    function parm2#(int)    r_parm();     parm2#(int) r;    return r; endfunction
    function tp2_t          r_tdparm();   tp2_t r;          return r; endfunction
    function alias_q2       r_alias_q();  alias_q2 r;       return r; endfunction
    function int            r_dynlocal(); int r; return r; endfunction
    // ---- shapes the law DOES claim ----
    function q_int2         r_q_int();      q_int2 r;       return r; endfunction
    function q_tdint2       r_q_tdint();    q_tdint2 r;     return r; endfunction
    function q_ttint2       r_q_ttint();    q_ttint2 r;     return r; endfunction
    function q_tdsp2        r_q_tdsp();     q_tdsp2 r;      return r; endfunction
    function q_tdsu2        r_q_tdsu();     q_tdsu2 r;      return r; endfunction
    function q_tdup2        r_q_tdup();     q_tdup2 r;      return r; endfunction
    function q_tden2        r_q_tden();     q_tden2 r;      return r; endfunction
    function q_cls2         r_q_cls();      q_cls2 r;       return r; endfunction
    function q_parm2        r_q_parm();     q_parm2 r;      return r; endfunction
    function q_tdlogic2     r_q_tdlogic();  q_tdlogic2 r;   return r; endfunction
    function f2_int2        r_f2_int();     f2_int2 r;      return r; endfunction
    function f2_sp2         r_f2_sp();      f2_sp2 r;       return r; endfunction
    function f2_en2         r_f2_en();      f2_en2 r;       return r; endfunction
    function f2_cls2        r_f2_cls();     f2_cls2 r;      return r; endfunction
    // CLASS-LOCAL typedefs of the same shapes
    typedef int   lq_int2[$];
    typedef ti2_t lq_tdint2[$];
    typedef base2 lq_cls2[$];
    typedef en2_t lq_en2[$];
    typedef sp2_t lq_sp2[$];
    function lq_int2   r_lq_int();   lq_int2 r;   return r; endfunction
    function lq_tdint2 r_lq_tdint(); lq_tdint2 r; return r; endfunction
    function lq_cls2   r_lq_cls();   lq_cls2 r;   return r; endfunction
    function lq_en2    r_lq_en();    lq_en2 r;    return r; endfunction
    function lq_sp2    r_lq_sp();    lq_sp2 r;    return r; endfunction
    // void + task
    function void r_void(); endfunction
    task t_out(output int o); o = 1; endtask
  endclass

  // TYPE PARAMETER return, and a type-param-based array typedef
  class c2p #(type T = int, type QT = q_int2);
    function T  r_typaram();  T r;  return r; endfunction
    function QT r_typaramq(); QT r; return r; endfunction
    typedef T tq2[$];
    function tq2 r_tq();      tq2 r; return r; endfunction
  endclass

  // package FREE functions over the same axis
  function automatic q_int2   pf2_q_int();   q_int2 r;   return r; endfunction
  function automatic q_tdint2 pf2_q_tdint(); q_tdint2 r; return r; endfunction
  function automatic q_cls2   pf2_q_cls();   q_cls2 r;   return r; endfunction
  function automatic q_tden2  pf2_q_tden();  q_tden2 r;  return r; endfunction
  function automatic q_tdsp2  pf2_q_tdsp();  q_tdsp2 r;  return r; endfunction
  function automatic alias_q2 pf2_alias();   alias_q2 r; return r; endfunction
  function automatic ti2_t    pf2_tdint();   ti2_t r;    return r; endfunction
endpackage

module top2;
  import p2::*;
  p2::c2 h2;
  p2::c2p #(int) h2p;
  initial begin
    h2 = new();
    h2p = new();
  end
endmodule
