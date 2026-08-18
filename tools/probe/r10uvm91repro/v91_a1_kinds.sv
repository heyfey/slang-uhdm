// v91 arm 1 — RESOLVED-TYPE KIND SWEEP the implementer's grid does not reach:
// integer, queue/dyn/assoc/fixed-array DEFAULTS (not property types),
// interface class, typedef-of-typedef chains, unpacked struct.
package pv1;
  class kA; int x; endclass
  interface class ifc_a; pure virtual function void f(); endclass
  typedef struct packed { int a; bit b; } sp_t;
  typedef struct { int a; real b; } su_t;      // UNPACKED struct
  typedef enum { Q0, Q1 } en_t;
  typedef int qi_t[$];                          // queue
  typedef int di_t[];                           // dynamic
  typedef int ai_t[string];                     // assoc
  typedef int fi_t[4];                          // fixed unpacked

  // integer (PredefinedIntegerType, distinct from int)
  class c_integer #(type A=integer, type B=A); typedef A a_t; typedef B b_t; A p_a; B p_b; endclass
  // time / longint / shortreal — more scalar kinds
  class c_time  #(type A=time,      type B=A); typedef A a_t; typedef B b_t; A p_a; B p_b; endclass
  class c_lint  #(type A=longint,   type B=A); typedef A a_t; typedef B b_t; A p_a; B p_b; endclass
  class c_sreal #(type A=shortreal, type B=A); typedef A a_t; typedef B b_t; A p_a; B p_b; endclass
  class c_reg   #(type A=reg,       type B=A); typedef A a_t; typedef B b_t; A p_a; B p_b; endclass
  class c_chand #(type A=chandle,   type B=A); typedef A a_t; typedef B b_t; A p_a; B p_b; endclass

  // AGGREGATE / CONTAINER DEFAULTS — the law's allow-list EXCLUDES these.
  class c_qu   #(type A=qi_t, type B=A); typedef A a_t; typedef B b_t; A p_a; B p_b; endclass
  class c_dy   #(type A=di_t, type B=A); typedef A a_t; typedef B b_t; A p_a; B p_b; endclass
  class c_as   #(type A=ai_t, type B=A); typedef A a_t; typedef B b_t; A p_a; B p_b; endclass
  class c_fx   #(type A=fi_t, type B=A); typedef A a_t; typedef B b_t; A p_a; B p_b; endclass
  class c_supk #(type A=su_t, type B=A); typedef A a_t; typedef B b_t; A p_a; B p_b; endclass
  class c_ific #(type A=ifc_a, type B=A); typedef A a_t; typedef B b_t; A p_a; B p_b; endclass

  // TYPEDEF-OF-TYPEDEF chains inside the class (uvm87 rule 1: consumption)
  class c_tdtd #(type A=int, type B=A);
    typedef A a_t;
    typedef a_t a2_t;     // consumes a_t
    typedef B b_t;
    A p_a; B p_b;
  endclass
  // consumption where the CONSUMED one is the only candidate of its parameter
  class c_tdtd2 #(type A=int, type B=A);
    typedef B b_t;
    typedef b_t b2_t;     // consumes b_t -> B has NO surviving candidate
    A p_a; B p_b;
  endclass
  // three-deep chain of typedefs
  class c_tdtd3 #(type A=int, type B=A);
    typedef A a_t;
    typedef a_t a2_t;
    typedef a2_t a3_t;
    typedef B b_t;
    A p_a; B p_b;
  endclass

  // LONG parameter chain, 5 deep, typedef only on the MIDDLE one
  class c_chain5 #(type A=int, type B=A, type C=B, type D=C, type E=D);
    typedef C c_t;
    A p_a; B p_b; C p_c; D p_d; E p_e;
  endclass
  // 5 deep, typedefs on FIRST and LAST
  class c_chain5b #(type A=int, type B=A, type C=B, type D=C, type E=D);
    typedef A a_t;
    typedef E e_t;
    A p_a; E p_e;
  endclass

  // MIXED qualifiers on ONE chain: local on the LAST, public on the first
  class c_qmix #(type A=int, type B=A);
    typedef A a_t;
    local typedef B lb_t;
    A p_a; B p_b;
  endclass
  // and the reverse: local on the FIRST, public on the last
  class c_qmix2 #(type A=int, type B=A);
    local typedef A la_t;
    typedef B b_t;
    A p_a; B p_b;
  endclass
endpackage

module topv1;
  import pv1::*;
  c_integer u1; c_time u2; c_lint u3; c_sreal u4; c_reg u5; c_chand u6;
  c_qu u7; c_dy u8; c_as u9; c_fx u10; c_supk u11; c_ific u12;
  c_tdtd u13; c_tdtd2 u14; c_tdtd3 u15;
  c_chain5 u16; c_chain5b u17; c_qmix u18; c_qmix2 u19;
endmodule
