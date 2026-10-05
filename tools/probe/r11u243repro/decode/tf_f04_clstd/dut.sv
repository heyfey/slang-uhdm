// § fixedClassPropIsArrayVar6 (decode of its residue R1, a typedef-named unpacked-array class property; not written by r11u243)
// class-scope typedefs of fixed, queue and 2-D fixed arrays typing properties of the same class
package p;
  class fac;
    typedef int f1_t[4];
    typedef int iq_t[$];
    typedef int f2_t[2][3];
    f1_t m_a;
    iq_t m_q;
    f2_t m_f;
  endclass
endpackage
module top;
  import p::*;
  fac f;
endmodule
