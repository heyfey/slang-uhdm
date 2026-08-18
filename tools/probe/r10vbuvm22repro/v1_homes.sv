// r10vbuvm22 verifier grid v1 — HOMES x CONTAINER FLAVOUR x WRITTEN BASE.
// MEASUREMENT ONLY.  LHS is always golden (Surelog); RHS is always ours.
class cbase1;
  int x;
endclass

typedef struct packed { int a; bit b; } sp1_t;
typedef struct { int a; string s; } su1_t;
typedef enum { E1A, E1B } en1_t;
typedef int ti1_t;

package p1;
  class pcbase1;
    int y;
  endclass
  typedef struct packed { int a; bit b; } psp1_t;
  typedef enum { PE1A, PE1B } pen1_t;
  typedef int pti1_t;

  // ---- PACKAGE-SCOPE typedefs, unpacked dims WRITTEN ON THEM ----
  typedef pcbase1 pk_q_cls[$];      // named CLASS base
  typedef pcbase1 pk_d_cls[];
  typedef pcbase1 pk_a_cls[string];
  typedef pcbase1 pk_f_cls[4];
  typedef pti1_t  pk_q_tdint[$];    // named NON-class base (typedef of int)
  typedef pen1_t  pk_q_tdenum[$];
  typedef psp1_t  pk_q_tdstruct[$];
  typedef int     pk_q_int[$];      // KEYWORD base
  typedef logic [7:0] pk_q_logic[$];
  typedef string  pk_q_str[$];
  typedef struct packed { int a; } pk_q_inlstruct[$];   // INLINE aggregate base
  typedef enum { PZ0, PZ1 } pk_q_inlenum[$];
  typedef int     pk_f_int[3];
  typedef int     pk_2d_int[2][3];

  // package FREE functions
  function automatic pk_q_cls       pf_q_cls();       pk_q_cls r;       return r; endfunction
  function automatic pk_d_cls       pf_d_cls();       pk_d_cls r;       return r; endfunction
  function automatic pk_a_cls       pf_a_cls();       pk_a_cls r;       return r; endfunction
  function automatic pk_f_cls       pf_f_cls();       pk_f_cls r;       return r; endfunction
  function automatic pk_q_tdint     pf_q_tdint();     pk_q_tdint r;     return r; endfunction
  function automatic pk_q_tdenum    pf_q_tdenum();    pk_q_tdenum r;    return r; endfunction
  function automatic pk_q_tdstruct  pf_q_tdstruct();  pk_q_tdstruct r;  return r; endfunction
  function automatic pk_q_int       pf_q_int();       pk_q_int r;       return r; endfunction
  function automatic pk_q_logic     pf_q_logic();     pk_q_logic r;     return r; endfunction
  function automatic pk_q_str       pf_q_str();       pk_q_str r;       return r; endfunction
  function automatic pk_q_inlstruct pf_q_inlstruct(); pk_q_inlstruct r; return r; endfunction
  function automatic pk_q_inlenum   pf_q_inlenum();   pk_q_inlenum r;   return r; endfunction
  function automatic pk_f_int       pf_f_int();       pk_f_int r;       return r; endfunction
  function automatic pk_2d_int      pf_2d_int();      pk_2d_int r;      return r; endfunction

  // PACKAGE CLASS, typedefs in the CLASS
  class pcls1;
    typedef pcbase1 c_q_cls[$];
    typedef pcbase1 c_f_cls[2];
    typedef pti1_t  c_q_tdint[$];
    typedef pen1_t  c_q_tdenum[$];
    typedef psp1_t  c_q_tdstruct[$];
    typedef int     c_q_int[$];
    typedef int     c_f_int[2];
    typedef string  c_q_str[$];
    typedef struct packed { int a; } c_q_inlstruct[$];
    typedef enum { CZ0, CZ1 } c_q_inlenum[$];

    function c_q_cls       cm_q_cls();       c_q_cls r;       return r; endfunction
    function c_f_cls       cm_f_cls();       c_f_cls r;       return r; endfunction
    function c_q_tdint     cm_q_tdint();     c_q_tdint r;     return r; endfunction
    function c_q_tdenum    cm_q_tdenum();    c_q_tdenum r;    return r; endfunction
    function c_q_tdstruct  cm_q_tdstruct();  c_q_tdstruct r;  return r; endfunction
    function c_q_int       cm_q_int();       c_q_int r;       return r; endfunction
    function c_f_int       cm_f_int();       c_f_int r;       return r; endfunction
    function c_q_str       cm_q_str();       c_q_str r;       return r; endfunction
    function c_q_inlstruct cm_q_inlstruct(); c_q_inlstruct r; return r; endfunction
    function c_q_inlenum   cm_q_inlenum();   c_q_inlenum r;   return r; endfunction
    // PACKAGE-scoped typedef named from a CLASS method
    function pk_q_cls      cm_pk_cls();      pk_q_cls r;      return r; endfunction
    function pk_q_tdint    cm_pk_tdint();    pk_q_tdint r;    return r; endfunction
    function pk_q_int      cm_pk_int();      pk_q_int r;      return r; endfunction
    // static / virtual
    static function c_q_cls   cs_q_cls();   c_q_cls r;   return r; endfunction
    virtual function c_q_cls  cv_q_cls();   c_q_cls r;   return r; endfunction
    static function c_q_int   cs_q_int();   c_q_int r;   return r; endfunction
    virtual function c_q_int  cv_q_int();   c_q_int r;   return r; endfunction
  endclass
endpackage

// ---- $unit CLASS ----
class ucls1;
  typedef cbase1 u_q_cls[$];
  typedef ti1_t  u_q_tdint[$];
  typedef int    u_q_int[$];
  typedef int    u_f_int[2];
  function u_q_cls   um_q_cls();   u_q_cls r;   return r; endfunction
  function u_q_tdint um_q_tdint(); u_q_tdint r; return r; endfunction
  function u_q_int   um_q_int();   u_q_int r;   return r; endfunction
  function u_f_int   um_f_int();   u_f_int r;   return r; endfunction
endclass

// ---- $unit-level typedefs + $unit free function ----
typedef cbase1 uu_q_cls[$];
typedef ti1_t  uu_q_tdint[$];
typedef int    uu_q_int[$];
function automatic uu_q_cls   uf_q_cls();   uu_q_cls r;   return r; endfunction
function automatic uu_q_tdint uf_q_tdint(); uu_q_tdint r; return r; endfunction
function automatic uu_q_int   uf_q_int();   uu_q_int r;   return r; endfunction

// ---- MODULE home ----
module top1;
  import p1::*;
  typedef cbase1 m_q_cls[$];
  typedef ti1_t  m_q_tdint[$];
  typedef sp1_t  m_q_tdstruct[$];
  typedef en1_t  m_q_tdenum[$];
  typedef int    m_q_int[$];
  typedef int    m_f_int[2];
  typedef string m_q_str[$];

  function automatic m_q_cls      mf_q_cls();      m_q_cls r;      return r; endfunction
  function automatic m_q_tdint    mf_q_tdint();    m_q_tdint r;    return r; endfunction
  function automatic m_q_tdstruct mf_q_tdstruct(); m_q_tdstruct r; return r; endfunction
  function automatic m_q_tdenum   mf_q_tdenum();   m_q_tdenum r;   return r; endfunction
  function automatic m_q_int      mf_q_int();      m_q_int r;      return r; endfunction
  function automatic m_f_int      mf_f_int();      m_f_int r;      return r; endfunction
  function automatic m_q_str      mf_q_str();      m_q_str r;      return r; endfunction
  // PACKAGE typedef named from a MODULE function (importer present)
  function automatic p1::pk_q_cls   mf_pk_cls();   p1::pk_q_cls r;   return r; endfunction
  function automatic p1::pk_q_tdint mf_pk_tdint(); p1::pk_q_tdint r; return r; endfunction
  function automatic p1::pk_q_int   mf_pk_int();   p1::pk_q_int r;   return r; endfunction

  // MODULE CLASS
  class mcls1;
    typedef cbase1 mc_q_cls[$];
    typedef ti1_t  mc_q_tdint[$];
    typedef int    mc_q_int[$];
    function mc_q_cls   mcm_q_cls();   mc_q_cls r;   return r; endfunction
    function mc_q_tdint mcm_q_tdint(); mc_q_tdint r; return r; endfunction
    function mc_q_int   mcm_q_int();   mc_q_int r;   return r; endfunction
  endclass
endmodule
