// r10uvm91 arm 1 — the class-scope TYPE-PARAMETER typespec group when the
// parameters resolve to a NON-CLASS type.  § classTpTsResolvedNameEverySite87
// owns the CLASS-resolved half; uvm87's residue R1 left int / struct / enum
// alone.  Every cell below is read off ONE golden, both directions.
//
// The head this arm exists for: uvm-1.2 uvm_imps.svh:232 —
//   class uvm_blocking_master_imp #(type REQ=int, type RSP=REQ, type IMP=int,
//                                   type REQ_IMP=IMP, type RSP_IMP=IMP)
//     typedef IMP this_imp_type; typedef REQ_IMP this_req_type;
//     typedef RSP_IMP this_rsp_type;
//     local this_req_type m_req_imp;  local this_rsp_type m_rsp_imp;
// golden: ONE int_typespec named `this_rsp_type` located at the `int` of
// `type IMP=int` (the class HEADER), bound at 9 sites.
package p91;
  class k91;  int x;  endclass
  class k91b; int y;  endclass
  typedef struct packed { int a; int b; } st91_t;
  typedef enum { E0, E1 } en91_t;

  // (A) THE CORPUS SHAPE VERBATIM, int, all five parameters.
  class c_uvm #(type REQ=int, type RSP=REQ, type IMP=int,
                type REQ_IMP=IMP, type RSP_IMP=IMP);
    typedef IMP     this_imp_type;
    typedef REQ_IMP this_req_type;
    typedef RSP_IMP this_rsp_type;
    local this_req_type m_req_imp;
    local this_rsp_type m_rsp_imp;
    function new(this_imp_type imp, this_req_type req_imp,
                 this_rsp_type rsp_imp);
      m_req_imp = req_imp;
      m_rsp_imp = rsp_imp;
    endfunction
    function void a_put(REQ t); endfunction
    function void a_get(output RSP t); endfunction
  endclass

  // (B) ROOT vs FIRST-IN-GROUP.  Only the DERIVED parameter has a typedef, so
  //     "the group object is the ROOT parameter's header default" and "the
  //     object is the FIRST group member's own default" disagree here.
  class c_root #(type A=int, type B=A);
    typedef B b_t;
    B p_b;
    A p_a;
    function void f_b(b_t x); endfunction
  endclass

  // (C) TWO INDEPENDENT ROOTS of the same resolved type — one group or two?
  class c_two #(type A=int, type B=int);
    typedef A a_t;
    typedef B b_t;
    A p_a;
    B p_b;
  endclass

  // (D) the group KEY is the RESOLVED type: int vs integer in one class.
  class c_kind #(type A=int, type B=integer, type C=A);
    typedef A a_t;
    typedef B b_t;
    typedef C c_t;
    A p_a;
    B p_b;
    C p_c;
  endclass

  // (E) TYPEDEF ORDER: written c/a/b over parameters A,B,C.
  class c_ord #(type A=int, type B=A, type C=A);
    typedef C c_t;
    typedef A a_t;
    typedef B b_t;
    A p_a;
    B p_b;
    C p_c;
  endclass

  // (F) TWO typedefs of ONE parameter (uvm87 rule 2: FIRST survivor wins).
  class c_dbl #(type A=int, type B=A);
    typedef A a1_t;
    typedef A a2_t;
    typedef B b1_t;
    typedef B b2_t;
    A p_a;
    B p_b;
  endclass

  // (G) QUALIFIED typedefs (uvm87 rule 3: not candidates).
  class c_qual #(type A=int, type B=A);
    local typedef B lb_t;
    protected typedef A pa_t;
    A p_a;
    B p_b;
  endclass

  // (H) NO typedef at all — the whole group must stay anonymous.
  class c_notd #(type A=int, type B=A);
    A p_a;
    B p_b;
    function void f_a(A x); endfunction
  endclass

  // (I) a PLAIN typedef of the bare builtin sitting between two parameter
  //     typedefs, and a bare-builtin formal — neither is in the group.
  class c_mix #(type A=int, type B=A);
    typedef A a_t;
    typedef int plain_t;
    typedef B b_t;
    A p_a;
    plain_t p_plain;
    function void f_raw(int x); endfunction
  endclass

  // (J) KINDS: bit / logic / byte / shortint / real / string.
  class c_bit  #(type A=bit,      type B=A); typedef A a_t; typedef B b_t; A p_a; B p_b; endclass
  class c_log  #(type A=logic,    type B=A); typedef A a_t; typedef B b_t; A p_a; B p_b; endclass
  class c_byte #(type A=byte,     type B=A); typedef A a_t; typedef B b_t; A p_a; B p_b; endclass
  class c_shrt #(type A=shortint, type B=A); typedef A a_t; typedef B b_t; A p_a; B p_b; endclass
  class c_real #(type A=real,     type B=A); typedef A a_t; typedef B b_t; A p_a; B p_b; endclass
  class c_str  #(type A=string,   type B=A); typedef A a_t; typedef B b_t; A p_a; B p_b; endclass
  // a PACKED VECTOR default
  class c_vec  #(type A=logic[7:0], type B=A); typedef A a_t; typedef B b_t; A p_a; B p_b; endclass

  // (K) AGGREGATE kinds — enum and packed struct (uvm87 R1's other half).
  class c_enum #(type A=en91_t, type B=A); typedef A a_t; typedef B b_t; A p_a; B p_b; endclass
  class c_st   #(type A=st91_t, type B=A); typedef A a_t; typedef B b_t; A p_a; B p_b; endclass

  // (L) the CLASS-resolved control — must stay exactly as uvm87 left it.
  class c_cls  #(type A=k91, type B=A); typedef A a_t; typedef B b_t; A p_a; B p_b; endclass

  // (M) ALL THE SITES on one int group: scalar / queue / dynamic / fixed /
  //     assoc property, method body local, nested-block local, return, formal,
  //     and the typedef-SPELLED property.
  class c_sites #(type A=int, type B=A);
    typedef A a_t;
    typedef B b_t;
    A p_scalar;
    A p_queue[$];
    A p_dyn[];
    A p_fix[4];
    A p_assoc[string];
    b_t p_td;
    function void m_local();
      A l_v;
      begin
        A l_nested;
      end
    endfunction
    function A m_ret();
      return 0;
    endfunction
    function void m_formal(A item); endfunction
  endclass

  // (N) SPECIALIZATIONS of the corpus shape: int -> bit and int -> class.
  typedef c_uvm #(bit, bit, bit, bit, bit)          c_uvm_bit_t;
  typedef c_uvm #(k91, k91, k91b, k91b, k91b)       c_uvm_cls_t;
  typedef c_sites #(int, int)                       c_sites_int_t;
  typedef c_sites #(bit, bit)                       c_sites_bit_t;

  // (P) the CORPUS'S OWN COUNTER-EXAMPLE, copied from uvm-1.2:
  //     `uvm_spell_chkr #(type T=int)` writes `typedef T tab_t[string];` and
  //     `uvm_utils #(type TYPE=int)` writes `typedef TYPE types_t[$];`.  A
  //     DIMENSIONED typedef is an `array_typespec` OVER the parameter, not a
  //     typedef OF it: golden leaves the type_parameter ANONYMOUS and lists the
  //     array under its own name.  This cell is why the candidate walk tests
  //     `dimensions.empty()` — without it the law renamed six cells that the
  //     PRISTINE build already had right.
  class c_dim #(type A=int, type B=A);
    typedef A tab_t[string];
    typedef B q_t[$];
    function void f_tab(tab_t t); endfunction
    A p_a;
  endclass
  // ...and the MIXED cell: one dimensioned typedef and one plain, on the same
  // parameter chain.  Only the plain one is a candidate.
  class c_dim2 #(type A=int, type B=A);
    typedef A tab_t[string];
    typedef B b_t;
    A p_a;
    B p_b;
  endclass

  // (O) a DERIVED class over a parameterised base — the inherited parameter.
  class c_base #(type A=int, type B=A);
    typedef A a_t;
    typedef B b_t;
    A p_a;
  endclass
  class c_deri extends c_base #(int, int);
    int own_i;
  endclass
endpackage

module top91;
  import p91::*;
  c_uvm         u_uvm;
  c_root        u_root;
  c_two         u_two;
  c_kind        u_kind;
  c_ord         u_ord;
  c_dbl         u_dbl;
  c_qual        u_qual;
  c_notd        u_notd;
  c_mix         u_mix;
  c_bit         u_bit;
  c_log         u_log;
  c_byte        u_byte;
  c_shrt        u_shrt;
  c_real        u_real;
  c_str         u_str;
  c_vec         u_vec;
  c_enum        u_enum;
  c_st          u_st;
  c_cls         u_cls;
  c_sites       u_sites;
  c_uvm_bit_t   u_uvm_bit;
  c_uvm_cls_t   u_uvm_cls;
  c_sites_int_t u_sites_int;
  c_sites_bit_t u_sites_bit;
  c_dim         u_dim;
  c_dim2        u_dim2;
  c_base        u_base;
  c_deri        u_deri;
endmodule
