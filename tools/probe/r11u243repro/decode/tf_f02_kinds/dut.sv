// § fixedClassPropIsArrayVar6 (decode of its residue R1, a typedef-named unpacked-array class property; not written by r11u243)
// class properties typed by typedefs of a 1-D fixed array, a queue, a dynamic array and a 2-D fixed array
package p;
  typedef int f1_t[4];
  typedef int iq_t[$];
  typedef byte id_t[];
  typedef logic [3:0] f2_t[2][3];
  class fac;
    f1_t m_a;
    iq_t m_q;
    id_t m_d;
    f2_t m_f;
  endclass
endpackage
module top;
  import p::*;
  fac f;
endmodule
