// r10buvm22 — THE GOLDEN GRID for the FUNCTION RETURN VARIABLE's object KIND.
// MEASUREMENT ONLY.  Each function's name encodes its cell:
//    <home>_<return-type shape>
// homes:  pf_ = package free function        pc_ = package class, IN-BODY method
//         po_ = package class, OUT-OF-BODY   ps_ = package class, static
//         pv_ = package class, virtual       mc_ = module class, in-body
//         uc_ = $unit class, in-body         mf_ = module free function
// shapes: int / vec / tdint / tdvec / tdalias / tdcls / tdstruct / tdenum /
//         q_cls / q_int / q_td / q_struct / d_cls / d_int /
//         a_cls / a_int / a_str / f_cls / f_int /
//         pq_cls / pq_int  (the typedef lives in the PACKAGE, not the class)
//         tp (a type parameter)
package p22;
  typedef int pi_t;
  typedef logic [7:0] pv_t;
  typedef struct packed { logic [3:0] a; } ps_t;
  typedef enum logic [1:0] { PA, PB } pe_t;

  class C22;
    int x;
  endclass

  // PACKAGE-scoped array typedefs (the eager-compile arm)
  typedef C22   pq_cls_t[$];
  typedef int   pq_int_t[$];
  typedef ps_t  pq_str_t[$];
  typedef C22   pd_cls_t[];
  typedef int   pd_int_t[];
  typedef C22   pa_cls_t[string];
  typedef int   pa_int_t[string];
  typedef C22   pf_cls_t[4];
  typedef int   pf_int_t[4];
  typedef pi_t  palias_t;
  typedef C22   pcls_t;

  // ---- package FREE functions -------------------------------------------
  function int      pf_int();      pf_int = 0;      endfunction
  function logic [7:0] pf_vec();   pf_vec = 0;      endfunction
  function pi_t     pf_tdint();    pf_tdint = 0;    endfunction
  function pv_t     pf_tdvec();    pf_tdvec = 0;    endfunction
  function palias_t pf_tdalias();  pf_tdalias = 0;  endfunction
  function pcls_t   pf_tdcls();    pf_tdcls = null; endfunction
  function ps_t     pf_tdstruct(); pf_tdstruct = 0; endfunction
  function pe_t     pf_tdenum();   pf_tdenum = PA;  endfunction
  function pq_cls_t pf_q_cls();    endfunction
  function pq_int_t pf_q_int();    endfunction
  function pq_str_t pf_q_struct(); endfunction
  function pd_cls_t pf_d_cls();    endfunction
  function pd_int_t pf_d_int();    endfunction
  function pa_cls_t pf_a_cls();    endfunction
  function pa_int_t pf_a_int();    endfunction
  function pf_cls_t pf_f_cls();    endfunction
  function pf_int_t pf_f_int();    endfunction

  // ---- package CLASS ------------------------------------------------------
  class K22;
    // class-scoped typedefs (the never-eager arm)
    typedef int   ki_t;
    typedef logic [7:0] kv_t;
    typedef struct packed { logic [3:0] a; } ks_t;
    typedef enum logic [1:0] { KA, KB } ke_t;
    typedef pi_t  kalias_t;
    typedef C22   kcls_t;
    typedef C22   kq_cls_t[$];
    typedef int   kq_int_t[$];
    typedef pi_t  kq_td_t[$];
    typedef ks_t  kq_str_t[$];
    typedef C22   kd_cls_t[];
    typedef int   kd_int_t[];
    typedef C22   ka_cls_t[string];
    typedef int   ka_int_t[string];
    typedef int   ka_str_t[int];
    typedef C22   kf_cls_t[4];
    typedef int   kf_int_t[4];

    // IN-BODY
    function int      pc_int();      pc_int = 0;      endfunction
    function logic [7:0] pc_vec();   pc_vec = 0;      endfunction
    function ki_t     pc_tdint();    pc_tdint = 0;    endfunction
    function kv_t     pc_tdvec();    pc_tdvec = 0;    endfunction
    function kalias_t pc_tdalias();  pc_tdalias = 0;  endfunction
    function kcls_t   pc_tdcls();    pc_tdcls = null; endfunction
    function ks_t     pc_tdstruct(); pc_tdstruct = 0; endfunction
    function ke_t     pc_tdenum();   pc_tdenum = KA;  endfunction
    function string   pc_str();      pc_str = "";     endfunction
    function kq_cls_t pc_q_cls();    endfunction
    function kq_int_t pc_q_int();    endfunction
    function kq_td_t  pc_q_td();     endfunction
    function kq_str_t pc_q_struct(); endfunction
    function kd_cls_t pc_d_cls();    endfunction
    function kd_int_t pc_d_int();    endfunction
    function ka_cls_t pc_a_cls();    endfunction
    function ka_int_t pc_a_int();    endfunction
    function ka_str_t pc_a_str();    endfunction
    function kf_cls_t pc_f_cls();    endfunction
    function kf_int_t pc_f_int();    endfunction
    // the PACKAGE typedef used from inside a class method
    function pq_cls_t pc_pq_cls();   endfunction
    function pq_int_t pc_pq_int();   endfunction
    function pf_int_t pc_pf_int();   endfunction
    // STATIC / VIRTUAL
    static function kq_cls_t ps_q_cls();  endfunction
    static function kq_int_t ps_q_int();  endfunction
    virtual function kq_cls_t pv_q_cls(); endfunction
    virtual function kq_int_t pv_q_int(); endfunction
    virtual function kf_cls_t pv_f_cls(); endfunction
    // OUT-OF-BODY prototypes
    extern function kq_cls_t po_q_cls();
    extern function kq_int_t po_q_int();
    extern function kcls_t   po_tdcls();
    extern function ks_t     po_tdstruct();
    extern function kf_cls_t po_f_cls();
    extern function pq_cls_t po_pq_cls();
  endclass

  function K22::kq_cls_t K22::po_q_cls();   endfunction
  function K22::kq_int_t K22::po_q_int();   endfunction
  function K22::kcls_t   K22::po_tdcls();   po_tdcls = null; endfunction
  function K22::ks_t     K22::po_tdstruct(); po_tdstruct = 0; endfunction
  function K22::kf_cls_t K22::po_f_cls();   endfunction
  function p22::pq_cls_t K22::po_pq_cls();  endfunction

  // a PARAMETERIZED class: the type-parameter return (the § 58 arm)
  class G22 #(type T = int);
    typedef T tq_t[$];
    function T    pc_tp();     endfunction
    function tq_t pc_tp_q();   endfunction
  endclass
endpackage

// ---- $unit class ---------------------------------------------------------
typedef int u_i_t;
class U22;
  typedef p22::C22 uq_cls_t[$];
  typedef int      uq_int_t[$];
  typedef p22::C22 ucls_t;
  function uq_cls_t uc_q_cls();   endfunction
  function uq_int_t uc_q_int();   endfunction
  function ucls_t   uc_tdcls();   uc_tdcls = null; endfunction
endclass

// ---- module free functions + module class --------------------------------
module top22;
  import p22::*;
  typedef int mi_t;
  typedef C22 mq_cls_t[$];
  typedef int mq_int_t[$];
  function mq_cls_t mf_q_cls();  endfunction
  function mq_int_t mf_q_int();  endfunction
  function mi_t     mf_tdint();  mf_tdint = 0; endfunction

  class M22;
    typedef C22 nq_cls_t[$];
    typedef int nq_int_t[$];
    typedef C22 ncls_t;
    function nq_cls_t mc_q_cls();  endfunction
    function nq_int_t mc_q_int();  endfunction
    function ncls_t   mc_tdcls();  mc_tdcls = null; endfunction
  endclass

  K22 k1;
  M22 m1;
  U22 u1;
  G22 #(int) g1;
  initial begin
    k1 = new();
    m1 = new();
    u1 = new();
    g1 = new();
  end
endmodule
