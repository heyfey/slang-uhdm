// § fixedClassPropIsArrayVar6 (decode of its residue R1, a typedef-named unpacked-array class property; not written by r11u243)
// $unit typedefs of fixed, queue and dynamic arrays typing class properties
typedef int f1_t[4];
typedef int iq_t[$];
class fac;
  f1_t m_a;
  iq_t m_q;
endclass
module top;
  fac f;
endmodule
