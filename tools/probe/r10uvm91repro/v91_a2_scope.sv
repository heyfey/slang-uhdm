// v91 arm 2 — the SCOPES the implementer's grid never leaves the package for:
// module, $unit, interface, nested class, derived class with its own params,
// plus SPECIALIZATION coverage (partial override, class->int, int->class).
class cu_unit #(type A=int, type B=A);   // $unit scope
  typedef A a_t; typedef B b_t; A p_a; B p_b;
endclass
class cu_unit_cls;  int z; endclass
class cu_unit2 #(type A=cu_unit_cls, type B=A);  // class-resolved in $unit
  typedef A a_t; typedef B b_t; A p_a; B p_b;
endclass

package pv2;
  class kB; int y; endclass

  // NESTED class: inner class with its OWN type params, inside an outer one
  class c_outer #(type OA=int, type OB=OA);
    typedef OA oa_t;
    typedef OB ob_t;
    OA p_oa;
    class c_inner #(type IA=int, type IB=IA);
      typedef IA ia_t;
      typedef IB ib_t;
      IA p_ia; IB p_ib;
    endclass
    c_inner p_inner;
  endclass
  // inner class whose typedef names the OUTER class's parameter
  class c_outer2 #(type OA=int, type OB=OA);
    typedef OA oa_t;
    class c_in2;
      typedef OA inner_oa_t;   // names the ENCLOSING class's parameter
      OA p_oa;
    endclass
    OA p_oa;
  endclass

  // DERIVED class introducing its own parameters over a parameterised base
  class c_pbase #(type A=int, type B=A);
    typedef A a_t; typedef B b_t; A p_a; B p_b;
  endclass
  class c_pderi #(type C=int, type D=C) extends c_pbase #(int, int);
    typedef C c_t; typedef D d_t; C p_c; D p_d;
  endclass
  // derived class whose base specialization uses ITS OWN parameter
  class c_pderi2 #(type C=int) extends c_pbase #(C, C);
    typedef C c_t; C p_c;
  endclass

  // PARTIAL specialization: override only the FIRST of a 3-chain
  class c_p3 #(type A=int, type B=A, type C=B);
    typedef A a_t; typedef B b_t; typedef C c_t;
    A p_a; B p_b; C p_c;
  endclass
  typedef c_p3 #(bit)            c_p3_part_t;   // A=bit, B,C default to A
  typedef c_p3 #(bit, bit)       c_p3_part2_t;
  typedef c_p3 #(bit, bit, bit)  c_p3_all_t;
  typedef c_p3 #(kB, kB, kB)     c_p3_cls_t;    // int -> CLASS
  typedef c_p3 #(int, kB, int)   c_p3_mix_t;    // MIXED: middle becomes class

  // class -> int specialization (the reverse of the grid's int -> class)
  class c_cbase #(type A=kB, type B=A);
    typedef A a_t; typedef B b_t; A p_a; B p_b;
  endclass
  typedef c_cbase #(int, int) c_cbase_int_t;
  typedef c_cbase #(int)      c_cbase_intp_t;
endpackage

interface iv2;
  // class declared inside an INTERFACE
  class c_in_iface #(type A=int, type B=A);
    typedef A a_t; typedef B b_t; A p_a; B p_b;
  endclass
  c_in_iface u_ifc;
endinterface

module mv2;
  // class declared inside a MODULE
  class c_in_mod #(type A=int, type B=A);
    typedef A a_t; typedef B b_t; A p_a; B p_b;
  endclass
  c_in_mod u_mod;
endmodule

module topv2;
  import pv2::*;
  cu_unit u0; cu_unit2 u0b;
  c_outer u1; c_outer2 u2;
  c_pbase u3; c_pderi u4; c_pderi2 u5;
  c_p3 u6;
  c_p3_part_t u7; c_p3_part2_t u8; c_p3_all_t u9;
  c_p3_cls_t u10; c_p3_mix_t u11;
  c_cbase u12; c_cbase_int_t u13; c_cbase_intp_t u14;
  mv2 i_mv2();
  iv2 i_iv2();
endmodule
